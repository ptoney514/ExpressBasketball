# Linear Session-Based Issue Management Philosophy

## Why Session-Based Issue Creation?

### The Problem with Real-Time Issue Creation
Creating Linear issues for every TODO, bug, or thought during development leads to:
- 🗑️ **Issue pollution** - Hundreds of minor issues that clutter your workspace
- 🔄 **Context switching** - Constantly updating Linear while trying to code
- 📝 **Duplicate work** - Recording the same information in multiple places
- 😵 **Cognitive overload** - Managing issues instead of solving problems
- ⏰ **Wasted time** - Creating/closing issues for things fixed in same session

### The Session-Based Approach
Create issues only at **natural boundaries**:
- 🏁 **Session end** - What needs to continue tomorrow?
- 💾 **Commit time** - What's incomplete in this commit?
- 🚨 **Blockers** - What's preventing progress?
- 📋 **Explicit requests** - When you specifically want tracking

---

## Core Principles

### 1. Linear is for Continuity, Not Documentation
```
❌ Wrong: Every TODO becomes a Linear issue
✅ Right: Only TODOs that affect next session become issues
```

### 2. PROJECT_STATUS.md is Your Scratchpad
```
During session → PROJECT_STATUS.md (temporary notes)
Between sessions → Linear (tracked work)
```

### 3. Commits Drive Issue Creation
```
If work is complete → Regular commit (no issue needed)
If work continues → Create issue, then commit with [PT-XXX]
```

### 4. Not Everything Needs Tracking
```
Fixed in same session → No issue needed
Spans multiple sessions → Create issue
Minor improvement idea → Code comment is enough
Major refactor needed → Create issue
```

---

## Practical Examples

### Example 1: Finding a Bug During Development

**Old Way (Excessive)**:
```
1. Find bug
2. Create Linear issue immediately
3. Fix bug
4. Update Linear to "Done"
5. Close issue
Result: Unnecessary overhead for 5-minute fix
```

**New Way (Efficient)**:
```
1. Find bug
2. Fix bug
3. Commit the fix
Result: Bug fixed, no unnecessary tracking
```

**New Way (If Can't Fix Now)**:
```
1. Find bug
2. Try to fix for 10 minutes
3. Can't fix quickly
4. At session end: Create Linear issue
5. Next session: Continue with issue reference
Result: Only tracked because it spans sessions
```

### Example 2: TODO Comments in Code

**Old Way (Excessive)**:
```javascript
// TODO: Optimize this function - CREATES LINEAR ISSUE
// TODO: Add type checking - CREATES LINEAR ISSUE  
// TODO: Consider caching - CREATES LINEAR ISSUE
Result: 3 Linear issues for minor improvements
```

**New Way (Efficient)**:
```javascript
// TODO: Optimize this function - stays as comment
// TODO: Add type checking - stays as comment
// TODO: Consider caching - stays as comment

At commit: "Are any of these blocking or urgent?"
If no: Leave as comments
If yes: Create ONE issue for critical improvements
```

### Example 3: Feature Development

**Working on Feature (Session 1)**:
```
Morning: Start feature
PROJECT_STATUS.md: "Working on user auth"
Afternoon: 60% complete
End of day: Create Linear issue PT-123 "Complete user auth"
Commit: [PT-123] wip: Initial auth implementation
```

**Continuing Feature (Session 2)**:
```
Morning: Check Linear, see PT-123
Branch: Already on feature/PT-123-user-auth
Work: Complete the feature
Commit: [PT-123] feat: Complete user authentication
Linear: Update PT-123 to Done
```

---

## Quick Decision Tree

```
Found something that needs work
            ↓
    Can I fix it now?
       /        \
     YES         NO
      ↓           ↓
   Fix it    Will I work on it
     ↓        next session?
   Commit        /    \
   (no issue)  YES     NO
                ↓       ↓
          Create issue  Add TODO comment
          at session end  (no issue)
```

---

## Session Patterns

### Morning Start
```bash
# Check what you were working on
"Any Linear issues assigned to me?"

# If continuing work
git checkout feature/PT-XXX-description

# If starting fresh
Just start coding (no issue needed yet)
```

### During the Day
```bash
# Keep notes locally
echo "Fixed auth bug" >> PROJECT_STATUS.md
echo "Still need to add validation" >> PROJECT_STATUS.md

# Only create Linear issue if blocked
"Create Linear issue: Blocked by API changes"
```

### End of Day
```bash
# Review what needs to continue
"What did I not finish today?"

# Create issues only for continuing work
"Create issue: Complete user validation (partially done today)"

# Commit with reference if work continues
git commit -m "[PT-124] wip: Partial validation implementation"
```

---

## Benefits of This Approach

### For You
- 🎯 **Focused work** - Less interruption from issue management
- 🧹 **Clean Linear workspace** - Only meaningful issues
- ⏱️ **Time saved** - No managing trivial issues
- 📊 **Better metrics** - Issues represent real work units

### For Your Team (If Applicable)
- 👀 **Clear visibility** - Every issue matters
- 📈 **Accurate velocity** - Not inflated by micro-issues
- 🎨 **Clean backlog** - No noise from fixed TODOs

### For Your 20+ Projects
- 🗂️ **Manageable scale** - 10 real issues vs 100 micro-issues per project
- 🔍 **Easy filtering** - Every issue is significant
- 📋 **True priorities** - Not buried in trivial items
- 🚀 **Quick decisions** - "What's actually important?"

---

## Anti-Patterns to Avoid

### ❌ Don't Do This:
- Create issue for every TODO found
- Update Linear after every small change
- Create issues for "might be nice" ideas
- Track 10-minute tasks in Linear
- Create issues then immediately close them

### ✅ Do This Instead:
- Create issues for multi-session work
- Update Linear at natural boundaries
- Keep ideas in code comments
- Fix small things without tracking
- Only track what needs continuity

---

## The One Question That Matters

Before creating any Linear issue, ask:

> **"Will I need to remember this for my next work session?"**

- If YES → Create Linear issue
- If NO → Don't create issue

That's it. That's the whole philosophy.

---

## Customization for Your Workflow

Feel free to adjust these triggers based on your needs:

### Minimal Tracking (Even Less)
- Only create issues for work spanning weeks
- Only track blockers and major features
- Use PROJECT_STATUS.md for everything else

### Moderate Tracking (Recommended)
- Create issues for next-session work
- Track incomplete commits
- Major bugs and features

### Detailed Tracking (If Needed)
- Create issues for next-day work
- Track all incomplete features
- Include important refactoring

---

Remember: **Linear is your assistant, not your boss.** It should help you remember what to work on next, not document every thought you have while coding.