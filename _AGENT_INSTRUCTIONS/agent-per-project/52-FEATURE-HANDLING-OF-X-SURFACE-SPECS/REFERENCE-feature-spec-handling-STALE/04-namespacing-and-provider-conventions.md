# Namespacing and Provider Conventions

This document defines naming and import conventions used to keep feature-level
spec handling consistent, scalable, and friendly to both humans and agents.

The architecture relies on **namespacing via imports**, not globally unique names.

---

## Generic Provider Names

Within a feature, providers are allowed (and encouraged) to use **generic names**.

Examples:

- infoCassetteSpecCoordinatorProvider
- infoContentResolverProvider
- featureCassetteSpecCoordinatorProvider
- settingsCassetteSpecCoordinatorProvider

These names intentionally do not encode the feature name.

---

## Import Aliasing Is Mandatory

All feature-level provider exports must be imported using an alias.

Example:

import 'features/handles/feature_level_providers.dart'
  as handles_feature;

Usage:

ref.read(
  handles_feature.infoContentResolverProvider.notifier
);

This ensures:

- no naming collisions
- immediate visibility of feature ownership
- uniform APIs across features

---

## Barrel Files

Each feature exposes a single barrel file:

features/<feature>/feature_level_providers.dart

This file:

- exports application-layer coordinators and resolvers
- does not contain logic
- provides the public feature API to the rest of the app

App-level code must never import feature internals directly.

---

## Riverpod Generated Providers

All coordinators and resolvers use Riverpod code generation.

Consequences:

- provider names are fixed by class names
- feature-level naming discipline is critical
- provider identity is stable and predictable

Generated providers are treated as part of the public feature API.

---

## Class Naming vs Provider Naming

Class names may be generic or feature-specific depending on taste.
Provider names remain generic.

Debugging and stack traces rely on:

- file paths
- import aliases
- surrounding context

Avoid embedding feature names into provider identifiers.

---

## Rules Summary

- Always import feature providers with an alias
- Never rely on globally unique provider names
- Never expose feature internals directly
- Treat feature_level_providers.dart as the only entry point
