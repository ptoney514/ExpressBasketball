# Linear Session-Based Quick Reference Card

## 🎯 The Golden Rule
**Only create Linear issues for work that continues into the next session**

---

## ⚡ Quick Commands

### Session Start
```
"What Linear issues do I have for this project?"
"Any in-progress work to continue?"
```

### During Work
```
"Note this" → Goes to PROJECT_STATUS.md (not Linear)
"Fixed bug" → Just commit it (no issue needed)
"Can't fix this now" → Note for session end
```

### Before Commit
```
Work complete? → Normal commit
Work continues? → Create issue → Commit with [PT-XXX]
```

### Session End
```
"What needs a Linear issue for tomorrow?"
"Create issue for [unfinished work only]"
```

---

## 📝 What Gets an Issue vs What Doesn't

| Situation | Linear Issue? | Why |
|-----------|--------------|-----|
| Bug fixed in 10 minutes | ❌ No | Fixed same session |
| Bug needs investigation tomorrow | ✅ Yes | Spans sessions |
| TODO in code | ❌ No | Just a comment |
| Feature 50% done at day end | ✅ Yes | Continues tomorrow |
| Typo fixed | ❌ No | Immediate fix |
| Major refactor needed | ✅ Yes | Planned work |
| "Would be nice" idea | ❌ No | Not planned |
| Blocked by external team | ✅ Yes | Needs tracking |

---

## 🔄 Daily Flow

```
Morning:
├── Check Linear for assigned issues
├── If continuing → checkout feature/PT-XXX branch
└── If new work → just start coding

During Day:
├── Work normally
├── Keep notes in PROJECT_STATUS.md
└── Only create issues if blocked

Evening:
├── Review incomplete work
├── Create issues ONLY for tomorrow's work
├── Commit with [PT-XXX] if continuing
└── Clear PROJECT_STATUS.md of completed items
```

---

## 💬 Git Commits

### With Linear Issue (continuing work):
```bash
git commit -m "[PT-123] wip: Partial auth implementation"
git commit -m "[PT-123] feat: Complete user authentication"
git commit -m "[PT-123] fix: Resolve session timeout"
```

### Without Linear Issue (completed work):
```bash
git commit -m "feat: Add logging utility"
git commit -m "fix: Correct typo in error message"
git commit -m "docs: Update README"
```

---

## 🚫 Common Mistakes to Avoid

1. **Creating issues for everything** → Only for session continuity
2. **Tracking completed work** → No issue needed if done
3. **Issues for TODOs** → Leave as code comments
4. **Updating Linear constantly** → Only at session boundaries
5. **Issues for "someday" ideas** → Not unless planned

---

## ✅ Correct Patterns

1. **Incomplete at day end** → Create issue
2. **Blocked work** → Create issue
3. **Multi-day feature** → Create issue once, reference in commits
4. **Quick fix** → Just fix and commit
5. **Future idea** → Code comment, not issue

---

## 🎨 Labels to Always Include

Every Linear issue needs:
- `project:[name]` - Which project
- Priority label - How urgent
- Type label - Bug/Feature/Tech-debt
- Component label - What area (if applicable)

---

## 📊 Decision Matrix

```
┌─────────────────────────────────────┐
│ Will I work on this next session?   │
├─────────────────────────────────────┤
│ YES → Create Linear Issue           │
│ NO  → Don't Create Linear Issue     │
└─────────────────────────────────────┘
```

That's literally it. One question, one decision.

---

## 🔗 Useful Aliases

Add to your shell profile:

```bash
# Check my issues
alias my-issues="echo 'Ask Claude: Show my Linear issues'"

# Commit with Linear reference
alias gcommit-linear='git commit -m "[PT-$1] $2: $3"'
# Usage: gcommit-linear 123 feat "Add user auth"

# Session end reminder
alias end-session="echo 'Ask Claude: What needs Linear issues for tomorrow?'"
```

---

## 📌 Remember

**Linear tracks work continuity, not work history**

- PROJECT_STATUS.md = Today's notepad
- Linear = Tomorrow's todo list
- Code comments = Someday ideas

Keep it simple. Keep it useful. Don't over-track.