---
title: "RELEASE.md"
source: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/RELEASE.md"
type: articles
ingested: 2026-05-28
tags: [collection, stratum-sri, release-process]
summary: "The changelog is a list of notable changes for each version of a project. It is a way to keep track of the project's progress and to communicate the changes to the users and the community."
collection: "stratum-sri"
adapter: git
upstream_id: "RELEASE.md"
upstream_type: git-file
revision: "65c9688ca0e9cdcf213b32a6f51e9309fb75bbab"
sha: "1d84b0ad7cc41e90f0e24271fda74ac0a2ffb80b"
canonical_url: "https://github.com/stratum-mining/stratum/blob/65c9688ca0e9cdcf213b32a6f51e9309fb75bbab/RELEASE.md"
content_format: markdown
license: "Apache-2.0 OR MIT"
fetched: 2026-05-28
---

## Changelog

The changelog is a list of notable changes for each version of a project. 
It is a way to keep track of the project's progress and to communicate 
the changes to the users and the community.

The changelog is automatically generated on each release page, and extra contextual
information is added as needed, such as:
 - General release information.
 - Breaking changes.
 - Notable changes.

## Release Process

Try to constrain each development cycle to a fixed time period, after which a
release is made. After all release tasks are completed, initiate the release
process by creating a new release branch, named `x.y.z.` referring to the
version number, from the `main` branch.  The release branch is used as a
breaking point and future reference for the release and should include the
changelog entries for the release and any other release-specific tasks. Any bug
fixes or changes for the release should be done on the release branch. When the
release branch is ready, create a new tag and initiate any publishing tasks.

Usually the release process is as follows:

1. Create a new release branch from the `main` branch.
2. Create a new tag for the release branch.
3. Publish the release.

## Versioning

Crates follow SemVer 2.0.0. Whenever the repository goes through a global release, all crates are published to crates.io.

The global repository releases follow `X.Y.Z`, which is changed under some subjective criteria:
- If a release includes only bug fixes`, then `Z` is bumped.
- If a release includes breaking and/or non-breaking changes, then `Y` is bumped.
- If a release marks a milestone i.e., crates are reaching a new maturity level, then `X` is bumped.

## Tags and Branches

- Changes to `main` branch should be added through a merge commit.
- The `main` branch is the default branch and it is always active.
- The `main` branch is protected and requires a pull request to merge changes
  with at least 2 approvals.
- Each release is tagged with the version number of the release and a release
  branch is kept for future reference or fixes.
