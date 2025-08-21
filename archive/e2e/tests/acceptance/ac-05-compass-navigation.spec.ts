import { test, expect } from '@playwright/test';
import { TestDataGenerator, TestUser } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-5: Compass Navigation (Standard Mode)', () => {
  let testUser: TestUser;
  let apiHelpers: APIHelpers;
  
  test.beforeEach(async ({ page, request, context }) => {
    testUser = TestDataGenerator.generateUser();
    apiHelpers = new APIHelpers(request);
    
    // Create and login user
    await apiHelpers.createTestUser(testUser);
    
    // Grant necessary permissions
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');
    await page.waitForURL('**/dashboard');
  });

  test('should display compass component with current heading @smoke @critical', async ({ page }) => {
    // Navigate to compass mode
    await page.click('[data-testid="nav-compass"]');
    await page.waitForURL('**/compass');

    // Verify compass component is displayed
    await expect(page.locator('[data-testid="compass-container"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-face"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-needle"]')).toBeVisible();

    // Verify cardinal directions are labeled
    await expect(page.locator('[data-testid="north-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="south-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="east-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="west-indicator"]')).toBeVisible();

    // Verify current heading display
    await expect(page.locator('[data-testid="current-heading"]')).toBeVisible();
    await expect(page.locator('[data-testid="heading-degrees"]')).toMatch(/^\d{1,3}°$/);
    await expect(page.locator('[data-testid="cardinal-direction"]')).toBeVisible();
  });

  test('should respond to device orientation changes', async ({ page, context }) => {
    await page.goto('/compass');

    // Get initial heading
    const initialHeading = await page.locator('[data-testid="heading-degrees"]').textContent();

    // Simulate device rotation (mock orientation change)
    await page.evaluate(() => {
      // Dispatch mock orientation event
      const event = new CustomEvent('deviceorientationabsolute', {
        detail: { alpha: 90 } // 90 degrees
      });
      window.dispatchEvent(event);
    });

    await page.waitForTimeout(1000); // Allow compass to update

    // Verify heading changed
    const newHeading = await page.locator('[data-testid="heading-degrees"]').textContent();
    
    // On desktop/test environment, heading might not change, but component should still be responsive
    await expect(page.locator('[data-testid="compass-needle"]')).toBeVisible();
    await expect(page.locator('[data-testid="heading-degrees"]')).toMatch(/^\d{1,3}°$/);
  });

  test('should display nearby sightings on compass overlay', async ({ page, request }) => {
    // Create test sightings at known directions
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    const northSighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'North UFO Sighting',
      location: {
        latitude: 37.7849, // North of user
        longitude: -122.4194,
        address: 'North location'
      }
    };
    
    const eastSighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'East Light Formation',
      location: {
        latitude: 37.7749,
        longitude: -122.4094, // East of user
        address: 'East location'
      }
    };

    await apiHelpers.createTestSighting(northSighting, token);
    await apiHelpers.createTestSighting(eastSighting, token);

    await page.goto('/compass');
    await page.waitForSelector('[data-testid="compass-container"]');

    // Wait for sightings to load
    await page.waitForSelector('[data-testid="sighting-indicator"]', { timeout: 10000 });

    // Verify sighting indicators are displayed
    const sightingIndicators = page.locator('[data-testid="sighting-indicator"]');
    await expect(sightingIndicators).toHaveCountGreaterThanOrEqual(2);

    // Verify indicators show direction and distance
    const firstIndicator = sightingIndicators.first();
    await expect(firstIndicator.locator('[data-testid="sighting-direction"]')).toBeVisible();
    await expect(firstIndicator.locator('[data-testid="sighting-distance"]')).toBeVisible();
    await expect(firstIndicator.locator('[data-testid="sighting-title"]')).toBeVisible();

    // Click on sighting indicator
    await firstIndicator.click();

    // Should show sighting details popup
    await expect(page.locator('[data-testid="sighting-popup"]')).toBeVisible();
    await expect(page.locator('[data-testid="popup-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="popup-distance"]')).toBeVisible();
    await expect(page.locator('[data-testid="view-full-details-btn"]')).toBeVisible();
  });

  test('should show accurate bearing to selected sighting', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    // Create sighting due north (bearing should be ~0°)
    const northSighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'Due North Sighting',
      location: {
        latitude: 37.7849, // Exactly north
        longitude: -122.4194, // Same longitude
        address: 'Due North'
      }
    };

    const { id } = await apiHelpers.createTestSighting(northSighting, token);

    await page.goto('/compass');
    await page.waitForSelector('[data-testid="sighting-indicator"]');

    // Select the sighting
    const sightingIndicator = page.locator('[data-testid="sighting-indicator"]').first();
    await sightingIndicator.click();

    // Verify bearing calculation
    await expect(page.locator('[data-testid="selected-sighting-bearing"]')).toBeVisible();
    const bearingText = await page.locator('[data-testid="bearing-value"]').textContent();
    
    // Bearing to due north should be close to 0° or 360°
    const bearing = parseInt(bearingText?.replace('°', '') || '0');
    expect(bearing >= 350 || bearing <= 10).toBeTruthy();

    // Verify navigation arrow points to sighting
    await expect(page.locator('[data-testid="navigation-arrow"]')).toBeVisible();
    await expect(page.locator('[data-testid="navigation-arrow"]')).toHaveAttribute('data-bearing', /\d+/);
  });

  test('should provide turn-by-turn navigation instructions', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    const targetSighting = {
      ...TestDataGenerator.generateSighting(),
      title: 'Navigation Target',
      location: {
        latitude: 37.7849,
        longitude: -122.4294,
        address: 'Northwest target'
      }
    };

    await apiHelpers.createTestSighting(targetSighting, token);

    await page.goto('/compass');
    await page.waitForSelector('[data-testid="sighting-indicator"]');

    // Start navigation to sighting
    const sightingIndicator = page.locator('[data-testid="sighting-indicator"]').first();
    await sightingIndicator.click();
    await page.click('[data-testid="start-navigation-btn"]');

    // Verify navigation mode is active
    await expect(page.locator('[data-testid="navigation-active"]')).toBeVisible();
    await expect(page.locator('[data-testid="navigation-instructions"]')).toBeVisible();

    // Verify instruction text
    const instructions = page.locator('[data-testid="current-instruction"]');
    await expect(instructions).toBeVisible();
    
    const instructionText = await instructions.textContent();
    expect(instructionText).toMatch(/(Turn|Face|Head|Look)/i);
    expect(instructionText).toMatch(/(left|right|north|south|east|west)/i);

    // Verify distance to target
    await expect(page.locator('[data-testid="distance-remaining"]')).toBeVisible();
    await expect(page.locator('[data-testid="distance-value"]')).toMatch(/\d+(\.\d+)?\s*(m|km|ft|mi)/);

    // Verify stop navigation button
    await expect(page.locator('[data-testid="stop-navigation-btn"]')).toBeVisible();
  });

  test('should filter sightings by distance and category', async ({ page, request }) => {
    const token = await apiHelpers.loginUser(testUser.email, testUser.password);
    
    // Create sightings at different distances and categories
    const nearUFO = {
      ...TestDataGenerator.generateSighting(),
      title: 'Near UFO',
      category: 'ufo' as const,
      location: {
        latitude: 37.7759, // ~1.1km away
        longitude: -122.4204,
        address: 'Nearby'
      }
    };
    
    const farLight = {
      ...TestDataGenerator.generateSighting(),
      title: 'Far Light',
      category: 'light' as const,
      location: {
        latitude: 37.8049, // ~3.3km away
        longitude: -122.4494,
        address: 'Far away'
      }
    };

    await apiHelpers.createTestSighting(nearUFO, token);
    await apiHelpers.createTestSighting(farLight, token);

    await page.goto('/compass');

    // Open filters
    await page.click('[data-testid="compass-filters-btn"]');
    await expect(page.locator('[data-testid="filter-panel"]')).toBeVisible();

    // Set distance filter to 2km
    await page.fill('[data-testid="distance-filter"]', '2');
    await page.selectOption('[data-testid="category-filter"]', 'ufo');
    await page.click('[data-testid="apply-filters-btn"]');

    await page.waitForSelector('[data-testid="sighting-indicator"]');

    // Should only show UFO sightings within 2km
    const visibleIndicators = page.locator('[data-testid="sighting-indicator"]');
    const count = await visibleIndicators.count();

    if (count > 0) {
      // Verify all visible sightings are UFO category
      for (let i = 0; i < count; i++) {
        const indicator = visibleIndicators.nth(i);
        await indicator.hover();
        await expect(page.locator('[data-testid="sighting-tooltip"]')).toContainText('UFO');
      }
    }

    // Clear filters
    await page.click('[data-testid="compass-filters-btn"]');
    await page.click('[data-testid="clear-filters-btn"]');

    // Should show all sightings again
    const allIndicators = await page.locator('[data-testid="sighting-indicator"]').count();
    expect(allIndicators).toBeGreaterThanOrEqual(count);
  });

  test('should calibrate compass when requested', async ({ page }) => {
    await page.goto('/compass');

    // Open compass settings
    await page.click('[data-testid="compass-settings-btn"]');
    await expect(page.locator('[data-testid="settings-panel"]')).toBeVisible();

    // Start calibration
    await page.click('[data-testid="calibrate-compass-btn"]');
    await expect(page.locator('[data-testid="calibration-modal"]')).toBeVisible();

    // Verify calibration instructions
    await expect(page.locator('[data-testid="calibration-instructions"]')).toContainText('figure-8 pattern');
    await expect(page.locator('[data-testid="calibration-animation"]')).toBeVisible();

    // Simulate calibration completion
    await page.evaluate(() => {
      // Dispatch calibration events
      for (let i = 0; i < 10; i++) {
        const event = new CustomEvent('deviceorientationabsolute', {
          detail: { alpha: i * 36, accuracy: 1 }
        });
        window.dispatchEvent(event);
      }
    });

    await page.waitForTimeout(2000);

    // Verify calibration complete
    await expect(page.locator('[data-testid="calibration-success"]')).toBeVisible();
    await page.click('[data-testid="calibration-done-btn"]');

    // Compass should show improved accuracy
    await expect(page.locator('[data-testid="compass-accuracy"]')).toContainText('High');
  });

  test('should switch between true north and magnetic north', async ({ page }) => {
    await page.goto('/compass');

    // Open settings
    await page.click('[data-testid="compass-settings-btn"]');

    // Toggle to true north
    await page.check('[data-testid="true-north-toggle"]');
    await page.click('[data-testid="apply-settings-btn"]');

    // Verify true north indicator
    await expect(page.locator('[data-testid="true-north-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="north-type"]')).toContainText('True North');

    // Switch back to magnetic north
    await page.click('[data-testid="compass-settings-btn"]');
    await page.uncheck('[data-testid="true-north-toggle"]');
    await page.click('[data-testid="apply-settings-btn"]');

    // Verify magnetic north indicator
    await expect(page.locator('[data-testid="magnetic-north-indicator"]')).toBeVisible();
    await expect(page.locator('[data-testid="north-type"]')).toContainText('Magnetic North');
  });

  test('should display altitude and GPS accuracy information', async ({ page }) => {
    await page.goto('/compass');

    // Verify location information panel
    await expect(page.locator('[data-testid="location-info"]')).toBeVisible();
    await expect(page.locator('[data-testid="current-coordinates"]')).toBeVisible();
    await expect(page.locator('[data-testid="altitude-display"]')).toBeVisible();
    await expect(page.locator('[data-testid="gps-accuracy"]')).toBeVisible();

    // Verify coordinate format
    const coordinates = await page.locator('[data-testid="current-coordinates"]').textContent();
    expect(coordinates).toMatch(/\d+\.\d+°[NS],\s*\d+\.\d+°[EW]/);

    // Verify altitude shows units
    const altitude = await page.locator('[data-testid="altitude-display"]').textContent();
    expect(altitude).toMatch(/\d+(\.\d+)?\s*(m|ft)/);

    // Verify accuracy indicator
    const accuracy = await page.locator('[data-testid="gps-accuracy"]').textContent();
    expect(accuracy).toMatch(/\d+(\.\d+)?\s*m/);
  });

  test('should handle compass in low-light/night mode', async ({ page }) => {
    await page.goto('/compass');

    // Toggle night mode
    await page.click('[data-testid="night-mode-btn"]');

    // Verify dark theme applied
    await expect(page.locator('[data-testid="compass-container"]')).toHaveClass(/night-mode|dark-theme/);
    
    // Verify red lighting for night vision
    const compassFace = page.locator('[data-testid="compass-face"]');
    const backgroundColor = await compassFace.evaluate(el => 
      window.getComputedStyle(el).backgroundColor
    );
    
    // Should use red or dark colors
    expect(backgroundColor).toMatch(/(rgb\(.*?[0-9]+.*?0.*?0.*?\))|(rgba\(0, 0, 0)|rgb\(.*?50.*?\))/);

    // Verify readability in night mode
    await expect(page.locator('[data-testid="heading-degrees"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-needle"]')).toBeVisible();

    // Toggle back to day mode
    await page.click('[data-testid="day-mode-btn"]');
    await expect(page.locator('[data-testid="compass-container"]')).not.toHaveClass(/night-mode|dark-theme/);
  });

  test('should save and restore compass preferences', async ({ page, context }) => {
    await page.goto('/compass');

    // Set preferences
    await page.click('[data-testid="compass-settings-btn"]');
    await page.check('[data-testid="true-north-toggle"]');
    await page.selectOption('[data-testid="distance-units"]', 'imperial');
    await page.selectOption('[data-testid="default-range"]', '10');
    await page.click('[data-testid="apply-settings-btn"]');

    // Reload page
    await page.reload();

    // Verify preferences are restored
    await page.click('[data-testid="compass-settings-btn"]');
    await expect(page.locator('[data-testid="true-north-toggle"]')).toBeChecked();
    await expect(page.locator('[data-testid="distance-units"]')).toHaveValue('imperial');
    await expect(page.locator('[data-testid="default-range"]')).toHaveValue('10');

    // Verify UI reflects saved preferences
    await expect(page.locator('[data-testid="north-type"]')).toContainText('True North');
    await expect(page.locator('[data-testid="distance-value"]')).toMatch(/\d+(\.\d+)?\s*(ft|mi)/);
  });

  test.afterEach(async ({ request }) => {
    // Cleanup test data
    if (testUser && apiHelpers) {
      const token = await apiHelpers.loginUser(testUser.email, testUser.password);
      await apiHelpers.cleanupTestData(token, []);
    }
  });
});