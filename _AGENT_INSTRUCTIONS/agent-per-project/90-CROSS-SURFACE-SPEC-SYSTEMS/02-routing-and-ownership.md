# Routing and Ownership

This document clarifies who owns what, and how routing works.

---

## Ownership Summary

Essentials owns:

- system state
- system coordinator
- system payload view models
- outer routing spec: <System>Spec.<feature>(innerSpec)

Features own:

- inner spec definitions
- feature coordinators/cases/builders for that system
- meaning: keys, enums, constants, copy rules, computed values

---

## Routing Rule

System coordinator must only do:

switch (outerSpec) {
  case <System>Spec.contacts(inner):
    delegate to contacts feature
  case <System>Spec.handles(inner):
    delegate to handles feature
  ...
}

System coordinator must not do:

- switch on inner spec variants
- interpret keys inside inner specs
- compute feature-specific values
- format feature-specific text

---

## Feature Execution Model

Feature receives its inner spec and runs:

innerSpec
 → feature-level system coordinator (routing only)
   → feature system case handlers / resolvers (logic + data)
     → system payload model
       → essentials system coordinator inserts payload into system UI

This keeps:

- app-level routing simple
- feature logic local
- surfaces decoupled