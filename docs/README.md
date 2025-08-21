# UFOBeep Documentation Guide

## How to Use These Docs

### 📋 For Daily Development
- **QUICKSTART.md** - Your go-to reference for commands and URLs
- **ENDPOINTS.md** - API reference when adding/modifying endpoints
- **DEPLOYMENT.md** - How to deploy changes to production

### 🎯 For Planning
- **MASTER_PLAN_v13.md** - Current roadmap and feature list (living document)
  - Update when: Adding major features, changing architecture

### 🔧 For Process
- **CONTRIBUTING.md** - Git workflow and PR process
- **CI.md** - Understanding GitHub Actions and CI/CD

## When to Update Each Doc

| Document | Update When | Example |
|----------|------------|---------|
| **ENDPOINTS.md** | Adding/changing API endpoints | New `/alerts/{id}/witness` endpoint |
| **DEPLOYMENT.md** | Changing deployment process | New service, new server, new script |
| **MASTER_PLAN_v13.md** | Major feature decisions | Adding AI detection, changing architecture |
| **QUICKSTART.md** | New dev setup steps | New dependency, new test device |
| **CI.md** | Modifying GitHub workflows | Adding new test suite |
| **CONTRIBUTING.md** | Changing team process | New branch naming, new review rules |

## Quick Update Commands

```bash
# After adding new API endpoint
# Update: ENDPOINTS.md

# After changing deployment
# Update: DEPLOYMENT.md, QUICKSTART.md

# After major feature work  
# Update: MASTER_PLAN_v13.md, ENDPOINTS.md

# After modifying workflows
# Update: CI.md
```

## Keep Docs in Sync

When making changes:
1. **Code first** - Implement the feature
2. **Docs second** - Update relevant documentation
3. **Deploy third** - Push to production

## Archive Old Docs
Move outdated docs to `/docs/archive/` instead of deleting.