# TL;DR — Cross-Surface Spec Systems (For Agents)

- Do not cram tooltips/onboarding into cassette flow.
- Each surface/system has its own essentials module.

Essentials/<system> owns:
- system state + coordinator + payload models
- outer routing spec: <System>Spec.<feature>(innerSpec)
- NO feature subfolders
- NO inner spec interpretation

Features own:
- inner spec unions (e.g. ContactsOnboardingSpec)
- keys/enums/constants for meaning
- spec_coordinators (routing only)
- spec_cases (logic + data)
- builders (assembly only)

Routing rule:
- system coordinator switches only on outer spec variant to pick the feature
- feature coordinator switches on inner spec variants to decide meaning