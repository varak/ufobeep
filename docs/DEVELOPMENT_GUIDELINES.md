# Development Guidelines

## Critical Rules to Prevent API Inconsistencies

### Before Adding New Endpoints

**Step 1: Check Existing Endpoints**
```bash
# Search for similar functionality
grep -r "GET.*beep" api/app/routers/
grep -r "endpoint_name" docs/ENDPOINTS.md
```

**Step 2: Verify Response Format**
- Use `enrichment_data` (NOT `enrichment`)
- Follow existing structure patterns
- Test with both MUFON and UFOBeep data

**Step 3: Update Documentation**
- Add to `docs/ENDPOINTS.md`
- Document purpose and usage
- Mark any structural differences

### Known Technical Debt

#### Duplicate Beep Lookup Endpoints
**Problem**: Two endpoints return same data with different structures
- `GET /api/beep/{id}` - Flat structure, used by web pages
- `GET /api/beep/by-short-url/{id}` - Nested structure, used by middleware

**Impact**: Frontend components break when switching endpoints
**Status**: Documented, data format standardized, structural fix deferred

**DO NOT CREATE MORE BEEP ENDPOINTS** until this is resolved.

### Common Mistakes to Avoid

#### ❌ Creating Endpoint Variants
```python
# BAD - Creates third variant
@router.get("/beep/details/{id}")
@router.get("/beep/lookup/{id}")
@router.get("/beep/fetch/{id}")
```

#### ❌ Inconsistent Response Formats
```python
# BAD - Different field names
return {"enrichment": data}      # Some endpoints
return {"enrichment_data": data} # Other endpoints
```

#### ❌ Different Nesting Levels
```python
# BAD - Inconsistent nesting
return {"data": alert_data}           # Flat
return {"data": {"alert": alert_data}} # Nested
```

### Correct Patterns

#### ✅ Extend Existing Endpoints
```python
# GOOD - Add query parameters to existing endpoint
@router.get("/beep")
async def get_alerts(limit: int = 20, include_media: bool = False):
```

#### ✅ Consistent Response Format
```python
# GOOD - Standard format
return {
    "success": True,
    "data": {
        "enrichment_data": enrichment,  # NOT "enrichment"
        "source": "mufon",
        # ... other fields
    }
}
```

### Translation System

#### Required for New Features
- Add English keys to `web/public/locales/en/common.json`
- Run `translate.sh` to generate all languages
- Use `t('translationKey')` in components, never hardcode text

#### Shape Classification Translations
All MUFON shapes must have `mufon{Shape}` translation keys:
- `mufonDisc: "Disc"`
- `mufonTriangle: "Triangle"`
- `mufonSphere: "Sphere"`
- etc.

### Code Review Checklist

- [ ] No duplicate endpoints created
- [ ] Response format matches existing patterns
- [ ] All text uses translation keys
- [ ] Documentation updated
- [ ] Tested with both MUFON and UFOBeep data
- [ ] No new technical debt introduced

### Emergency Fixes

If you must create inconsistent code to fix urgent issues:
1. **Document the inconsistency** in this file
2. **Add TODO comments** in the code
3. **Create cleanup task** for technical debt backlog
4. **Set timeline** for proper fix

The goal is to prevent the codebase from becoming unmaintainable due to accumulated inconsistencies.