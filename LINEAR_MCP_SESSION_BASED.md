# Linear MCP Setup Guide - Session & Commit Based

*A balanced approach to Linear integration that creates issues only when committing code or ending sessions*

---

## Copy and paste this entire message into Claude Code:

---

Hi Claude! I have Linear MCP configured. Let's set up Linear integration for session handoffs and commit tracking.

## Phase 1: Setup Project Structure

### 1. Create LINEAR_CONFIG.md
```markdown
# LINEAR_CONFIG.md - Linear MCP Integration

## Project Identification
- **Team Name**: [Check Linear for my teams and confirm with me]
- **Project Label**: `project:[infer from folder/package name]`
- **Default Assignee**: me

## Issue Creation Policy
- Create issues ONLY when:
  - Committing code with unfinished work
  - Ending a session with pending tasks
  - Explicitly requested by me
  - Major bugs that block progress
- DO NOT create issues for:
  - Every TODO comment found
  - Minor refactoring needs
  - Small bugs fixed in same session

## Git Integration
- Branch: feature/PT-XXX-description
- Commit: [PT-XXX] type: message
- Create issues for work continuing to next session

## Session Handoff
- At session end: Create issues for incomplete work
- At session start: Check existing assigned issues
- Keep PROJECT_STATUS.md as temporary notes
```

### 2. Update CLAUDE.md
Add this section:
```markdown
## Linear Integration (MCP Enabled)
- Linear MCP configured for issue management
- See LINEAR_CONFIG.md for project configuration
- Issues created at commit time and session end
- Every commit references [PT-XXX] if related to issue
- PROJECT_STATUS.md for in-session notes
```

### 3. Update PROJECT_STATUS.md
Add this minimal Linear section:
```markdown
## Linear Issues 🔗
### Current Issue
- Working on: [PT-XXX] - [Title] (if any)
- Branch: `feature/PT-XXX-description`

### To Create at Commit/Session End
- [ ] Items that need follow-up
- [ ] Bugs not fixed this session
- [ ] Features partially complete
```

---

## Phase 2: Check Existing Linear State

Please check my Linear workspace:

1. **Verify team and existing issues**:
   ```
   Linear:list_teams
   Linear:list_issues assignee:me state:"In Progress"
   Linear:list_issues label:"project:[this-project-name]"
   ```

2. **Check if I'm already working on something**:
   ```
   Linear:list_issues assignee:me state:"In Progress" label:"project:[this-project-name]"
   ```

---

## Phase 3: Lightweight Project Scan

Please do a quick scan (but DON'T create issues yet):

1. **Check for existing tracking files**:
   - Does CLAUDE.md exist?
   - Does PROJECT_STATUS.md exist?
   - Does LINEAR_CONFIG.md already exist?
   - Any .gitmessage template?

2. **Note (but don't create issues for)**:
   - Number of TODO/FIXME comments found
   - Any ERROR_LOG.md entries
   - TECHNICAL_DEBT.md items
   
3. **Report findings** without creating issues:
   ```
   Found:
   - X TODO comments (will create issues if still relevant at commit)
   - Y items in technical debt (track if they affect current work)
   - Z incomplete features (create issues only if stopping work on them)
   ```

---

## Phase 4: Establish Commit Workflows

Create/update WORKFLOW_GUIDE.md with:

```markdown
## Linear Commit Workflow

### Starting Work (No Automatic Issues)
1. Check for existing assigned issues:
   Ask: "Do I have any Linear issues for this project?"
2. If yes, checkout branch: `git checkout -b feature/PT-XXX-description`
3. If no, just start working (create issue later if needed)

### During Development (No Automatic Issues)
- Keep notes in PROJECT_STATUS.md
- Don't create Linear issues for every TODO
- Only create issue if it's blocking or critical

### At Commit Time
For unfinished work being committed:
1. Create Linear issue for work to continue next session
2. Reference in commit: `[PT-XXX] wip: Partial implementation of feature`

For completed work:
- If has issue: `[PT-XXX] feat: Completed feature`
- If no issue: Regular commit (no Linear reference needed)

### Session End Checklist
Ask Claude: "What needs Linear issues for next session?"
- [ ] Incomplete features → Create issue
- [ ] Bugs not fixed → Create issue  
- [ ] Important refactoring → Create issue
- [ ] Skip minor TODOs that can wait

### What DOESN'T Need an Issue
- Code comments for future nice-to-haves
- Minor refactoring ideas
- Small bugs fixed in same session
- Documentation updates completed
- TODOs that aren't blocking anything
```

---

## Phase 5: Git Configuration

Set up git for Linear integration:

```bash
# Only create commit template if working on Linear issue
echo "[PT-XXX] type: " > .gitmessage.linear

# Alias for Linear commits
git config alias.linear-commit '!f() { git commit -m "[PT-$1] $2: $3"; }; f'
# Usage: git linear-commit 123 feat "Add user auth"
```

---

## Phase 6: Session Commands

### Daily Commands to Remember

#### Session Start
```
"What Linear issues are assigned to me for this project?"
"Is there an in-progress issue I should continue?"
```

#### During Work (Minimal Linear Usage)
```
"Note this for later" → Goes in PROJECT_STATUS.md, not Linear
"Found a bug" → Fix it if possible, only create issue if can't fix now
```

#### Before Committing
```
"Is this work complete?" 
- If YES → Normal commit
- If NO → Create Linear issue first, then commit with [PT-XXX]
```

#### Session End
```
"What unfinished work needs a Linear issue for next time?"
"Create issues only for work I'll continue next session"
```

---

## Phase 7: Final Setup Report

Please provide this summary:

### Configuration Summary
1. **Linear Setup**:
   - Team: [confirmed team name]
   - Project label: `project:[name]`
   - Existing issues: [count]

2. **Files Created/Updated**:
   - [ ] LINEAR_CONFIG.md created
   - [ ] CLAUDE.md updated with Linear section
   - [ ] PROJECT_STATUS.md updated with minimal Linear section
   - [ ] WORKFLOW_GUIDE.md updated with commit workflows

3. **Project Status**:
   - TODO comments found: X (no issues created yet)
   - Currently assigned issues: [list if any]
   - Suggested branch name if continuing existing issue

### Questions for You
- Any existing Linear issue you want to continue?
- Any critical bugs that need immediate Linear issues?
- Preferred commit style: [PT-XXX] or just PT-XXX?

---

## Key Principles Going Forward

### ✅ DO Create Linear Issues For:
- Work that spans multiple sessions
- Bugs you're stopping work on
- Features you're committing incomplete
- Tasks you want to remember for tomorrow
- Anything you explicitly ask for

### ❌ DON'T Create Linear Issues For:
- Every TODO comment in code
- Small fixes done in same session
- Ideas that might be nice someday
- Refactoring that's not planned
- Documentation typos fixed immediately

### 📝 Use PROJECT_STATUS.md For:
- Temporary session notes
- Things you're actively working on
- Quick reminders that don't need tracking
- Work completed this session

### 🎯 Use Linear For:
- Work spanning multiple sessions
- Team visibility on progress
- Bugs that need tracking
- Feature planning
- Commit references for incomplete work

---

## Remember: Less is More

The goal is to track what matters for **session continuity**, not every single thought or TODO. Linear issues should represent **work that needs to continue** into the next session, not a comprehensive list of everything that could possibly be improved.

Let's set up your streamlined Linear integration!