import { test, expect } from '@playwright/test';
import { TestDataGenerator, TestUser } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-6: Pilot Mode Navigation', () => {
  let testUser: TestUser;
  let apiHelpers: APIHelpers;
  
  test.beforeEach(async ({ page, request, context }) => {
    testUser = TestDataGenerator.generateUser();
    apiHelpers = new APIHelpers(request);
    
    // Create and login user
    await apiHelpers.createTestUser(testUser);
    
    // Grant necessary permissions for pilot mode
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');
    await page.waitForURL('**/dashboard');
  });

  test('should switch to pilot mode from standard compass @smoke @critical', async ({ page }) => {
    // Navigate to compass
    await page.goto('/compass');
    await page.waitForSelector('[data-testid="compass-container"]');

    // Switch to pilot mode
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Verify pilot mode activation
    await expect(page.locator('[data-testid="pilot-mode-active"]')).toBeVisible();
    await expect(page.locator('[data-testid="mode-indicator"]')).toContainText('Pilot Mode');

    // Verify pilot-specific UI elements
    await expect(page.locator('[data-testid="horizon-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="artificial-horizon"]')).toBeVisible();
    await expect(page.locator('[data-testid="altitude-tape"]')).toBeVisible();
    await expect(page.locator('[data-testid="airspeed-indicator"]')).toBeVisible();

    // Verify compass still visible but enhanced
    await expect(page.locator('[data-testid="pilot-compass"]')).toBeVisible();
    await expect(page.locator('[data-testid="heading-bug"]')).toBeVisible();
  });

  test('should display artificial horizon with pitch and roll', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Verify artificial horizon components
    await expect(page.locator('[data-testid="horizon-line"]')).toBeVisible();
    await expect(page.locator('[data-testid="pitch-scale"]')).toBeVisible();
    await expect(page.locator('[data-testid="roll-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="aircraft-symbol"]')).toBeVisible();

    // Simulate device orientation change (mock roll/pitch)
    await page.evaluate(() => {
      const event = new CustomEvent('deviceorientationabsolute', {
        detail: { 
          alpha: 0,   // heading
          beta: 10,   // pitch (nose up)
          gamma: -5   // roll (left wing down)
        }
      });
      window.dispatchEvent(event);
    });

    await page.waitForTimeout(1000);

    // Verify pitch indication
    await expect(page.locator('[data-testid="pitch-value"]')).toContainText('10°');
    await expect(page.locator('[data-testid="pitch-direction"]')).toContainText('UP');

    // Verify roll indication
    await expect(page.locator('[data-testid="roll-value"]')).toContainText('5°');
    await expect(page.locator('[data-testid="roll-direction"]')).toContainText('LEFT');

    // Verify horizon line tilts with roll
    const horizonTransform = await page.locator('[data-testid="horizon-line"]')
      .getAttribute('style');
    expect(horizonTransform).toContain('rotate');
  });

  test('should show airspace information and NOTAMs', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Wait for airspace data to load
    await page.waitForSelector('[data-testid="airspace-panel"]', { timeout: 15000 });

    // Verify airspace information
    await expect(page.locator('[data-testid="controlled-airspace"]')).toBeVisible();
    await expect(page.locator('[data-testid="airspace-class"]')).toBeVisible();
    await expect(page.locator('[data-testid="ceiling-height"]')).toBeVisible();
    await expect(page.locator('[data-testid="floor-height"]')).toBeVisible();

    // Check for NOTAMs
    const notamsSection = page.locator('[data-testid="notams-section"]');
    if (await notamsSection.isVisible()) {
      await expect(page.locator('[data-testid="active-notams"]')).toBeVisible();
      
      const notamItems = page.locator('[data-testid="notam-item"]');
      const notamCount = await notamItems.count();
      
      if (notamCount > 0) {
        const firstNotam = notamItems.first();
        await expect(firstNotam.locator('[data-testid="notam-type"]')).toBeVisible();
        await expect(firstNotam.locator('[data-testid="notam-description"]')).toBeVisible();
        await expect(firstNotam.locator('[data-testid="notam-validity"]')).toBeVisible();
      }
    }

    // Verify TFR (Temporary Flight Restrictions) if any
    const tfrSection = page.locator('[data-testid="tfr-section"]');
    if (await tfrSection.isVisible()) {
      await expect(page.locator('[data-testid="active-tfrs"]')).toBeVisible();
    }
  });

  test('should display nearby aircraft traffic', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Wait for traffic data
    await page.waitForSelector('[data-testid="traffic-panel"]', { timeout: 10000 });

    // Verify traffic display
    await expect(page.locator('[data-testid="traffic-scope"]')).toBeVisible();
    
    const trafficTargets = page.locator('[data-testid="traffic-target"]');
    const targetCount = await trafficTargets.count();

    if (targetCount > 0) {
      const firstTarget = trafficTargets.first();
      
      // Verify traffic target information
      await expect(firstTarget.locator('[data-testid="target-callsign"]')).toBeVisible();
      await expect(firstTarget.locator('[data-testid="target-altitude"]')).toBeVisible();
      await expect(firstTarget.locator('[data-testid="target-distance"]')).toBeVisible();
      await expect(firstTarget.locator('[data-testid="target-bearing"]')).toBeVisible();

      // Click on traffic target for details
      await firstTarget.click();
      await expect(page.locator('[data-testid="traffic-detail-popup"]')).toBeVisible();
      await expect(page.locator('[data-testid="aircraft-type"]')).toBeVisible();
      await expect(page.locator('[data-testid="flight-level"]')).toBeVisible();
      await expect(page.locator('[data-testid="ground-speed"]')).toBeVisible();
    } else {
      // Should show "no traffic" message
      await expect(page.locator('[data-testid="no-traffic-message"]')).toContainText('No traffic detected');
    }
  });

  test('should provide aviation weather information', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Open weather panel
    await page.click('[data-testid="weather-info-btn"]');
    await expect(page.locator('[data-testid="aviation-weather"]')).toBeVisible();

    // Verify METAR information
    await expect(page.locator('[data-testid="metar-section"]')).toBeVisible();
    await expect(page.locator('[data-testid="station-identifier"]')).toBeVisible();
    await expect(page.locator('[data-testid="wind-information"]')).toBeVisible();
    await expect(page.locator('[data-testid="visibility-range"]')).toBeVisible();
    await expect(page.locator('[data-testid="cloud-layers"]')).toBeVisible();
    await expect(page.locator('[data-testid="temperature-dewpoint"]')).toBeVisible();
    await expect(page.locator('[data-testid="barometric-pressure"]')).toBeVisible();

    // Verify TAF (Terminal Aerodrome Forecast) if available
    const tafSection = page.locator('[data-testid="taf-section"]');
    if (await tafSection.isVisible()) {
      await expect(page.locator('[data-testid="forecast-periods"]')).toBeVisible();
      await expect(page.locator('[data-testid="wind-forecast"]')).toBeVisible();
      await expect(page.locator('[data-testid="visibility-forecast"]')).toBeVisible();
    }

    // Verify weather conditions indicators
    await expect(page.locator('[data-testid="flight-conditions"]')).toBeVisible();
    const conditions = await page.locator('[data-testid="flight-category"]').textContent();
    expect(conditions).toMatch(/(VFR|MVFR|IFR|LIFR)/);
  });

  test('should calculate bearing and distance to sightings in aviation format', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    // Create test sighting
    const targetSighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'Aviation Target UFO',
      location: {
        latitude: 37.8049, // ~3.3km north-northwest
        longitude: -122.4494,
        address: 'Flight path area'
      }
    };

    await apiHelpers.createTestSighting(targetSighting, token);

    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');
    await page.waitForSelector('[data-testid="sighting-indicator"]');

    // Select the sighting
    const sightingIndicator = page.locator('[data-testid="sighting-indicator"]').first();
    await sightingIndicator.click();

    // Verify aviation-style navigation information
    await expect(page.locator('[data-testid="aviation-bearing"]')).toBeVisible();
    await expect(page.locator('[data-testid="magnetic-bearing"]')).toBeVisible();
    await expect(page.locator('[data-testid="distance-nautical"]')).toBeVisible();

    // Verify bearing format (should be 3-digit magnetic bearing)
    const bearing = await page.locator('[data-testid="magnetic-bearing"]').textContent();
    expect(bearing).toMatch(/^\d{3}°M$/);

    // Verify distance in nautical miles
    const distance = await page.locator('[data-testid="distance-nautical"]').textContent();
    expect(distance).toMatch(/\d+(\.\d+)?\s*nm/i);

    // Verify radial information (bearing from nearest VOR if available)
    const radialInfo = page.locator('[data-testid="vor-radial"]');
    if (await radialInfo.isVisible()) {
      await expect(radialInfo).toMatch(/R-\d{3}/);
    }
  });

  test('should show altitude bands and flight levels', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Verify altitude tape display
    await expect(page.locator('[data-testid="altitude-tape"]')).toBeVisible();
    await expect(page.locator('[data-testid="current-altitude"]')).toBeVisible();
    await expect(page.locator('[data-testid="altitude-scale"]')).toBeVisible();

    // Verify flight level indicators
    const altitudeTicks = page.locator('[data-testid="altitude-tick"]');
    await expect(altitudeTicks).toHaveCountGreaterThan(5);

    // Check for pressure altitude vs GPS altitude
    await expect(page.locator('[data-testid="pressure-altitude"]')).toBeVisible();
    await expect(page.locator('[data-testid="gps-altitude"]')).toBeVisible();

    // Verify altimeter setting
    await expect(page.locator('[data-testid="altimeter-setting"]')).toBeVisible();
    const baroSetting = await page.locator('[data-testid="baro-setting"]').textContent();
    expect(baroSetting).toMatch(/\d{2}\.\d{2}.*inHg|QNH.*\d{4}/);

    // Test altitude alerting (if available)
    const altitudeAlert = page.locator('[data-testid="altitude-alert"]');
    if (await altitudeAlert.isVisible()) {
      await expect(altitudeAlert).toContainText('ALT');
    }
  });

  test('should provide ILS/GPS approach information for nearby airports', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Open approaches panel
    await page.click('[data-testid="approaches-btn"]');
    await expect(page.locator('[data-testid="approaches-panel"]')).toBeVisible();

    // Wait for airport data to load
    await page.waitForSelector('[data-testid="nearby-airports"]', { timeout: 10000 });

    const airports = page.locator('[data-testid="airport-item"]');
    const airportCount = await airports.count();

    if (airportCount > 0) {
      const firstAirport = airports.first();
      
      // Verify airport information
      await expect(firstAirport.locator('[data-testid="airport-identifier"]')).toBeVisible();
      await expect(firstAirport.locator('[data-testid="airport-name"]')).toBeVisible();
      await expect(firstAirport.locator('[data-testid="airport-distance"]')).toBeVisible();
      await expect(firstAirport.locator('[data-testid="airport-bearing"]')).toBeVisible();

      // Click on airport to see approaches
      await firstAirport.click();
      
      const approaches = page.locator('[data-testid="approach-item"]');
      const approachCount = await approaches.count();
      
      if (approachCount > 0) {
        const firstApproach = approaches.first();
        await expect(firstApproach.locator('[data-testid="approach-type"]')).toBeVisible();
        await expect(firstApproach.locator('[data-testid="runway-identifier"]')).toBeVisible();
        await expect(firstApproach.locator('[data-testid="approach-frequency"]')).toBeVisible();

        // Select approach for navigation
        await firstApproach.click();
        await expect(page.locator('[data-testid="approach-selected"]')).toBeVisible();
        await expect(page.locator('[data-testid="localizer-course"]')).toBeVisible();
      }
    }
  });

  test('should display GPS navigation with waypoints', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    // Create sightings as waypoints
    const waypoint1 = {
      ...TestDataGenerator.generateSighting(),
      title: 'Waypoint Alpha',
      location: { latitude: 37.7849, longitude: -122.4294, address: 'WPT A' }
    };
    
    const waypoint2 = {
      ...TestDataGenerator.generateSighting(),
      title: 'Waypoint Bravo',
      location: { latitude: 37.7949, longitude: -122.4394, address: 'WPT B' }
    };

    await apiHelpers.createTestSighting(waypoint1, token);
    await apiHelpers.createTestSighting(waypoint2, token);

    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Create flight plan
    await page.click('[data-testid="flight-plan-btn"]');
    await expect(page.locator('[data-testid="flight-plan-panel"]')).toBeVisible();

    // Add waypoints to flight plan
    const sightingIndicators = page.locator('[data-testid="sighting-indicator"]');
    await sightingIndicators.first().click();
    await page.click('[data-testid="add-to-flight-plan"]');

    await sightingIndicators.nth(1).click();
    await page.click('[data-testid="add-to-flight-plan"]');

    // Verify flight plan waypoints
    const waypoints = page.locator('[data-testid="waypoint-item"]');
    await expect(waypoints).toHaveCount(2);

    // Start navigation along flight plan
    await page.click('[data-testid="activate-flight-plan"]');

    // Verify GPS navigation is active
    await expect(page.locator('[data-testid="gps-navigation-active"]')).toBeVisible();
    await expect(page.locator('[data-testid="active-waypoint"]')).toBeVisible();
    await expect(page.locator('[data-testid="distance-to-waypoint"]')).toBeVisible();
    await expect(page.locator('[data-testid="bearing-to-waypoint"]')).toBeVisible();
    await expect(page.locator('[data-testid="time-to-waypoint"]')).toBeVisible();

    // Verify CDI (Course Deviation Indicator)
    await expect(page.locator('[data-testid="course-deviation"]')).toBeVisible();
    await expect(page.locator('[data-testid="desired-track"]')).toBeVisible();
    await expect(page.locator('[data-testid="cross-track-error"]')).toBeVisible();
  });

  test('should handle emergency/priority sighting navigation', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    // Create priority sighting
    const emergencySighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'PRIORITY: Military Aircraft Encounter',
      category: 'ufo' as const,
      description: 'Urgent: Multiple witnesses report military response to UFO',
      location: { latitude: 37.8149, longitude: -122.4594, address: 'Priority Area' }
    };

    await apiHelpers.createTestSighting(emergencySighting, token);

    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Look for priority sighting indicators
    await page.waitForSelector('[data-testid="priority-sighting"]', { timeout: 10000 });

    // Verify priority sighting is highlighted
    const prioritySighting = page.locator('[data-testid="priority-sighting"]').first();
    await expect(prioritySighting).toHaveClass(/priority|urgent|emergency/);
    await expect(prioritySighting.locator('[data-testid="priority-indicator"]')).toBeVisible();

    // Select priority sighting
    await prioritySighting.click();

    // Should show emergency navigation options
    await expect(page.locator('[data-testid="emergency-navigation"]')).toBeVisible();
    await expect(page.locator('[data-testid="direct-to-btn"]')).toBeVisible();
    await expect(page.locator('[data-testid="emergency-frequency"]')).toBeVisible();

    // Activate emergency navigation
    await page.click('[data-testid="direct-to-btn"]');

    // Verify emergency mode is active
    await expect(page.locator('[data-testid="emergency-mode-active"]')).toBeVisible();
    await expect(page.locator('[data-testid="emergency-course"]')).toBeVisible();
    await expect(page.locator('[data-testid="emergency-distance"]')).toBeVisible();

    // Should show recommended actions
    await expect(page.locator('[data-testid="emergency-instructions"]')).toBeVisible();
    await expect(page.locator('[data-testid="contact-atc-btn"]')).toBeVisible();
  });

  test('should display radio frequencies and communication info', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Open communication panel
    await page.click('[data-testid="radio-panel-btn"]');
    await expect(page.locator('[data-testid="radio-frequencies"]')).toBeVisible();

    // Verify common aviation frequencies
    await expect(page.locator('[data-testid="ground-frequency"]')).toBeVisible();
    await expect(page.locator('[data-testid="tower-frequency"]')).toBeVisible();
    await expect(page.locator('[data-testid="approach-frequency"]')).toBeVisible();
    await expect(page.locator('[data-testid="emergency-frequency"]')).toContainText('121.5');

    // Check for local frequencies based on location
    const localFreqs = page.locator('[data-testid="local-frequencies"]');
    if (await localFreqs.isVisible()) {
      await expect(localFreqs.locator('[data-testid="ctaf-frequency"]')).toBeVisible();
      await expect(localFreqs.locator('[data-testid="unicom-frequency"]')).toBeVisible();
    }

    // Verify frequency format
    const frequencies = await page.locator('[data-testid="frequency-value"]').allTextContents();
    for (const freq of frequencies) {
      expect(freq).toMatch(/^\d{3}\.\d{2,3}$/); // Aviation frequency format
    }

    // Test frequency selection
    await page.click('[data-testid="frequency-item"]').first();
    await expect(page.locator('[data-testid="active-frequency"]')).toBeVisible();
  });

  test('should integrate with sectional chart overlay', async ({ page }) => {
    await page.goto('/compass');
    await page.click('[data-testid="pilot-mode-toggle"]');

    // Enable sectional chart overlay
    await page.click('[data-testid="chart-overlay-btn"]');
    await page.selectOption('[data-testid="chart-type"]', 'sectional');
    await page.click('[data-testid="enable-overlay"]');

    // Verify sectional chart is displayed
    await expect(page.locator('[data-testid="sectional-overlay"]')).toBeVisible();

    // Verify chart features are visible
    await expect(page.locator('[data-testid="controlled-airspace-overlay"]')).toBeVisible();
    await expect(page.locator('[data-testid="airport-symbols"]')).toBeVisible();
    
    // Check for navigation aids
    const navAids = page.locator('[data-testid="nav-aid-symbol"]');
    if (await navAids.count() > 0) {
      const firstNavAid = navAids.first();
      await firstNavAid.hover();
      await expect(page.locator('[data-testid="nav-aid-info"]')).toBeVisible();
    }

    // Verify chart opacity control
    await page.locator('[data-testid="chart-opacity-slider"]').fill('50');
    
    // Test chart pan/zoom
    const chartOverlay = page.locator('[data-testid="sectional-overlay"]');
    await chartOverlay.hover();
    await page.mouse.wheel(0, -100); // Zoom in
    await page.waitForTimeout(500);
    
    // Chart should still be visible after zoom
    await expect(chartOverlay).toBeVisible();
  });

  test.afterEach(async ({ request }) => {
    // Cleanup test data
    if (testUser && apiHelpers) {
      const token = await apiHelpers.loginUser(testUser.email, testUser.password);
      await apiHelpers.cleanupTestData(token, []);
    }
  });
});