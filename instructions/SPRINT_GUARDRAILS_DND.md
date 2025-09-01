# Sprint Plan Augmentation — Guardrails for DND/Quiet Hours

## Non‑negotiable Guardrails (prevent UI/DB regressions)

1) **Schema Freeze & Feature Flags**
   - No breaking DB schema changes for DND/Quiet Hours during this sprint.
   - Introduce `feature_flags.dnd_server_filtering` (default: false).
   - New code paths must be gated by the flag. Rollout via config, not code deploy.

2) **Contracts & DTOs**
   - Create explicit DTOs:
     - `DeviceRegistrationRequestV2` (additive only; original `DeviceRegistrationRequest` untouched).
     - `PushTargetV2` on server side; never delete/repurpose existing fields.
   - On mobile: versioned models with safe default values; avoid `required` on new fields.

3) **Migrations**
   - Only additive columns (`quiet_hours_start`, `quiet_hours_end`, `quiet_hours_tz`, `dnd_until`, `allow_emergency_override`).
   - All columns NULL‑tolerant with server‑side defaults.
   - Single migration file with full backward compatibility.

4) **Dual‑Path Logic**
   - Keep existing client‑only muting path.
   - Add server‑filtering path behind `dnd_server_filtering` flag.
   - Emergency override logic isolated in `dnd_utils.py` with unit tests.

5) **Rollout Plan**
   - Stage 1: Flag off. Deploy. No behavior change.
   - Stage 2: Enable for canary cohort (internal devices only).
   - Stage 3: Ramp to 10%, 50%, 100%. Roll back by flipping flag.

6) **Test Matrix (must pass before flag on)**
   - Unit: device registration parser, window math (cross‑midnight), emergency override thresholds.
   - Integration: push targeting excludes quiet devices; override when ≥N witnesses.
   - E2E: Android notification receipt in/ out of window (manual time travel), profile screen unaffected.
   - Regression: profile page renders; comment stream & map unaffected; DB migrations idempotent.

7) **Observability**
   - Add Sentry breadcrumbs for: registration update, push target build, filter decision, deliver/not deliver reason.
   - Emit metrics: `push_filtered_quiet_hours`, `push_filtered_dnd`, `push_emergency_override`, with device counts.

8) **Backout**
   - Feature flag to OFF, no rollback required.
   - Migration is additive; keep it.

## Tasks for Claude

- Create `server/feature_flags.py` with `dnd_server_filtering: bool` loaded from env.
- Implement `DeviceRegistrationRequestV2` (server + client) keeping V1 intact.
- Add columns (NULL‑tolerant) + backfill defaults (`allow_emergency_override=false`).
- Implement `dnd_utils.py` with helpers:
  - `is_in_quiet_window(now, start, end, tz)` handles cross‑midnight
  - `should_override(emergency_witness_count, threshold)`
- Push pipeline:
  - Build `PushTargetV2` from DB row + V2 prefs.
  - `_filter_targets_by_preferences()` returns decision + reason tag for logging/metrics.
- Add Sentry + metrics counters.
- Write 12 targeted unit tests + 3 integration tests described above.
- Create canary cohort mechanism (env var with device IDs set).

**Exit Criteria**
- All tests pass in CI.
- Canary run shows zero increase in failed deliveries except for expected filtered pushes.
- No UI or DB exceptions in Sentry for 48h after 50% ramp.
