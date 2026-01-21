# Feature Implementation Template (Per System)

Within a feature, system-specific logic lives in a dedicated application subtree.

Example for Contacts:

features/contacts/application/
  cassettes/
    spec_coordinators/
    spec_cases/
    spec_widget_builders/   (temporary name if legacy folders exist)
  onboarding/
    spec_coordinators/
    spec_cases/
    chain_link_builders/    (system-specific builders)
  tooltips/
    spec_coordinators/
    spec_cases/

---

## What belongs in each folder

spec_coordinators/
- pattern match on feature inner specs
- delegate immediately

spec_cases/
- repositories / data access
- business rules
- formatting
- error handling
- returns system payload models

builders/
- only assemble widgets or system payload pieces
- no data access, no meaning interpretation

---

## Feature keys for shared meaning (optional)

If multiple surfaces reuse the same meaning, define keys and resolvers:

ContactsInfoKey
InfoContentResolver.resolve(key)

Then each system consumes resolved meaning differently:

- sidebar info cassette uses the key to show an info card
- tooltip uses the same key to show a hover hint
- onboarding uses the same key as a step body (optionally)

Meaning is shared; machinery is not.