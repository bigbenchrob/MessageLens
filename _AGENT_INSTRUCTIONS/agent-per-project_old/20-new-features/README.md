# Feature Development In Progress

This folder contains active feature development work. Each feature folder represents a feature in various stages of development following the systematic workflow documented in `agent-instructions-shared/50-ai-workflow/feature-development-workflow.md`.

## Workflow Overview

When a new feature is proposed:
1. **Proposal**: Create folder with `PROPOSAL.md`
2. **Planning**: Add `CHECKLIST.md`, `DESIGN_NOTES.md`, `TESTS.md`
3. **Implementation**: Update checklist as tasks complete
4. **Testing**: Validate all tests pass
5. **Documentation**: Create documentation in `10-features/{feature-name}/`
6. **Completion**: Mark as complete with `STATUS.md`

## Active Features

### 🚧 In Development
{No active features currently}

### ✅ Recently Completed
{No completed features yet}

## Starting a New Feature

When the user requests a new feature, the agent will:
1. Create a new folder: `20-new-features/{feature-name}/`
2. Generate `PROPOSAL.md` using the template from `agent-instructions-shared/90-templates/`
3. Wait for user approval before proceeding to planning
4. Create comprehensive development checklist and planning documents
5. Track progress through the checklist as implementation proceeds

## Feature Folder Structure

Each feature folder contains:
```
{feature-name}/
├── PROPOSAL.md           # Feature proposal and scope
├── CHECKLIST.md          # Development task tracking (updated live)
├── DESIGN_NOTES.md       # Technical decisions and architecture notes
├── TESTS.md              # Test strategy and results
└── STATUS.md             # Completion summary (added when done)
```

## Completion Process

When a feature is complete:
1. All checklist items marked `[x]`
2. All tests passing
3. Documentation created in `10-features/{feature-name}/`
4. `STATUS.md` created with:
   - Completion date
   - Final test results
   - Link to documentation
   - Lessons learned

## Related Documentation

- **Workflow Guide**: `_AGENT_INSTRUCTIONS/agent-instructions-shared/50-ai-workflow/feature-development-workflow.md`
- **Proposal Template**: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/feature-proposal-template.md`
- **Checklist Template**: `_AGENT_INSTRUCTIONS/agent-instructions-shared/90-templates/feature-checklist-template.md`
- **Completed Features**: `_AGENT_INSTRUCTIONS/agent-per-project/10-features/`

---

*This folder follows the systematic feature development workflow designed to ensure quality, trackability, and proper documentation.*
