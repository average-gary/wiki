# On-Device Data Layer: mempool.space + Open-Meteo request specs, ArduinoJson v7 filters & parse code

> ### ✅ VERIFIED CORRECTION (apply — OVERRIDES the draft code below)
> Adversarial verify pass, high confidence:
> - **DELETE every `client->setTimeout(HTTP_TIMEOUT_MS / 1000)` call** (draft lines ~49, ~89). `WiFiClientSecure::setTimeout()` unit is **core-version-dependent**: seconds on Arduino-ESP32 core 2.x, but the class is renamed `NetworkClientSecure` on core 3.x and the ms/1000 math becomes an **8 ms** timeout → **every HTTPS handshake fails.** Set timeouts ONLY on the `HTTPClient` (`https.setConnectTimeout(ms)` / `https.setTimeout(ms)`), which the draft already does — just remove the `client->setTimeout()` lines entirely.
> - The `delete client;` per-request discipline (not `stop()`) is CORRECT and MUST be kept — this fork is always-on over USB, so the TLS heap leak would eventually crash it (upstream only survives with `stop()` because it deep-sleeps/reboots each cycle).
> - Keep ArduinoJson **v7** elastic `JsonDocument` (do not downgrade to v6 `StaticJsonDocument<N>`); parse `/api/blocks/tip/height` with `atoi` (bare integer); use `strtol`/long for price. Close/`delete` the TLS client BEFORE the `firstPage()/nextPage()` render loop so TLS + framebuffer don't coincide and OOM.
> - Full C1–C7 list: `../buildlog-phase0-2026-07-20.md`.

# On-Device Data Layer Spec — mempool.space + Open-Meteo

Target: fork of `lmarzen/esp32-weather-epd` (Arduino/PlatformIO, ESP32-WROOM-32E, no PSRAM), fetching Bitcoin + weather over WiFi and rendering with GxEPD2. This document is the **data layer only** — HTTPS transport, endpoint specs, ArduinoJson **v7** filters/sizing, C++ structs, and parse code. Display code is out of scope.

All snippets assume the Arduino-ESP32 core (`HTTPClient`, `WiFiClientSecure`) and **ArduinoJson 7.x** (`ArduinoJson@^7` in `platformio.ini`).

> Provenance: JSON shapes below were pulled live from the real endpoints this session (2026-07-20). ArduinoJson v7 semantics verified against arduinojson.org. Upstream HTTPS pattern verified against `esp32-weather-epd/platformio/src/client_utils.cpp`.

---

## 0. HTTPS transport discipline (the memory-critical part)

Per the wiki, TLS handshake buffers — **not** JSON parsing — are the biggest RAM consumer, and repeated HTTPS connects **leak heap unless you `delete` the `WiFiClientSecure`** (calling `stop()` alone is not enough). ([HTTPS reality](/Users/garykrause/wiki/topics/eink-esp32-dashboard/raw/articles/2026-07-20-esp32-https-requests.md), [ArduinoJson streaming](/Users/garykrause/wiki/topics/eink-esp32-dashboard/raw/articles/2026-07-20-arduinojson-httpclient.md))

Note: upstream `esp32-weather-epd` reuses one `WiFiClientSecure` passed by reference and only calls `client.stop()`. We deliberately diverge to the wiki's **heap-allocate-and-`delete`-per-request** discipline, which is the safer pattern for a long-lived always-on USB dashboard doing many cycles.

One generic helper drives every JSON endpoint. It uses `setInsecure()` (encrypted but unauthenticated — acceptable for these public read-only APIs, and it dodges the cost of maintaining rotating CA roots), `useHTTP10(true)` (defeats chunked transfer encoding so the stream parses cleanly), streams straight into the `JsonDocument`, and applies an optional `Filter`.

```cpp
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>   // v7

// TCP + TLS timeouts. e-ink cycles are slow; be generous but bounded.
static const uint16_t HTTP_TIMEOUT_MS = 8000;

// HTTP status helpers (from esp_http_client / HTTPClient)
#ifndef HTTP_CODE_OK
  #define HTTP_CODE_OK 200
#endif
#define HTTP_CODE_TOO_MANY_REQUESTS 429

// Return values: >0 => HTTP status code; <=0 => local error.
enum : int { ERR_NO_CLIENT = -1, ERR_CONNECT = -2, ERR_DESERIALIZE = -3 };

// Streams JSON from `url` into `doc`. If `filter` != nullptr, applies it.
// Returns the HTTP status code (200 on success) or a negative ERR_* code.
int httpsGetJson(const String &url, JsonDocument &doc, const JsonDocument *filter = nullptr)
{
  WiFiClientSecure *client = new WiFiClientSecure;
  if (!client) return ERR_NO_CLIENT;

  client->setInsecure();                 // encrypted, NOT authenticated (public read-only API)
  // NOTE: WiFiClientSecure::setTimeout() takes SECONDS on most Arduino-ESP32 cores
  // (unlike HTTPClient::setTimeout which is ms). See risky claims.
  client->setTimeout(HTTP_TIMEOUT_MS / 1000);

  int code = ERR_CONNECT;
  {
    HTTPClient https;
    https.setConnectTimeout(HTTP_TIMEOUT_MS);   // ms
    https.setTimeout(HTTP_TIMEOUT_MS);          // ms
    https.useHTTP10(true);                       // defeat chunked encoding for streamed parse
    https.addHeader("User-Agent", "esp32-eink-dashboard/1.0");

    if (https.begin(*client, url)) {
      code = https.GET();
      if (code == HTTP_CODE_OK) {
        DeserializationError err = filter
          ? deserializeJson(doc, https.getStream(),
                             DeserializationOption::Filter(*filter))
          : deserializeJson(doc, https.getStream());
        if (err) {
          Serial.printf("[json] deserialize failed: %s\n", err.c_str());
          code = ERR_DESERIALIZE;
        }
      }
      https.end();
    }
  } // HTTPClient destroyed here (stack)

  delete client;   // <-- MUST delete, not just stop(): prevents the TLS heap leak
  return code;
}
```

For the **bare-integer** block-height endpoint there is no JSON — read the body as text and convert:

```cpp
// Returns block height, or 0 on failure.
uint32_t httpsGetPlainUint(const String &url)
{
  WiFiClientSecure *client = new WiFiClientSecure;
  if (!client) return 0;
  client->setInsecure();
  client->setTimeout(HTTP_TIMEOUT_MS / 1000);

  uint32_t value = 0;
  {
    HTTPClient https;
    https.setConnectTimeout(HTTP_TIMEOUT_MS);
    https.setTimeout(HTTP_TIMEOUT_MS);
    https.useHTTP10(true);
    if (https.begin(*client, url)) {
      int code = https.GET();
      if (code == HTTP_CODE_OK) {
        // Body is e.g. "958913\n" — no JSON. strtoul is robust to trailing whitespace.
        value = (uint32_t) strtoul(https.getString().c_str(), nullptr, 10);
      }
      https.end();
    }
  }
  delete client;
  return value;
}
```

---

## 1. ArduinoJson v7 essentials (what changed from v6)

The wiki's how-to article links the v6 docs; upstream and most tutorials are still v6. **We target v7.** Key differences that touch this code (verified at arduinojson.org):

- `StaticJsonDocument<N>` and `DynamicJsonDocument(N)` are **gone**, merged into a single **`JsonDocument`** with **elastic capacity** (it grows automatically). You just write `JsonDocument doc;` — **no size argument**. `shrinkToFit()` is called automatically during deserialization.
- Removed: `capacity()`, `containsKey()`, `memoryUsage()`, `garbageCollect()`, the `JSON_OBJECT_SIZE()`/`JSON_ARRAY_SIZE()` macros.
- **`deserializeJson()` and `DeserializationOption::Filter` are unchanged in usage** — same call signature as v6.
- The `doc["key"] | default` "or-default" operator still works and is the safe way to read possibly-missing fields.

### JsonDocument sizing (v7)

Because v7 is elastic there is no capacity to compute, but you still care about the **peak heap** each doc holds. Approximate footprints for our filtered payloads (each is freed when the doc goes out of scope):

| Endpoint (filtered) | Fields kept | Approx. heap for the doc |
|---|---|---|
| `/api/v1/fees/recommended` | 5 ints | < 200 B |
| `/api/v1/prices` (USD + time) | 2 numbers | < 150 B |
| `/api/blocks/tip/height` | none (plain int) | 0 (no JsonDocument) |
| Open-Meteo (current + 3-day daily) | ~7 current + 4×3 daily | ~1.5–2.5 KB |

The dominant memory cost is still the **TLS session (tens of KB)**, not any of these docs — which is exactly why the `delete client` discipline matters more than doc sizing.

### Filter mechanics (v7, identical to v6.15+)

Build a second `JsonDocument`; set a key to `true` to **keep that member and everything under it**; omit a key to **drop it**. For arrays, the **first element** of the filter (`filter[0]`) is the template applied to every array item. Then pass `DeserializationOption::Filter(filter)` to `deserializeJson`.

```cpp
JsonDocument filter;
filter["current"] = true;   // keep the whole "current" object
filter["daily"]   = true;   // keep the whole "daily" object
// "hourly", "*_units", "generationtime_ms", etc. are NOT listed -> dropped
```

---

## 2. mempool.space — Bitcoin data

Host `https://mempool.space` (HTTPS/443). No API key. Rate-limited by **HTTP 429** with no published numeric limit → **poll on the order of minutes, never seconds**. ([mempool API](/Users/garykrause/wiki/topics/eink-esp32-dashboard/raw/data/2026-07-20-mempool-space-api.md))

### 2a. Recommended fees — `GET /api/v1/fees/recommended`

**Live response (verbatim, 2026-07-20):**
```json
{"fastestFee":4,"halfHourFee":3,"hourFee":1,"economyFee":1,"minimumFee":1}
```
All values are integer **sat/vB**. Flat object, ~70 bytes — a filter is optional but cheap. Struct + parse:

```cpp
struct BitcoinFees {
  int fastest;   // fastestFee  (next block)
  int halfHour;  // halfHourFee
  int hour;      // hourFee
  int economy;   // economyFee
  int minimum;   // minimumFee  (mempool floor)
};

bool fetchFees(BitcoinFees &out)
{
  JsonDocument doc;   // ~200 B; no filter needed for a 5-field object
  int code = httpsGetJson("https://mempool.space/api/v1/fees/recommended", doc);
  if (code != HTTP_CODE_OK) { logMempoolCode(code); return false; }

  out.fastest  = doc["fastestFee"]  | 0;
  out.halfHour = doc["halfHourFee"] | 0;
  out.hour     = doc["hourFee"]     | 0;
  out.economy  = doc["economyFee"]  | 0;
  out.minimum  = doc["minimumFee"]  | 0;
  return out.fastest > 0;   // sanity: fastestFee is never 0
}
```

### 2b. Block tip height — `GET /api/blocks/tip/height`

**Live response (verbatim, 2026-07-20):** a bare integer, no JSON, no braces:
```
958913
```
Parse with the plain-text helper — **do not** feed this to ArduinoJson.

```cpp
bool fetchBlockHeight(uint32_t &out)
{
  uint32_t h = httpsGetPlainUint("https://mempool.space/api/blocks/tip/height");
  if (h == 0) return false;   // 0 is never a valid current tip
  out = h;
  return true;
}
```

### 2c. Price — `GET /api/v1/prices`

**Live response (verbatim, 2026-07-20):**
```json
{"time":1784567405,"USD":65475,"EUR":57359,"GBP":48761,"CAD":92052,"CHF":52972,"AUD":93340,"JPY":10628130}
```
Fiat values are **integers** (whole currency units, not cents). `time` is a Unix epoch (seconds). We render USD only, so filter to `USD` + `time`:

```cpp
struct BitcoinPrice {
  long usd;    // whole USD
  long time;   // unix epoch seconds (server-side price timestamp)
};

bool fetchPrice(BitcoinPrice &out)
{
  JsonDocument filter;
  filter["USD"]  = true;
  filter["time"] = true;   // drops EUR/GBP/CAD/CHF/AUD/JPY

  JsonDocument doc;   // < 150 B after filtering
  int code = httpsGetJson("https://mempool.space/api/v1/prices", doc, &filter);
  if (code != HTTP_CODE_OK) { logMempoolCode(code); return false; }

  out.usd  = doc["USD"]  | 0L;
  out.time = doc["time"] | 0L;
  return out.usd > 0;
}
```

---

## 3. Open-Meteo — weather

Host `https://api.open-meteo.com` (HTTPS/443). No API key for non-commercial use; ~10k calls/day free tier — polling every 15–30 min is trivially within limits. ([Open-Meteo](/Users/garykrause/wiki/topics/eink-esp32-dashboard/raw/data/2026-07-20-open-meteo-api.md))

### 3a. Request URL — only the fields worth rendering

Request **`current` + `daily` only** (no `hourly`), 3 forecast days, imperial units, local timezone. Keeping `hourly` out of the URL is the first-line defense; the Filter is defense-in-depth (also strips metadata).

```
https://api.open-meteo.com/v1/forecast
  ?latitude=40.71&longitude=-74.01
  &current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m
  &daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max
  &timezone=auto
  &forecast_days=3
  &temperature_unit=fahrenheit
  &wind_speed_unit=mph
```

Build it from your captive-portal-configured lat/lon:

```cpp
String buildForecastUrl(double lat, double lon)
{
  String u = "https://api.open-meteo.com/v1/forecast";
  u += "?latitude="  + String(lat, 4);
  u += "&longitude=" + String(lon, 4);
  u += "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m";
  u += "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max";
  u += "&timezone=auto&forecast_days=3&temperature_unit=fahrenheit&wind_speed_unit=mph";
  return u;
}
```

### 3b. Live response shape (verbatim, 2026-07-20)

```json
{
  "latitude": 40.710335, "longitude": -73.99308,
  "generationtime_ms": 0.49, "utc_offset_seconds": -14400,
  "timezone": "America/New_York", "timezone_abbreviation": "GMT-4", "elevation": 27.0,
  "current_units": { "time":"iso8601","interval":"seconds","temperature_2m":"°F",
    "relative_humidity_2m":"%","apparent_temperature":"°F","is_day":"",
    "weather_code":"wmo code","wind_speed_10m":"mp/h" },
  "current": { "time":"2026-07-20T13:15","interval":900,"temperature_2m":81.5,
    "relative_humidity_2m":31,"apparent_temperature":81.6,"is_day":1,
    "weather_code":0,"wind_speed_10m":8.4 },
  "daily_units": { "time":"iso8601","weather_code":"wmo code",
    "temperature_2m_max":"°F","temperature_2m_min":"°F","precipitation_probability_max":"%" },
  "daily": {
    "time": ["2026-07-20","2026-07-21","2026-07-22"],
    "weather_code": [0,63,51],
    "temperature_2m_max": [83.5,83.5,87.0],
    "temperature_2m_min": [59.8,67.8,71.7],
    "precipitation_probability_max": [0,50,76]
  }
}
```

Note the `daily.*` values are **parallel arrays** indexed by day, not an array of objects. `weather_code` is a **WMO code** (0=clear, 61–65=rain, 71–75=snow, etc.).

### 3c. Filter (skip hourly + all metadata), structs, parse

```cpp
static const int N_DAILY = 3;

struct CurrentWeather {
  char  time[20];       // "2026-07-20T13:15"
  float temp;           // temperature_2m (°F)
  int   humidity;       // relative_humidity_2m (%)
  float apparentTemp;   // apparent_temperature (°F)
  bool  isDay;          // is_day (1/0)
  int   weatherCode;    // WMO
  float windSpeed;      // wind_speed_10m (mph)
};

struct DailyWeather {
  char  date[11];       // "2026-07-20"
  int   weatherCode;    // WMO
  float tMax, tMin;     // °F
  int   precipProbMax;  // %
};

struct WeatherData {
  CurrentWeather current;
  DailyWeather   daily[N_DAILY];
  long           utcOffsetSeconds;
};

bool fetchWeather(double lat, double lon, WeatherData &w)
{
  // Filter: keep only current + daily (+ tz offset). Drops hourly (if ever present),
  // *_units, generationtime_ms, elevation, etc.
  JsonDocument filter;
  filter["current"]            = true;
  filter["daily"]              = true;
  filter["utc_offset_seconds"] = true;

  JsonDocument doc;   // ~1.5–2.5 KB after filtering
  int code = httpsGetJson(buildForecastUrl(lat, lon), doc, &filter);
  if (code != HTTP_CODE_OK) {
    Serial.printf("[open-meteo] HTTP/err %d\n", code);
    return false;
  }

  w.utcOffsetSeconds = doc["utc_offset_seconds"] | 0L;

  JsonObject cur = doc["current"];
  strlcpy(w.current.time, cur["time"] | "", sizeof(w.current.time));
  w.current.temp         = cur["temperature_2m"]      | NAN;
  w.current.humidity     = cur["relative_humidity_2m"]| 0;
  w.current.apparentTemp = cur["apparent_temperature"]| NAN;
  w.current.isDay        = (cur["is_day"] | 1) != 0;
  w.current.weatherCode  = cur["weather_code"]        | -1;
  w.current.windSpeed    = cur["wind_speed_10m"]      | NAN;

  JsonObject daily = doc["daily"];
  JsonArray  dTime = daily["time"];
  int n = min((int)dTime.size(), N_DAILY);
  for (int i = 0; i < n; i++) {
    strlcpy(w.daily[i].date, daily["time"][i] | "", sizeof(w.daily[i].date));
    w.daily[i].weatherCode   = daily["weather_code"][i]                 | -1;
    w.daily[i].tMax          = daily["temperature_2m_max"][i]           | NAN;
    w.daily[i].tMin          = daily["temperature_2m_min"][i]           | NAN;
    w.daily[i].precipProbMax = daily["precipitation_probability_max"][i]| 0;
  }
  return !isnan(w.current.temp);
}
```

Optional WMO-code → short label helper for rendering:

```cpp
const char* wmoShort(int code)
{
  switch (code) {
    case 0:            return "Clear";
    case 1: case 2:    return "Mostly clear";
    case 3:            return "Overcast";
    case 45: case 48:  return "Fog";
    case 51: case 53: case 55: return "Drizzle";
    case 61: case 63: case 65: return "Rain";
    case 66: case 67:  return "Freezing rain";
    case 71: case 73: case 75: return "Snow";
    case 77:           return "Snow grains";
    case 80: case 81: case 82: return "Showers";
    case 85: case 86:  return "Snow showers";
    case 95:           return "Thunderstorm";
    case 96: case 99:  return "Thunderstorm+hail";
    default:           return "--";
  }
}
```

---

## 4. Rate limiting, retries & RTC persistence

mempool.space returns **HTTP 429** on abuse (possible temporary ban). Open-Meteo can 429 if you hammer it, but our cadence won't. Strategy:

- **Poll cadence**: Bitcoin every ~5 min (block time is ~10 min; fees drift slowly), weather every ~15–30 min. Since e-ink runs full-refresh per wake, a single ~15-min wake fetching all four is simplest.
- **On 429**: do **not** retry immediately. Keep the last-known value (persisted in RTC memory across deep sleep) and back off — skip N cycles before retrying.
- **On transient failure** (`ERR_CONNECT`, timeout): one short retry, then fall back to last-known.

```cpp
// Survives deep sleep (RTC slow memory). Keep it small.
RTC_DATA_ATTR struct {
  BitcoinFees   fees;
  BitcoinPrice  price;
  uint32_t      blockHeight;
  WeatherData   weather;
  uint8_t       mempoolBackoff;   // cycles to skip after a 429
  bool          valid;            // any good data yet?
} g_cache;

void logMempoolCode(int code)
{
  if (code == HTTP_CODE_TOO_MANY_REQUESTS) {
    g_cache.mempoolBackoff = 3;   // skip ~3 cycles (~15 min at 5-min cadence)
    Serial.println("[mempool] 429 -> backing off, using cached values");
  } else if (code != HTTP_CODE_OK) {
    Serial.printf("[mempool] HTTP/err %d\n", code);
  }
}

// In the wake loop, gate mempool calls on the backoff counter:
void refreshBitcoin()
{
  if (g_cache.mempoolBackoff > 0) { g_cache.mempoolBackoff--; return; } // stay on cache

  BitcoinFees f; if (fetchFees(f))          g_cache.fees = f;
  BitcoinPrice p; if (fetchPrice(p))        g_cache.price = p;
  uint32_t h; if (fetchBlockHeight(h))      g_cache.blockHeight = h;
  g_cache.valid = true;
}
```

Render from `g_cache` regardless of whether this cycle's fetch succeeded — the screen always shows last-known data, never blanks on a transient network hiccup.

---

## 5. Where this plugs into the esp32-weather-epd fork

- Replace the OpenWeatherMap code in `platformio/src/client_utils.cpp` (functions like `getOWMonecall`) with the fetch helpers above; upstream already uses the `http.begin(client, ...)` → `http.GET()` → `deserializeJson(http.getStream(), ...)` → `http.end()` skeleton, so this drops in.
- Upstream defines response structs in `platformio/src/_locale`/`api_response.h`; add `BitcoinFees`/`BitcoinPrice`/`WeatherData` alongside (or replace) those.
- Upstream currently **reuses one `WiFiClientSecure` + `client.stop()`**; switch to the `new`/`delete`-per-request helper here to follow the wiki's heap-leak guidance.
- Bump `platformio.ini`: `ArduinoJson@^7` (upstream pins v6 — the v7 changes in §1 are why the parse code uses `JsonDocument doc;` with no size arg).


---
## Risky claims flagged for verification

- **WiFiClientSecure::setInsecure() combined with delete-the-client-per-request (not just stop()) is the correct heap-leak-avoidance pattern; upstream esp32-weather-epd actually reuses a single by-reference client and only calls client.stop().**
  - risk: If the fork keeps upstream's reuse-by-reference model, adding new/delete per cycle changes lifetime semantics; conversely if you keep stop() only, the wiki-documented TLS heap leak can crash the device after many always-on USB cycles. The divergence from upstream must be applied deliberately in client_utils.cpp.
- **ArduinoJson v7 uses a single elastic JsonDocument declared with no size argument (JsonDocument doc;), and DeserializationOption::Filter is used identically to v6.**
  - risk: Upstream esp32-weather-epd pins ArduinoJson v6 (StaticJsonDocument<N>). Compiling the v7-style snippets against a v6 dependency will fail; the platformio.ini dependency must actually be bumped to ArduinoJson@^7 or the code rewritten for v6.
- **mempool.space /api/v1/prices returns integer whole-currency values (USD:65475, no cents) and /api/v1/fees/recommended returns integer sat/vB; /api/blocks/tip/height returns a bare integer with no JSON.**
  - risk: Parsing code assumes integer types and treats price as whole dollars; if a value is ever fractional or the height endpoint changes to JSON, atoi/strtoul/long parsing silently produces wrong displayed numbers. Verified live 2026-07-20 but the API contract is not versioned-guaranteed.
- **WiFiClientSecure::setTimeout() takes SECONDS on Arduino-ESP32, whereas HTTPClient::setTimeout()/setConnectTimeout() take milliseconds.**
  - risk: The helper passes HTTP_TIMEOUT_MS/1000 to the client. If the installed core version actually expects milliseconds there, the TLS socket timeout becomes 8ms and every HTTPS request fails; the units differ by core version and are a known footgun.
- **An Open-Meteo Filter that sets only current/daily/utc_offset_seconds to true reliably drops hourly and metadata, and daily.* fields arrive as parallel scalar arrays indexed by day (not an array of objects).**
  - risk: If daily were an array-of-objects (or field names changed), the [i] index parse would read wrong/empty values; and if the filter semantics differ, hourly could bloat the JsonDocument past the heap budget on the no-PSRAM WROOM. Shape verified live 2026-07-20.
