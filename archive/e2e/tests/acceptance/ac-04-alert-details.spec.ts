import { test, expect } from '@playwright/test';
import { TestDataGenerator, TestUser, TestSighting } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-4: View Alert Details and Join Discussion', () => {
  let testUser: TestUser;
  let apiHelpers: APIHelpers;
  let testSighting: { id: string; data: TestSighting };
  let authToken: string;

  test.beforeAll(async ({ request }) => {
    testUser = TestDataGenerator.generateUser();
    apiHelpers = new APIHelpers(request);
    const { token } = await apiHelpers.createTestUser(testUser);
    authToken = token;

    // Create a test sighting for viewing
    const sightingData = TestDataGenerator.FIXED_SIGHTING;
    const { id } = await apiHelpers.createTestSighting(sightingData, token);
    testSighting = { id, data: sightingData };
  });

  test.beforeEach(async ({ page }) => {
    // Login user
    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');
    await page.waitForURL('**/dashboard');
  });

  test('should display complete sighting details @smoke @critical', async ({ page }) => {
    // Navigate to sighting detail
    await page.goto(`/sighting/${testSighting.id}`);

    // Verify main sighting information
    await expect(page.locator('[data-testid="sighting-title"]')).toContainText(testSighting.data.title);
    await expect(page.locator('[data-testid="sighting-description"]')).toContainText(testSighting.data.description);
    await expect(page.locator('[data-testid="sighting-category"]')).toContainText(testSighting.data.category);
    await expect(page.locator('[data-testid="sighting-timestamp"]')).toBeVisible();

    // Verify location information
    await expect(page.locator('[data-testid="sighting-location"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-coordinates"]')).toContainText(`${testSighting.data.location.latitude}`);
    await expect(page.locator('[data-testid="sighting-coordinates"]')).toContainText(`${testSighting.data.location.longitude}`);

    // Verify compass and elevation data
    await expect(page.locator('[data-testid="sighting-compass"]')).toContainText(`${testSighting.data.compass}°`);
    await expect(page.locator('[data-testid="sighting-elevation"]')).toContainText(`${testSighting.data.elevation}°`);

    // Verify map is displayed
    await expect(page.locator('[data-testid="sighting-map"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-marker"]')).toBeVisible();
  });

  test('should display enrichment data sections', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Wait for enrichment data to load
    await page.waitForSelector('[data-testid="enrichment-section"]', { timeout: 15000 });

    // Verify weather enrichment
    await expect(page.locator('[data-testid="weather-section"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-temperature"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-conditions"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-visibility"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-wind"]')).toBeVisible();

    // Verify celestial data
    await expect(page.locator('[data-testid="celestial-section"]')).toBeVisible();
    await expect(page.locator('[data-testid="sun-position"]')).toBeVisible();
    await expect(page.locator('[data-testid="moon-phase"]')).toBeVisible();
    await expect(page.locator('[data-testid="twilight-type"]')).toBeVisible();

    // Verify aircraft data
    await expect(page.locator('[data-testid="aircraft-section"]')).toBeVisible();

    // Check if ISS visibility data exists
    const issSection = page.locator('[data-testid="iss-visibility"]');
    if (await issSection.isVisible()) {
      await expect(issSection).toContainText('ISS');
    }
  });

  test('should allow joining Matrix discussion room', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Join discussion
    await page.click('[data-testid="join-discussion-btn"]');

    // Verify Matrix integration modal or redirect
    await page.waitForSelector('[data-testid="matrix-join-modal"]', { state: 'visible' });
    await expect(page.locator('[data-testid="room-info"]')).toBeVisible();
    await expect(page.locator('[data-testid="matrix-room-link"]')).toBeVisible();

    // Confirm join
    await page.click('[data-testid="confirm-join-btn"]');

    // Verify success state
    await expect(page.locator('[data-testid="discussion-joined"]')).toBeVisible();
    await expect(page.locator('[data-testid="discussion-status"]')).toContainText('Joined discussion');

    // Verify discussion section is now visible
    await expect(page.locator('[data-testid="discussion-section"]')).toBeVisible();
    await expect(page.locator('[data-testid="room-participants"]')).toBeVisible();
  });

  test('should display discussion participants and activity', async ({ page, request }) => {
    // Join the room first via API
    const roomId = await apiHelpers.joinMatrixRoom(testSighting.id, authToken);
    
    // Send a test message
    await apiHelpers.sendMatrixMessage(roomId, 'Test message from E2E test', authToken);

    await page.goto(`/sighting/${testSighting.id}`);

    // Wait for discussion section to load
    await page.waitForSelector('[data-testid="discussion-section"]');

    // Verify participant count
    await expect(page.locator('[data-testid="participant-count"]')).toBeVisible();
    await expect(page.locator('[data-testid="participant-count"]')).toContainText('1'); // At least the test user

    // Verify recent messages are shown
    await expect(page.locator('[data-testid="recent-messages"]')).toBeVisible();
    
    // Check if our test message appears
    const messages = page.locator('[data-testid="message-item"]');
    if (await messages.count() > 0) {
      await expect(messages.first().locator('[data-testid="message-content"]')).toBeVisible();
      await expect(messages.first().locator('[data-testid="message-author"]')).toBeVisible();
      await expect(messages.first().locator('[data-testid="message-timestamp"]')).toBeVisible();
    }

    // Verify join discussion button changes state
    await expect(page.locator('[data-testid="open-matrix-room-btn"]')).toBeVisible();
  });

  test('should show plane matching results when available', async ({ page, request }) => {
    // Trigger plane matching via API
    await apiHelpers.triggerPlaneMatch(testSighting.id, authToken);

    await page.goto(`/sighting/${testSighting.id}`);

    // Wait for plane matching section
    await page.waitForSelector('[data-testid="plane-matching-section"]', { timeout: 20000 });

    // Verify plane matching results
    await expect(page.locator('[data-testid="plane-match-status"]')).toBeVisible();
    
    const planeMatches = page.locator('[data-testid="plane-match-item"]');
    if (await planeMatches.count() > 0) {
      const firstMatch = planeMatches.first();
      await expect(firstMatch.locator('[data-testid="aircraft-callsign"]')).toBeVisible();
      await expect(firstMatch.locator('[data-testid="aircraft-altitude"]')).toBeVisible();
      await expect(firstMatch.locator('[data-testid="aircraft-speed"]')).toBeVisible();
      await expect(firstMatch.locator('[data-testid="match-probability"]')).toBeVisible();
    } else {
      // If no matches, should show "no aircraft found" message
      await expect(page.locator('[data-testid="no-aircraft-matches"]')).toContainText('No aircraft matches found');
    }
  });

  test('should display sighting on interactive map', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Verify interactive map
    await expect(page.locator('[data-testid="sighting-map"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-marker"]')).toBeVisible();

    // Test map interactions
    await page.click('[data-testid="sighting-marker"]');
    await expect(page.locator('[data-testid="marker-popup"]')).toBeVisible();

    // Verify zoom controls
    await expect(page.locator('[data-testid="zoom-in-btn"]')).toBeVisible();
    await expect(page.locator('[data-testid="zoom-out-btn"]')).toBeVisible();

    // Test zoom functionality
    await page.click('[data-testid="zoom-in-btn"]');
    await page.waitForTimeout(500); // Allow map to update

    await page.click('[data-testid="zoom-out-btn"]');
    await page.waitForTimeout(500);

    // Verify map layers toggle if available
    const layersControl = page.locator('[data-testid="map-layers-control"]');
    if (await layersControl.isVisible()) {
      await layersControl.click();
      await expect(page.locator('[data-testid="satellite-layer-toggle"]')).toBeVisible();
    }
  });

  test('should show directional compass visualization', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Verify compass component
    await expect(page.locator('[data-testid="compass-visualization"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-needle"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-degrees"]')).toContainText(`${testSighting.data.compass}°`);

    // Verify elevation angle display
    await expect(page.locator('[data-testid="elevation-display"]')).toBeVisible();
    await expect(page.locator('[data-testid="elevation-angle"]')).toContainText(`${testSighting.data.elevation}°`);

    // Verify sky direction indicator
    await expect(page.locator('[data-testid="sky-direction"]')).toBeVisible();
    
    // Verify cardinal direction text
    const compassDirection = testSighting.data.compass;
    let expectedDirection;
    if (compassDirection >= 337.5 || compassDirection < 22.5) expectedDirection = 'N';
    else if (compassDirection >= 22.5 && compassDirection < 67.5) expectedDirection = 'NE';
    else if (compassDirection >= 67.5 && compassDirection < 112.5) expectedDirection = 'E';
    else if (compassDirection >= 112.5 && compassDirection < 157.5) expectedDirection = 'SE';
    else if (compassDirection >= 157.5 && compassDirection < 202.5) expectedDirection = 'S';
    else if (compassDirection >= 202.5 && compassDirection < 247.5) expectedDirection = 'SW';
    else if (compassDirection >= 247.5 && compassDirection < 292.5) expectedDirection = 'W';
    else expectedDirection = 'NW';

    await expect(page.locator('[data-testid="cardinal-direction"]')).toContainText(expectedDirection);
  });

  test('should handle sharing sighting details', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Click share button
    await page.click('[data-testid="share-sighting-btn"]');

    // Verify share modal
    await expect(page.locator('[data-testid="share-modal"]')).toBeVisible();
    await expect(page.locator('[data-testid="share-url"]')).toBeVisible();
    await expect(page.locator('[data-testid="copy-url-btn"]')).toBeVisible();

    // Test copy URL functionality
    await page.click('[data-testid="copy-url-btn"]');
    await expect(page.locator('[data-testid="copy-success-message"]')).toBeVisible();

    // Verify social media share buttons
    await expect(page.locator('[data-testid="share-twitter-btn"]')).toBeVisible();
    await expect(page.locator('[data-testid="share-facebook-btn"]')).toBeVisible();

    // Close modal
    await page.click('[data-testid="close-share-modal"]');
    await expect(page.locator('[data-testid="share-modal"]')).toBeHidden();
  });

  test('should display related sightings', async ({ page, request }) => {
    // Create additional sighting in same area
    const relatedSighting = {
      ...TestDataGenerator.generateSighting(),
      location: {
        latitude: testSighting.data.location.latitude + 0.01, // Close to original
        longitude: testSighting.data.location.longitude + 0.01,
        address: 'Nearby location'
      }
    };
    await apiHelpers.createTestSighting(relatedSighting, authToken);

    await page.goto(`/sighting/${testSighting.id}`);

    // Wait for related sightings section
    await page.waitForSelector('[data-testid="related-sightings"]', { timeout: 10000 });

    // Verify related sightings are shown
    const relatedCards = page.locator('[data-testid="related-sighting-card"]');
    const relatedCount = await relatedCards.count();

    if (relatedCount > 0) {
      const firstRelated = relatedCards.first();
      await expect(firstRelated.locator('[data-testid="related-title"]')).toBeVisible();
      await expect(firstRelated.locator('[data-testid="related-distance"]')).toBeVisible();
      await expect(firstRelated.locator('[data-testid="related-timestamp"]')).toBeVisible();

      // Click on related sighting
      await firstRelated.click();

      // Should navigate to the related sighting
      await page.waitForURL('**/sighting/**');
      await expect(page.url()).not.toContain(testSighting.id);
    }
  });

  test('should handle anonymous viewing of public sightings', async ({ page }) => {
    // Logout first
    await page.click('[data-testid="user-menu"]');
    await page.click('[data-testid="logout-btn"]');
    await page.waitForURL('**/');

    // Navigate to sighting as anonymous user
    await page.goto(`/sighting/${testSighting.id}`);

    // Verify basic details are visible
    await expect(page.locator('[data-testid="sighting-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-description"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-map"]')).toBeVisible();

    // Verify join discussion shows login prompt
    await page.click('[data-testid="join-discussion-btn"]');
    await expect(page.locator('[data-testid="login-required-modal"]')).toBeVisible();
    await expect(page.locator('[data-testid="login-to-join-btn"]')).toBeVisible();

    // Click login button should redirect to login
    await page.click('[data-testid="login-to-join-btn"]');
    await page.waitForURL('**/login**');
  });

  test('should display timestamps in user locale', async ({ page }) => {
    await page.goto(`/sighting/${testSighting.id}`);

    // Verify timestamp elements are present
    await expect(page.locator('[data-testid="sighting-timestamp"]')).toBeVisible();
    await expect(page.locator('[data-testid="reported-time"]')).toBeVisible();

    // Verify relative time display
    const relativeTime = page.locator('[data-testid="relative-time"]');
    if (await relativeTime.isVisible()) {
      const timeText = await relativeTime.textContent();
      expect(timeText).toMatch(/(ago|just now|minutes?|hours?|days?)/i);
    }

    // Switch language and verify time format changes
    await page.click('[data-testid="language-switcher"]');
    await page.click('[data-testid="language-option-es"]');
    await page.waitForLoadState('networkidle');

    // Verify Spanish time format (basic check)
    const spanishTime = await page.locator('[data-testid="relative-time"]').textContent();
    if (spanishTime) {
      // Should contain Spanish time indicators
      const hasSpanishTimeWords = /hace|justo ahora|minutos?|horas?|días?/i.test(spanishTime);
      expect(hasSpanishTimeWords).toBeTruthy();
    }
  });

  test.afterAll(async ({ request }) => {
    // Cleanup test data
    if (authToken && apiHelpers) {
      await apiHelpers.cleanupTestData(authToken, []);
    }
  });
});