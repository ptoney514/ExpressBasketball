# Linear Configuration - Session-Based Approach

## 🎯 Core Philosophy
**Linear tracks work CONTINUITY, not work HISTORY**

## 📋 Team & Project Settings
- **Team**: PERNELL
- **Project Label**: `project:express-basketball`
- **Default Assignee**: Auto-assign to creator
- **Issue Prefix**: EB (ExpressBasketball)

## 🚦 When to Create Linear Issues

### ✅ CREATE Issues For:
1. **Work spanning multiple sessions**
   - Features you can't complete today
   - Bugs requiring investigation across sessions
   - Refactoring that takes multiple days

2. **Blockers & Dependencies**
   - Waiting on external input
   - API/service dependencies
   - Design decisions needed

3. **Handoff Points**
   - Work for other team members
   - Features needing review
   - Documentation requirements

### ❌ DON'T Create Issues For:
1. **Same-session work**
   - Quick bug fixes (< 1 hour)
   - Minor refactoring
   - Code cleanup
   - Comment additions

2. **Micro-tasks**
   - Typo fixes
   - Import adjustments
   - Variable renaming
   - Formatting changes

3. **Completed work**
   - Already fixed bugs
   - Implemented features
   - Resolved TODOs

## 📝 Daily Workflow

### Morning
```
Check: "What Linear issues are assigned to me?"
→ Continue existing work OR start fresh
→ Update PROJECT_STATUS.md with today's plan
```

### During Development
```
Find bug → Fix it → Commit (no issue)
Find TODO → Add code comment (no issue)
Can't finish → Note in PROJECT_STATUS.md
Hit blocker → Create Linear issue (if multi-session)
```

### End of Session
```
Review: "What needs a Linear issue for tomorrow?"
→ Create issues ONLY for continuing work
→ Update PROJECT_STATUS.md
→ Commit with [EB-XXX] references
```

## 🏷️ Label System

### Priority Labels
- `priority:urgent` - Blocking development
- `priority:high` - Next session priority
- `priority:medium` - This week
- `priority:low` - Backlog

### Type Labels
- `bug` - Defects and issues
- `feature` - New functionality
- `tech-debt` - Refactoring/cleanup
- `documentation` - Docs needed

### Component Labels (ExpressBasketball Specific)
- `component:coach-app` - ExpressCoach iOS app
- `component:parent-app` - ExpressUnited iOS app
- `component:backend` - Supabase/API
- `component:shared` - ExpressBasketballCore

## 🔗 Git Integration

### Commit Message Format
```
feat: Add roster management to coach app [EB-123]
fix: Resolve SwiftData sync issue [EB-124]
```

### Branch Naming
```
feature/EB-123-roster-management
bugfix/EB-124-swiftdata-sync
```

## 📊 The One Rule

Before creating any Linear issue, ask:
> **"Will I need to remember this for my next work session?"**

- YES → Create Linear issue
- NO → Use PROJECT_STATUS.md or code comments

## 🎯 ExpressBasketball Specific Guidelines

### Current Focus Areas
1. **ExpressCoach App** - Staff management features
2. **ExpressUnited App** - Parent viewing features
3. **Supabase Integration** - Backend setup
4. **SwiftData Models** - Local persistence

### Issue Templates

#### Feature Template
```
Title: [Component] Feature description
Description:
- User story
- Acceptance criteria
- Technical notes
Labels: feature, component:x, priority:x
```

#### Bug Template
```
Title: [Component] Bug description
Description:
- Steps to reproduce
- Expected vs actual
- Environment details
Labels: bug, component:x, priority:x
```

## 📈 Success Metrics

You're doing it right when:
- ✅ < 10 open issues per project
- ✅ Every issue represents multi-session work
- ✅ PROJECT_STATUS.md is your daily companion
- ✅ Linear issues have clear handoff value
- ✅ More coding, less issue management

## 🚀 Quick Commands

### Check assigned issues
```
"Show my Linear issues for express-basketball"
```

### Create continuation issue
```
"Create Linear issue: Continue SwiftData sync implementation"
```

### Update issue status
```
"Move EB-123 to In Progress"
```

---

*Remember: Linear is for CONTINUITY, not HISTORY. Most work doesn't need an issue.*