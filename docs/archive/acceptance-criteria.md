# UFOBeep Acceptance Criteria

## AC-1: User Registration and Profile Setup
**As a** new user  
**I want to** register and set up my profile  
**So that** I can start reporting and tracking UFO sightings

### Acceptance Criteria:
- [ ] User can register with email or phone number
- [ ] User can set observation preferences (range, notification types)
- [ ] User can select preferred language (EN/ES/DE)
- [ ] User profile data is persisted across sessions
- [ ] User can edit profile settings after registration

## AC-2: Capture and Report Sighting
**As a** registered user  
**I want to** capture and report a UFO sighting  
**So that** it can be shared with the community

### Acceptance Criteria:
- [ ] User can capture photo/video with device camera
- [ ] Automatic GPS location capture with accuracy indicator
- [ ] Compass heading and device orientation recorded
- [ ] User can add description and details
- [ ] Sighting is uploaded with all metadata
- [ ] User receives confirmation of successful submission
- [ ] Plane matching runs automatically for sky objects

## AC-3: Browse and Filter Alerts
**As a** user  
**I want to** browse and filter UFO alerts  
**So that** I can find relevant sightings

### Acceptance Criteria:
- [ ] User can view list of recent alerts
- [ ] Alerts show distance from user location
- [ ] User can filter by time (24h, week, month)
- [ ] User can filter by distance/radius
- [ ] User can filter by category (UFO, light, formation)
- [ ] Alerts update in real-time when new sightings are reported

## AC-4: View Alert Details and Join Discussion
**As a** user  
**I want to** view detailed information about a sighting  
**So that** I can learn more and discuss with others

### Acceptance Criteria:
- [ ] User can view full sighting details (photos, location, time, description)
- [ ] User can see enrichment data (weather, celestial, satellites)
- [ ] User can join Matrix chat room for the sighting
- [ ] User can post messages in the discussion
- [ ] User can see other witnesses' comments
- [ ] Moderation badges are visible on inappropriate content

## AC-5: Compass Navigation (Standard Mode)
**As a** user  
**I want to** navigate to a sighting location  
**So that** I can investigate or observe from the same spot

### Acceptance Criteria:
- [ ] Compass shows current heading (magnetic)
- [ ] Arrow points to sighting location
- [ ] Distance to sighting is displayed
- [ ] AR overlay shows sighting direction when camera active
- [ ] User location updates as they move
- [ ] Works offline with cached data

## AC-6: Pilot Mode Navigation
**As a** pilot or advanced user  
**I want to** use advanced navigation features  
**So that** I can precisely track and intercept phenomena

### Acceptance Criteria:
- [ ] Toggle between magnetic and true heading
- [ ] Display relative bearing to target
- [ ] Calculate and display ETA based on current speed
- [ ] Show altitude difference if available
- [ ] Display bank angle indicator for turns
- [ ] Vectoring guidance for optimal intercept path
- [ ] Speed and heading recommendations