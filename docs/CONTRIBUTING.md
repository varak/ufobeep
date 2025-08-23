# Contributing

## Workflow

1. **Create a branch for your work**
   ```bash
   git checkout -b feat/my-feature
   ```
   Use `feat/...` for new features, `fix/...` for bugfixes, `chore/...` for misc.

2. **Commit changes with Conventional Commits**
   Examples:
   - `feat: add push notification handling`
   - `fix: correct compass overlay bug`

3. **Push your branch to GitHub**
   ```bash
   git push origin feat/my-feature
   ```

4. **Open a Pull Request (PR)**
   - Target branch: `main`
   - CI checks (lint/tests) must pass
   - At least one review (you/Claude can self‑review if solo)

5. **Merge & cleanup**
   ```bash
   git checkout main
   git pull
   git branch -d feat/my-feature
   ```

## Best practices
- Keep commits small & descriptive
- Never commit secrets (Firebase keys, API tokens)
- Update docs if you change flows or endpoints

## Development Environment Setup

### API Development
1. **Start API locally**:
   ```bash
   cd api
   source venv/bin/activate
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

2. **Production deployment**:
   ```bash
   ./deploy.sh api
   ```

### Common Issues & Fixes

#### API Service Won't Start
- **Symptom**: systemd service fails with exit code 203
- **Cause**: Corrupted shebang in start-api.sh
- **Fix**: Ensure shebang is `#!/bin/bash` not `#\!/bin/bash`

#### Registration Errors
- **Best Practice**: Always provide user-friendly error messages
- **Example**: "This email is already registered" not "UNIQUE constraint failed"
- **Implementation**: Use try/catch with specific error handling for database constraints

#### Testing Registration Flow
1. Uninstall app completely (to simulate new user)
2. Install fresh APK: https://ufobeep.com/downloads/ufobeep-latest.apk
3. Verify username generation and error handling work correctly
