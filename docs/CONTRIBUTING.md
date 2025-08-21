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
