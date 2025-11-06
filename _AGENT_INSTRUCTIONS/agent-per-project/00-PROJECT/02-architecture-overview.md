---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2025-01-30
source_of_truth: This file
links:
    - ./01-aggregate-boundaries.md
    - ../10-DATABASES/00-all-databases-accessed.md
tests: []
---

# Architecture and Naming Conventions

## Overview
This document describes the Domain-Driven Design (DDD) architecture and naming conventions established for the Remember This Text Flutter project. These conventions ensure clean separation of concerns, maintainability, and consistency across the codebase.

## Feature-Based Folder Structure

Each feature follows a standardized DDD folder structure within `lib/features/`:

```
lib/features/
├── feature_name/
│   ├── application/           # Business logic and orchestration
│   ├── domain/               # Core business entities and interfaces  
│   ├── infrastructure/       # Data sources, repositories, and external services
│   └── presentation/         # UI components and state management
```

## Layer Responsibilities

### Infrastructure Layer
**Purpose**: Data access and external service integration  
**Restrictions**: Should ONLY contain:
- Data sources (local databases, APIs, file systems)
- Repository implementations  
- External service integrations (Rust components, native platform code)
- Corresponding Riverpod providers for the above

**What does NOT belong here**: Business logic, workflow orchestration, application services

**Examples**:
```
infrastructure/
├── data_sources/
│   ├── local/
│   │   ├── import/
│   │   │   └── import_db.dart           # Database operations only
│   │   └── working/
│   │       └── drift_db.dart            # Database schema and queries
│   └── remote/
│       └── api_client.dart              # API integration
├── repositories/
│   └── contact_repository_impl.dart     # Repository pattern implementation
└── rust_extraction/
    ├── rust_message_extractor.dart      # Rust FFI integration
    └── rust_extraction_provider.dart    # Provider for Rust services
```

### Application Layer  
**Purpose**: Business logic, workflows, and use case orchestration  
**Contains**:
- Application services that coordinate business workflows
- Use case implementations
- Business logic validation
- Application-level providers
- Import/export services and their result objects

**Subdivision by use case**: Organize into logical groupings like `import/`, `search/`, `sync/` etc.

**Examples**:
```
application/
├── import/
│   ├── import_service.dart              # Business logic for import workflows
│   ├── import_result.dart               # Result objects and DTOs
│   └── import_application_service.dart  # High-level orchestration
├── application_providers/
│   └── import_service_provider.dart     # Providers for application services
└── use_cases/
    └── sync_contacts_use_case.dart      # Specific business use cases
```

### Domain Layer
**Purpose**: Core business entities, value objects, and domain interfaces  
**Contains**:
- Entity definitions
- Value objects  
- Domain interfaces (repositories, services)
- Domain events
- Business rules and validation

### Presentation Layer
**Purpose**: UI components and presentation logic  
**Contains**:
- Widgets and UI components
- Presentation-specific state management
- UI event handling
- Screen/page definitions

## Naming Conventions

### Entity Files and Classes
**Template**: `{concept}_entity.dart` contains class `{Concept}Entity`

**Examples**:
- `app_layout_state_entity.dart` → `AppLayoutStateEntity`
- `contact_navigation_state_entity.dart` → `ContactNavigationStateEntity`  
- `message_search_result_entity.dart` → `MessageSearchResultEntity`

### Provider Files and Classes
**Template**: `{concept}_provider.dart` contains class `{Concept} extends _${Concept}` generating `{concept}Provider`

**Examples**:
- `app_layout_state_provider.dart` → `AppLayoutState extends _$AppLayoutState` → generates `appLayoutStateProvider`
- `import_service_provider.dart` → `ImportService` → generates `importServiceProvider`
- `contact_search_provider.dart` → `ContactSearch extends _$ContactSearch` → generates `contactSearchProvider`

**Generated Provider Naming**: Riverpod code generation creates camelCase provider names from PascalCase class names:
- `AppLayoutState` → `appLayoutStateProvider`
- `ContactNavigationState` → `contactNavigationStateProvider`

### Service Files and Classes
**Template**: `{concept}_service.dart` contains class `{Concept}Service`

**Examples**:
- `import_service.dart` → `ImportService`
- `message_extraction_service.dart` → `MessageExtractionService`
- `contact_sync_service.dart` → `ContactSyncService`

### Repository Files and Classes  
**Template**: `{entity}_repository.dart` contains interface, `{entity}_repository_impl.dart` contains implementation

**Examples**:
- `contact_repository.dart` → `abstract class ContactRepository`
- `contact_repository_impl.dart` → `class ContactRepositoryImpl implements ContactRepository`

### Database Files and Classes
**Template**: `{purpose}_db.dart` contains class `{Purpose}Database`

**Examples**:
- `import_db.dart` → `ImportDatabase`
- `drift_db.dart` → `DriftDatabase`  
- `cache_db.dart` → `CacheDatabase`

## Key Architecture Principles

### 1. Dependency Direction
- **Application** layer depends on **Domain** interfaces
- **Infrastructure** layer implements **Domain** interfaces  
- **Presentation** layer depends on **Application** services
- **Domain** layer has no dependencies on other layers

### 2. Provider Organization
- **Infrastructure providers**: Located with their respective data sources/repositories
- **Application providers**: Grouped in dedicated `application_providers/` folder
- **Presentation providers**: Co-located with UI components when UI-specific

### 3. Import Path Conventions
- Use relative imports within the same feature
- Use absolute imports for cross-feature dependencies
- Prefer `package:` imports for external dependencies

### 4. Business Logic Placement
- **Complex workflows**: Application services
- **Simple operations**: Domain entities or value objects
- **Data transformation**: Repository layer or dedicated transformer classes
- **UI logic**: Presentation layer only

## File Organization Examples

### Good Structure Example: Import Feature
```
lib/features/_import_and_dbs/
├── application/
│   ├── import/
│   │   ├── import_service.dart          # ✅ Business logic
│   │   └── import_result.dart           # ✅ Result DTOs
│   ├── application_providers/
│   │   └── import_service_provider.dart # ✅ Application providers
│   └── import_application_service.dart  # ✅ High-level orchestration
├── infrastructure/
│   ├── data_sources/local/import/
│   │   └── import_db.dart               # ✅ Database operations only
│   └── rust_extraction/
│       ├── rust_message_extractor.dart # ✅ External service integration
│       └── rust_extraction_provider.dart # ✅ Infrastructure provider
└── domain/
    └── i_repositories/
        └── repository_interface.dart    # ✅ Domain interfaces
```

### What NOT to do:
```
❌ infrastructure/import_service.dart     # Business logic in infrastructure
❌ application/database_operations.dart   # Database code in application  
❌ mixed_concerns_service.dart            # Multiple responsibilities in one file
```

## Performance Considerations

- **High-performance operations**: Keep in infrastructure layer (e.g., Rust integration)
- **Batch processing**: Coordinate in application layer, execute in infrastructure
- **Caching**: Implement in infrastructure, manage lifecycle in application

## Testing Strategy

- **Unit tests**: Focus on domain entities and application services
- **Integration tests**: Test infrastructure implementations  
- **Widget tests**: Test presentation layer components
- **Provider tests**: Test provider behavior and state management

---

*This document will be updated as the architecture evolves and new patterns are established.*
