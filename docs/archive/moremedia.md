# UFOBeep — Community Media Addition System (30 Sequential Build Steps)

> Feed these to Claude **one at a time** in order for community photo/video contributions with AI moderation.

## Overview
This system allows authenticated users to contribute additional photos/videos to existing sightings, with location verification, AI content moderation, and classification. Builds upon existing media storage infrastructure.

---

## Phase 1: User Authentication & Admin Foundation (Steps 1-8)

01. [TODO] [FASTAPI] Implement user registration/login system with JWT tokens  
    - Create User model with id, username, email, created_at, is_admin, is_verified  
    - POST /auth/register, POST /auth/login, POST /auth/refresh endpoints  
    - Password hashing with bcrypt, JWT token generation  
    - Email verification workflow (optional for MVP)

02. [TODO] [FASTAPI] Add user session management and authentication middleware  
    - JWT token validation middleware  
    - get_current_user() dependency injection  
    - get_current_user_id() for optional auth  
    - Rate limiting by user ID

03. [TODO] [FASTAPI] Create admin panel endpoints and permissions system  
    - Admin-only decorator @require_admin  
    - GET /admin/users (list users with stats)  
    - GET /admin/sightings (list all sightings with flags)  
    - POST /admin/users/{id}/ban, POST /admin/users/{id}/unban  
    - Basic admin dashboard data endpoints

04. [TODO] [MOBILE] Implement user registration/login screens  
    - Registration form with username, email, password  
    - Login form with remember me option  
    - Secure token storage in device keychain  
    - Auto-login on app start if token valid  
    - Logout functionality

05. [TODO] [NEXTJS] Add user authentication to website  
    - Login/register forms with form validation  
    - JWT token storage in secure httpOnly cookies  
    - Protected route middleware for authenticated pages  
    - User profile display in navbar  
    - Login required modal for contribution features

06. [TODO] [FASTAPI] Link existing sightings to user accounts  
    - Add reporter_user_id column to sightings table  
    - Migration to backfill existing sightings as anonymous  
    - Update sighting creation to require authentication  
    - Add user relationship to sighting model

07. [TODO] [FASTAPI] Create basic admin web interface  
    - Simple admin panel at /admin with user management  
    - View flagged content, user reports, system stats  
    - Ban/unban users, delete inappropriate content  
    - Export data for analysis

08. [TODO] [ALL] User profile and settings management  
    - User can update profile (display name, bio, location)  
    - Privacy settings (show location, public profile)  
    - Notification preferences  
    - Account deletion with data cleanup

---

## Phase 2: Community Contributions Core (Steps 9-16)

09. [TODO] [FASTAPI] Add contribution permission system  
    - GET /sightings/{id}/can-contribute endpoint  
    - Check user authentication, location proximity, time limits  
    - Max contributions per user per sighting (5)  
    - 7-day contribution window after original sighting

10. [TODO] [FASTAPI] Implement location validation for contributions  
    - Calculate distance between user location and sighting  
    - Use sighting visibility * 3 or default 100 miles max distance  
    - IP geolocation for web users, GPS for mobile  
    - Allow manual location override with admin approval

11. [TODO] [FASTAPI] Create contribution endpoints  
    - POST /sightings/{id}/contribute-media  
    - Upload flow: presign → upload → complete (same as existing)  
    - Store contributor user_id, contributed_at timestamp  
    - Update sighting media_files array with new items

12. [TODO] [FASTAPI] Add contribution tracking to database  
    - Add contributed_by_user_id, contributed_at to media_files  
    - Create contributions table for audit trail  
    - Track contribution attempts (success/failure reasons)  
    - User contribution stats and reputation

13. [TODO] [MOBILE] Add "Contribute Photos" to sighting detail screen  
    - Show button only if user can contribute (location check)  
    - Camera/gallery picker for multiple files  
    - Upload progress indicators  
    - Success confirmation with thumbnail previews

14. [TODO] [NEXTJS] Add community contribution section to alert detail page  
    - Show contribution form for authenticated users in range  
    - Drag & drop file upload interface  
    - Preview thumbnails with remove option  
    - Upload progress and error handling

15. [TODO] [MOBILE] Add contribution UI to post-beep success screen  
    - "Add More Photos" button after successful sighting creation  
    - Quick camera access for immediate follow-up shots  
    - Batch upload with progress indication  
    - Navigate to full sighting detail after upload

16. [TODO] [ALL] Enhanced media display with contributor attribution  
    - Show "Added by [username]" on contributed media  
    - Original reporter badge vs community contribution  
    - Timestamp of when media was added  
    - Contributor profile links (if public)

---

## Phase 3: AI Content Moderation (Steps 17-24)

17. [TODO] [FASTAPI] Integrate OpenAI GPT-4 Vision for content moderation  
    - Add OpenAI API client configuration  
    - POST /ai/moderate-image endpoint  
    - Detect NSFW, spam, inappropriate content  
    - Return safety score with confidence level

18. [TODO] [FASTAPI] Create content moderation pipeline  
    - Auto-moderate all uploads before storage  
    - Block unsafe content immediately  
    - Queue borderline content for human review  
    - Log violations by user for tracking

19. [TODO] [FASTAPI] Add human moderation review system  
    - Admin queue for flagged content review  
    - Approve/reject moderation decisions  
    - User appeals process for false positives  
    - Moderation action history and analytics

20. [TODO] [FASTAPI] Implement user reporting system  
    - POST /reports/media/{id} for community reporting  
    - Report categories: inappropriate, spam, fake, duplicate  
    - Auto-hide after threshold reports pending review  
    - Reporter anonymity and anti-spam measures

21. [TODO] [ALL] Content warning and filtering UI  
    - Mark potentially sensitive content with warnings  
    - User preference to hide/blur flagged content  
    - Click-to-reveal for borderline material  
    - Safe mode toggle in user settings

22. [TODO] [FASTAPI] Add content moderation webhook notifications  
    - Notify admins of high-priority violations  
    - Slack/Discord integration for moderation alerts  
    - Email digest of daily moderation actions  
    - Auto-ban users with multiple violations

23. [TODO] [ALL] Moderation transparency and user education  
    - Community guidelines page with examples  
    - Moderation appeal process documentation  
    - User notification when content is moderated  
    - Clear messaging about AI vs human moderation

24. [TODO] [FASTAPI] Advanced moderation features  
    - Duplicate image detection (perceptual hashing)  
    - User reputation scoring affecting auto-approval  
    - Whitelist trusted users for reduced moderation  
    - A/B test different moderation thresholds

---

## Phase 4: AI Classification & Analysis (Steps 25-30)

25. [TODO] [FASTAPI] Implement AI image classification system  
    - Integrate Google Cloud Vision or OpenAI for object detection  
    - POST /ai/classify-image endpoint  
    - Detect objects: aircraft, lights, sky, ground, buildings  
    - Scene analysis: time of day, weather, environment

26. [TODO] [FASTAPI] Add anomaly scoring and quality assessment  
    - Calculate anomaly score based on detected objects  
    - Image quality metrics: sharpness, brightness, blur  
    - Unusual object combinations increase anomaly score  
    - Store AI analysis results in media metadata

27. [TODO] [FASTAPI] Update alert level calculation with AI data  
    - Factor anomaly score into alert level determination  
    - Higher quality images increase alert score  
    - Multiple angles/perspectives bonus scoring  
    - AI confidence levels affect scoring weight

28. [TODO] [ALL] Display AI analysis results in UI  
    - Show detected objects with confidence percentages  
    - Anomaly score visualization (gauge or progress bar)  
    - Image quality indicators for users  
    - Toggle detailed AI analysis view

29. [TODO] [FASTAPI] Advanced AI features and insights  
    - Similar event detection across different sightings  
    - Temporal/spatial clustering of similar objects  
    - Weather correlation with sighting patterns  
    - Export AI analysis data for researchers

30. [TODO] [ALL] AI-powered recommendations and discovery  
    - "Similar sightings" recommendations based on AI analysis  
    - Smart notification triggers for high-anomaly events  
    - AI-generated sighting summaries and highlights  
    - Machine learning model improvement feedback loop

---

## Database Schema Changes

```sql
-- New tables
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    is_admin BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    is_banned BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sighting_id UUID REFERENCES sightings(id),
    user_id UUID REFERENCES users(id),
    media_file_id UUID REFERENCES media_files(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE moderation_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_file_id UUID REFERENCES media_files(id),
    reviewed_by_user_id UUID REFERENCES users(id),
    ai_result JSONB,
    human_decision VARCHAR(20), -- approved, rejected, flagged
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Modified tables
ALTER TABLE sightings ADD COLUMN reporter_user_id UUID REFERENCES users(id);
ALTER TABLE media_files ADD COLUMN contributed_by_user_id UUID REFERENCES users(id);
ALTER TABLE media_files ADD COLUMN contributed_at TIMESTAMP;
ALTER TABLE media_files ADD COLUMN ai_analysis JSONB;
ALTER TABLE media_files ADD COLUMN moderation_status VARCHAR(20) DEFAULT 'approved';
```

## Success Metrics

- **User Engagement**: Registration rate, contribution rate per user
- **Content Quality**: AI moderation accuracy, false positive rate
- **Community Growth**: Active contributors, photos per sighting
- **Safety**: Successfully blocked inappropriate content percentage
- **Alert Improvement**: Higher alert levels due to additional media

## Risk Mitigation

- **Spam Protection**: Rate limiting, user reputation, admin oversight
- **Privacy**: Location privacy controls, opt-out options
- **Legal**: Clear terms of service, DMCA compliance, data retention policies
- **Performance**: CDN for media, efficient AI API usage, caching strategies