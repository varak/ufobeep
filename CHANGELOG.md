# Changelog
All notable changes to this project will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial CONTRIBUTING.md and CI.md
- GitHub Actions for Flutter & API
- Master plan v13 (push-first + realtime)
- Device-specific deployment support (moto, tablet, pixel, samsung)
- Flutter build step integrated into deploy script

### Added (MP13-1 - Username System)
- Username generation service with cosmic-themed usernames (cosmic.whisper.7823)
- User registration API with complete profile management
- Mobile app user registration screen with generated/custom username options
- Database migration system for transitioning device IDs to usernames
- User profile API with statistics and engagement metrics

### Fixed
- "I saw it too" button now properly hidden for alert creators (handles empty reporterId)
- Premium satellite imagery access control (BlackSky/SkyFi)
- Chat button removed from alert detail screen
- Deploy script reliability with device management and timeouts
- Alert attribution system prepared for username-based identification

## [0.2.0-alpha] - 2025-08-21
### Added
- One-tap Beep button (UI + GPS permission)
- Basic camera capture + gallery save
- Partial compass overlay
- Alert list + detail + chat screens
- v1.1 and v2.0 APK builds

### Changed
- Migrated away from PWA/webapp for realtime alerts

### Removed
- PWA-first plan (archived to docs/archive)
