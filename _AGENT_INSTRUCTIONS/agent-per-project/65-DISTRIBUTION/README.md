---
tier: project
scope: distribution
owner: agent-per-project
last_reviewed: 2026-08-30
source_of_truth: doc
links:
  - ./10-render-tester-portal.md
  - ../60-BUILD-CONSIDERATIONS/README.md
tests: []
---

# Distribution

This folder documents how a finished MessageLens build becomes a public tester
download.

Build and distribution are separate responsibilities:

```text
MessageLens app repository
    builds, signs, notarizes, and packages the DMG

MessageLens tester-portal repository
    contains the static website, release metadata, and downloadable DMG

Render Static Site
    deploys the tester portal after the publishing branch is pushed to GitHub
```

Preparing the website repository locally is not publication. A release is
public only after the website commit has been pushed, Render has deployed it,
and both the site and exact download URL have been verified.

## Contents

| Document | Purpose |
| --- | --- |
| [`10-render-tester-portal.md`](10-render-tester-portal.md) | Canonical hosting service, repositories, public URLs, publishing sequence, and current release handoff |

