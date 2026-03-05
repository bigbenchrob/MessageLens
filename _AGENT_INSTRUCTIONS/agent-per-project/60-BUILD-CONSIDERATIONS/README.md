---
tier: project
scope: build
owner: agent-per-project
last_reviewed: 2025-07-27
source_of_truth: doc
links:
  - ./01-rust-ffi-dylib-bundling.md
tests: []
---

# Build Considerations

This folder documents platform-specific build requirements, release packaging gotchas, and build phase configurations that are critical for the app to function correctly outside of development.

## Contents

| Doc | Topic |
|-----|-------|
| [`01-rust-ffi-dylib-bundling.md`](01-rust-ffi-dylib-bundling.md) | **🔥 CRITICAL**: How the Rust FFI dylib is bundled into the macOS app and why `flutter_rust_bridge`'s default loader fails in release builds |
