---
title: "ESP32 HTTPS requests: TLS strategies & memory cost (Random Nerd Tutorials)"
source: https://randomnerdtutorials.com/esp32-https-requests/
type: article
tags: [esp32, https, tls, wificlientsecure, ca-cert, setinsecure, memory, heap-leak]
date: 2026-07-20
quality: 4
confidence: high
summary: "The two TLS strategies on ESP32: setCACert (verifies identity, production, requires maintaining rotating root certs) vs setInsecure (encrypted but unauthenticated, fine for public read-only APIs/prototyping). TLS handshake buffers are the biggest RAM consumer; repeated HTTPS connects leak heap -> delete the client, don't just stop()."
---

# ESP32 HTTPS requests (Random Nerd Tutorials)

HTTPS is the real memory tax, not JSON.

- Two TLS strategies:
  - `client.setCACert(rootCACertificate)` — verifies server identity (production). Must embed and **periodically maintain rotating root certs** (they expire) — a real maintenance cost.
  - `client.setInsecure()` — encrypted but unauthenticated (no MITM protection). Fine for public read-only APIs / fast prototyping.
- `HTTPClient` wraps a `WiFiClientSecure*`; `https.GET()` then stream/parse the body.
- **Memory gotcha**: repeated HTTPS connections leak heap and eventually crash — fix is to `delete` the client object, not just `client.stop()`. **TLS handshake buffers are the biggest RAM consumer** on the device.
- Trade-off: certificate = high security / production; setInsecure = high convenience / testing.
