# Database Connection Pool Guidelines

**Created**: September 8, 2025  
**Priority**: CRITICAL - Production Stability

## 🚨 The Problem

On September 8, 2025, UFOBeep API experienced a critical production outage:
- **Symptom**: 500 errors after only 5-10 beep requests
- **Impact**: Users unable to create beeps, complete system failure
- **Root Cause**: Database connection pool exhaustion

## 🔍 Technical Analysis

### What Went Wrong
Multiple API routers were creating independent database connection pools instead of sharing one:

```python
# ❌ WRONG: Each router created its own pool
# alerts.py
async def get_db():
    return await asyncpg.create_pool(
        host="localhost", port=5432, user="ufobeep_user", 
        password="ufopostpass", database="ufobeep_db",
        min_size=1, max_size=10  # ← Pool 1
    )

# admin_simple.py  
async def get_db():
    return await asyncpg.create_pool(
        # Same credentials, NEW POOL!  # ← Pool 2
        min_size=1, max_size=10
    )

# mufon.py (had TWO instances!)
db_pool = await asyncpg.create_pool(...)  # ← Pool 3
# ... later in same file ...
db_pool = await asyncpg.create_pool(...)  # ← Pool 4
```

### The Math That Broke Us
- **PostgreSQL limit**: 100 total connections
- **Pool 1**: up to 20 connections
- **Pool 2**: up to 10 connections  
- **Pool 3**: up to 5 connections
- **Pool 4**: up to 5 connections
- **Total pools**: 4+ separate pools
- **With concurrent requests**: Quickly exhausted 100 connection limit

## ✅ The Fix

### Shared Database Service Pattern
All routers now use the centralized database service:

```python
# ✅ CORRECT: Use shared pool
async def get_db():
    from app.services.database_service import get_database_pool
    return await get_database_pool()
```

### Centralized Pool Management
The `database_service.py` provides:
- **Single pool instance** shared across entire API
- **Proper connection lifecycle** management
- **Health monitoring** and diagnostics
- **Production-ready settings** (min=2, max=20)

## 📋 Mandatory Development Rules

### 🚫 NEVER DO THIS
```python
# ❌ Creating new pools anywhere except database_service.py
import asyncpg
pool = await asyncpg.create_pool(...)

# ❌ Closing shared pools
await pool.close()  # Don't close what you didn't create!

# ❌ Hardcoding database credentials in routers
password="ufopostpass"  # Use environment service!
```

### ✅ ALWAYS DO THIS
```python
# ✅ Use the shared database service
from app.services.database_service import get_database_pool
pool = await get_database_pool()

# ✅ Use dependency injection in FastAPI
async def some_endpoint(pool: asyncpg.Pool = Depends(get_database_pool)):
    async with pool.acquire() as conn:
        # Your database operations
        pass

# ✅ Proper connection handling
async with pool.acquire() as conn:
    # Connection automatically returned to pool
    result = await conn.fetch("SELECT * FROM table")
```

## 🛡️ Prevention Strategies

### Code Review Checklist
- [ ] No `asyncpg.create_pool()` calls outside `database_service.py`
- [ ] No hardcoded database credentials
- [ ] No `pool.close()` calls on shared pools
- [ ] All database access uses shared service
- [ ] Proper connection acquisition/release patterns

### Automated Checks
Add to CI/CD pipeline:
```bash
# Check for forbidden patterns
grep -r "asyncpg.create_pool" api/app/routers/ && exit 1
grep -r "pool.close()" api/app/routers/ && exit 1
```

### Monitoring
Watch for connection exhaustion warnings:
```bash
# Check current connections
sudo -u postgres psql -d ufobeep_db -c "SELECT count(*), state FROM pg_stat_activity WHERE datname='ufobeep_db' GROUP BY state;"

# Monitor for exhaustion errors
sudo journalctl -u ufobeep-api | grep "TooManyConnectionsError"
```

## 📊 Connection Pool Health

### Optimal Settings
```python
# Production pool configuration
pool = await asyncpg.create_pool(
    min_size=2,    # Keep minimum connections warm
    max_size=20,   # Reasonable max for single service
    max_queries=50000,  # Recycle connections periodically
    max_inactive_connection_lifetime=300,  # 5 minute timeout
)
```

### Health Indicators
```python
# Monitor pool health
health = {
    "total_size": pool.get_size(),
    "idle_size": pool.get_idle_size(), 
    "max_size": pool.get_max_size(),
    "min_size": pool.get_min_size()
}
```

## 🎯 Testing

### Load Testing
```bash
# Simulate the failure condition
for i in {1..20}; do
    curl -X POST https://ufobeep.com/api/alerts \
         -H "Content-Type: application/json" \
         -d '{"test": true}' &
done
wait
```

### Connection Counting
```bash
# Should never exceed reasonable limits
watch "sudo -u postgres psql -d ufobeep_db -c \"SELECT count(*) FROM pg_stat_activity WHERE datname='ufobeep_db';\""
```

## 🚨 Emergency Response

If connection pool exhaustion occurs again:

1. **Immediate**: Restart API service
   ```bash
   sudo systemctl restart ufobeep-api
   ```

2. **Investigate**: Check pool creation
   ```bash
   grep -r "create_pool" api/app/routers/
   ```

3. **Monitor**: Watch connection counts
   ```bash
   sudo journalctl -u ufobeep-api -f
   ```

## 📚 References

- **Fixed Files**: `alerts.py`, `admin_simple.py`, `mufon.py`
- **Service**: `app/services/database_service.py`
- **Deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md) for monitoring commands
- **PostgreSQL Docs**: Connection pooling best practices

---

**Remember**: This wasn't a theoretical problem. **5 beep requests crashed our production system.** These guidelines prevent it from happening again.