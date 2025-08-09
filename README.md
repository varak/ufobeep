# UFOBeep

Real-time UFO and anomaly sighting alert system with enrichment, chat, and AR navigation.

## Architecture

- **Mobile App** (Flutter): iOS/Android app for capturing, viewing, and navigating to sightings
- **Web** (Next.js): Public website with shareable alert pages and app installation guide  
- **API** (FastAPI): REST API with async enrichment workers
- **Chat** (Matrix): Per-sighting chat rooms with moderation
- **Infrastructure**: PostgreSQL, Redis, S3/MinIO, Matrix Dendrite

## Structure

```
app/      # Flutter mobile application
web/      # Next.js public website
api/      # FastAPI backend + workers
infra/    # Deployment configs
docs/     # Documentation
.github/  # CI/CD workflows
```

## Features

- 📸 Capture or upload sighting photos
- 🌍 Location-based alert feed with range filtering
- 💬 Real-time chat per sighting via Matrix
- 🧭 AR Compass navigation (Standard + Pilot modes)
- 🔄 Progressive enrichment (weather, celestial, satellites)
- 🔔 Push notifications for nearby sightings
- 🌐 Multi-language support (EN/ES/DE)
- 🛡️ Content moderation and safety features

## Development

See `docs/task.md` for build steps and `docs/project-description.md` for technical specifications.
