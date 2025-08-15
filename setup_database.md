# UFOBeep Database Setup Guide

## 1. Install PostgreSQL Client
```bash
sudo apt update
sudo apt install postgresql-client-common postgresql-client
```

## 2. Create UFOBeep Database and User

Connect as the default PostgreSQL superuser (usually `postgres`):
```bash
# Try one of these connection methods:
sudo -u postgres psql
# OR
psql -U postgres -h localhost
# OR
psql -h localhost -p 5432
```

Once connected to PostgreSQL, create the UFOBeep database setup:
```sql
-- Create database
CREATE DATABASE ufobeep_db;

-- Create user with password
CREATE USER ufobeep_user WITH PASSWORD 'ufopostpass';

-- Grant all privileges on the database
GRANT ALL PRIVILEGES ON DATABASE ufobeep_db TO ufobeep_user;

-- Connect to the ufobeep database
\c ufobeep_db

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO ufobeep_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ufobeep_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ufobeep_user;

-- Make sure future tables are also accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ufobeep_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ufobeep_user;

-- Verify the setup
\l  -- List databases
\du -- List users
\q  -- Quit
```

## 3. Test Connection
```bash
psql -h localhost -U ufobeep_user -d ufobeep_db
# Password: ufopostpass
```

## 4. Run UFOBeep Migration
```bash
cd /home/mike/D/ufobeep/api
PGPASSWORD=ufopostpass psql -h localhost -U ufobeep_user -d ufobeep_db -f migrations/001_add_media_primary_fields.sql
```

## 5. Verify Migration Success
```bash
PGPASSWORD=ufopostpass psql -h localhost -U ufobeep_user -d ufobeep_db -c "
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'media_files' 
AND column_name IN ('is_primary', 'uploaded_by_user_id', 'upload_order', 'display_priority', 'contributed_at')
ORDER BY column_name;
"
```

## Alternative: Use Python Migration Script

If you prefer using the Python script:
```bash
cd /home/mike/D/ufobeep/api
source venv/bin/activate
python run_migration.py
```

## Troubleshooting

### If postgres user doesn't exist:
Try connecting with your system username:
```bash
psql -h localhost -d postgres
```

### If permission denied:
Check PostgreSQL is running and accepting connections:
```bash
sudo systemctl status postgresql
```

### If database already exists:
You can skip database creation and just run the migration:
```bash
PGPASSWORD=ufopostpass psql -h localhost -U ufobeep_user -d ufobeep_db -f migrations/001_add_media_primary_fields.sql
```

---

**Once this is complete, your multi-media system will be fully operational!**