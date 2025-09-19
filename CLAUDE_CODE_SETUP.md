# Claude Code Project Setup Guide

## How to Set Up a Project for Optimal Claude Code Collaboration

This guide explains how to structure your project for the best possible experience with Claude Code, based on the successful patterns from the Express Basketball project.

---

## Essential Files for Claude Code Projects

### 1. CLAUDE.md - Project Instructions
**Purpose**: Stable architectural guidance that Claude Code reads first in every conversation.

#### Structure:
```markdown
# CLAUDE.md

## Project Type
[Brief description of what you're building]

## Project Vision & Goals
- Mission statement
- Core principles
- Current priorities

## Project Structure
```
project-root/
├── key-folders/
└── explained-here/
```

## Architecture Overview
- Technology stack
- Key decisions made
- Architecture patterns

## Development Commands
```bash
# Most important commands Claude should know
npm run dev
npm test
```

## Important Context
- Business rules
- Design decisions
- What NOT to do

## Current Focus
[What you're working on now]
```

#### Best Practices:
- Keep it under 500 lines
- Update monthly, not daily
- Include "what NOT to do" sections
- Add example commands
- Explain architectural decisions

---

### 2. PROJECT_STATUS.md - Living Status Document
**Purpose**: Current state of the project, updated frequently.

#### Structure:
```markdown
# Project Status

## Last Updated: [Date]

## Current Sprint/Phase
[What phase or sprint you're in]

## Completed Features ✅
- Feature 1 with brief description
- Feature 2 with brief description

## In Progress 🚧
- [ ] Current task 1
  - Subtask details
  - Blockers or issues
- [ ] Current task 2

## Pending/Backlog 📋
- Future feature 1
- Future feature 2

## Known Issues 🐛
- Issue 1: Description and impact
- Issue 2: Description and impact

## Recent Decisions 📝
- Decision 1: What and why
- Decision 2: What and why

## Next Session Goals
1. Specific goal 1
2. Specific goal 2
3. Specific goal 3
```

#### Best Practices:
- Update at start/end of each session
- Be specific about blockers
- Include error messages
- Track decisions made
- Set clear next session goals

---

### 3. WORKFLOW_GUIDE.md - Development Workflow
**Purpose**: Standard procedures for common tasks.

#### Structure:
```markdown
# Workflow Guide

## Development Workflow

### Starting a New Feature
1. Update PROJECT_STATUS.md with goal
2. Create feature branch (if using git)
3. Write tests first (if doing TDD)
4. Implement feature
5. Test locally
6. Update documentation

### Testing Checklist
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Edge cases considered

### Deployment Process
1. Step-by-step deployment
2. Environment-specific notes
3. Rollback procedure

### Common Tasks

#### Adding a New Component
```bash
# Commands to scaffold
# File naming conventions
# Where files should go
```

#### Debugging Issues
1. Check logs here: [location]
2. Common issues and fixes
3. Who to contact for help

## Code Standards

### Naming Conventions
- Components: PascalCase
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE

### File Organization
```
feature/
├── components/
├── hooks/
├── utils/
└── tests/
```

### Git Commit Messages
- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code refactoring
- test: Test updates
```

---

### 4. TECHNICAL_DEBT.md - Track Technical Compromises
**Purpose**: Document shortcuts taken and future improvements needed.

#### Structure:
```markdown
# Technical Debt Register

## High Priority (Address Soon)
- **Issue**: Description
  - **Impact**: Why it matters
  - **Solution**: How to fix
  - **Estimate**: Time needed

## Medium Priority
- Items that should be fixed but aren't blocking

## Low Priority
- Nice-to-have improvements

## Accepted Debt
- Things we've decided to live with and why
```

---

### 5. ERROR_LOG.md - Learn from Mistakes
**Purpose**: Document errors encountered and their solutions.

#### Structure:
```markdown
# Error Log

## [Date] - Error Title
**Error**: Full error message
**Context**: What you were trying to do
**Solution**: How you fixed it
**Prevention**: How to avoid in future

## Common Errors
### Error Pattern 1
- Symptoms
- Root cause
- Quick fix
- Proper fix
```

---

## Project Structure Best Practices

### Recommended Folder Structure
```
project-root/
├── CLAUDE.md                 # Core instructions (always)
├── PROJECT_STATUS.md         # Current status (always)
├── WORKFLOW_GUIDE.md         # How-to guide (always)
├── TECHNICAL_DEBT.md        # If applicable
├── ERROR_LOG.md             # If debugging often
├── docs/                    # Detailed documentation
│   ├── architecture/        # Diagrams, decisions
│   ├── api/                # API documentation
│   └── guides/             # User guides
├── scripts/                 # Automation scripts
│   ├── setup.sh            # Initial setup
│   ├── test.sh             # Test runner
│   └── deploy.sh           # Deployment
└── [your-app-code]/        # Actual application
```

---

## Session Management Tips

### Starting a Session with Claude Code

#### First Message Template:
```
Hi Claude, I'm working on [project name].

Current focus: [what you're working on]

Please check PROJECT_STATUS.md for current status.

Today's goal: [specific objective]

Any issues from last session: [problems to solve]
```

### Ending a Session

#### Last Message Template:
```
Let's wrap up. Please:
1. Summarize what we accomplished
2. Note any pending issues
3. Suggest next steps
4. Update PROJECT_STATUS.md if needed
```

---

## Pro Tips for Claude Code Collaboration

### 1. Use Clear File References
```markdown
Bad: "Update the config"
Good: "Update /src/config/app.config.js"
```

### 2. Provide Context with Errors
```markdown
Bad: "It's not working"
Good: "When I run 'npm start', I get error: [full error message]"
```

### 3. Be Specific About Expectations
```markdown
Bad: "Make it better"
Good: "Refactor to improve performance, specifically the data fetching in UserList component"
```

### 4. Use Code Blocks for Clarity
````markdown
When sharing code, always use triple backticks:
```javascript
const example = "like this";
```
````

### 5. Regular Checkpoints
- After major features
- Before refactoring
- When switching context
- At end of session

---

## Advanced Features

### Custom Instructions in CLAUDE.md

#### Example: Specific Libraries
```markdown
## Required Libraries
ALWAYS use these libraries:
- UI: shadcn/ui (not Material-UI)
- State: Zustand (not Redux)
- Forms: react-hook-form (not Formik)
```

#### Example: Coding Style
```markdown
## Coding Standards
- Prefer async/await over .then()
- Use functional components only
- Write tests for all utils
- Comment complex logic
```

#### Example: Security Rules
```markdown
## Security Requirements
- Never commit .env files
- Always validate user input
- Use parameterized queries
- Hash passwords with bcrypt
```

---

## Multi-Platform Project Setup

### For Projects with Multiple Apps (like Express Basketball)

```
workspace-root/
├── CLAUDE.md                    # Workspace overview
├── PROJECT_PLAN.md             # Strategic plan
├── TECHNICAL_SPECIFICATION.md  # Tech details
├── app1/
│   ├── CLAUDE.md               # App-specific instructions
│   └── PROJECT_STATUS.md       # App-specific status
├── app2/
│   ├── CLAUDE.md
│   └── PROJECT_STATUS.md
└── shared/
    └── CLAUDE.md               # Shared code instructions
```

---

## Maintenance Schedule

### Daily
- Update PROJECT_STATUS.md "In Progress" section
- Add new errors to ERROR_LOG.md

### Weekly
- Review and update PROJECT_STATUS.md fully
- Clean up completed tasks
- Update TECHNICAL_DEBT.md

### Monthly
- Review CLAUDE.md for accuracy
- Archive old status updates
- Refactor WORKFLOW_GUIDE.md based on learnings

---

## Example: Minimal Starting Setup

### For a New React Project:

#### CLAUDE.md
```markdown
# Project Name

## Project Type
React web application with TypeScript

## Tech Stack
- React 18
- TypeScript
- Vite
- Tailwind CSS

## Development Commands
```bash
npm run dev      # Start dev server
npm run build    # Build for production
npm test         # Run tests
```

## Project Structure
```
src/
├── components/  # Reusable components
├── pages/      # Page components
├── hooks/      # Custom hooks
└── utils/      # Helper functions
```

## Key Decisions
- Using Vite instead of CRA for speed
- Tailwind for styling (no CSS modules)
- Function components only (no class components)

## Current Focus
Building the initial UI components
```

#### PROJECT_STATUS.md
```markdown
# Project Status

## Last Updated: [Date]

## Completed ✅
- Project setup
- Basic routing

## In Progress 🚧
- [ ] Home page design
- [ ] Navigation component

## Next Up 📋
- User authentication
- API integration
```

#### WORKFLOW_GUIDE.md
```markdown
# Workflow Guide

## New Component
1. Create in src/components/ComponentName/
2. Include ComponentName.tsx and index.ts
3. Write tests in ComponentName.test.tsx

## Testing
```bash
npm test                 # Run all tests
npm test ComponentName   # Run specific test
```

## Build & Deploy
```bash
npm run build           # Creates dist/
npm run preview         # Preview build locally
```
```

---

## Success Metrics

Your project setup is successful when:
- ✅ Claude Code can understand project context immediately
- ✅ You spend less time explaining, more time building
- ✅ Errors are solved faster with ERROR_LOG.md
- ✅ New features follow consistent patterns
- ✅ You can resume work after breaks seamlessly
- ✅ Handoff to other developers is smooth

---

## Troubleshooting Setup Issues

### Common Problems:

#### 1. Claude Code seems confused
- Check if CLAUDE.md is clear and concise
- Ensure file paths are correct
- Update PROJECT_STATUS.md

#### 2. Repetitive questions from Claude
- Add the information to CLAUDE.md
- Create a FAQ section

#### 3. Inconsistent code style
- Add specific examples to WORKFLOW_GUIDE.md
- Include code formatting rules

#### 4. Lost context between sessions
- Better session notes in PROJECT_STATUS.md
- Use "Next Session Goals" section

---

## Final Tips

1. **Start Simple**: Don't create all files at once. Start with CLAUDE.md and PROJECT_STATUS.md
2. **Evolve Naturally**: Add other files as needs arise
3. **Be Consistent**: Update regularly, even if briefly
4. **Stay Organized**: Good structure saves time
5. **Document Decisions**: Future you will thank present you

---

*This guide is based on successful patterns from the Express Basketball project and other Claude Code collaborations.*

*Remember: The best documentation is the one that gets used and updated!*