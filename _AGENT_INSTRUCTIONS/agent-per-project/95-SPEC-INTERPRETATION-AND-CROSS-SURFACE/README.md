# Spec Interpretation + Cross-Surface Systems

This folder unifies the documentation for feature-side spec interpretation and
cross-surface spec systems (sidebar, onboarding, tooltips, etc.).

It defines the canonical flow, ownership boundaries, and templates needed to
keep spec-driven UI systems consistent and extensible.

## Read order

1) [Overview + Goals](00-overview-and-goals.md)
2) [Core Principles + Ownership](01-core-principles-and-ownership.md)
3) [Sidebar Cassette Spec-to-Widget Contract](02-sidebar-cassette-spec-to-widget-contract.md)
4) [Cross-Surface Spec Systems](03-cross-surface-spec-systems.md)
5) [Common Failure Modes](04-common-failure-modes.md)
6) [Base Spec Coordinator Template](05-base-spec-coordinator-template.md)
7) [Example End-to-End Onboarding Flow](06-example-end-to-end-onboarding-flow.md)
8) [TLDR for Agents](TLDR-for-agents.md)

## Canonical flow (keep consistent)

Spec
-> Feature coordinator (routing only)
-> Application-layer resolver / case handler
-> View model or content payload
-> App-level coordinator chooses chrome
-> Presentation widgets render UI
