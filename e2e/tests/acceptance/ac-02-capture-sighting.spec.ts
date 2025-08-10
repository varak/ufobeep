import { test, expect } from '@playwright/test';
import { TestDataGenerator, TestUser, TestSighting } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-2: Capture and Report UFO Sighting', () => {
  let testUser: TestUser;
  let apiHelpers: APIHelpers;

  test.beforeEach(async ({ page, request }) => {
    testUser = TestDataGenerator.generateUser();
    apiHelpers = new APIHelpers(request);
    
    // Create and login user
    await apiHelpers.createTestUser(testUser);
    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');
    await page.waitForURL('**/dashboard');
  });

  test('should allow user to capture sighting with location @smoke @critical', async ({ page, context }) => {
    // Grant location permission
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    // Navigate to sighting capture
    await page.click('[data-testid="capture-sighting-btn"]');
    await page.waitForURL('**/capture');

    // Verify location is captured
    await page.waitForSelector('[data-testid="location-status"]');
    await expect(page.locator('[data-testid="location-status"]')).toContainText('Location acquired');

    // Fill sighting details
    const sighting = TestDataGenerator.generateSighting();
    await page.fill('[data-testid="sighting-title"]', sighting.title);
    await page.fill('[data-testid="sighting-description"]', sighting.description);
    await page.selectOption('[data-testid="category-select"]', sighting.category);

    // Set compass heading using slider
    await page.click('[data-testid="compass-input"]');
    await page.fill('[data-testid="compass-input"]', sighting.compass.toString());

    // Set elevation angle
    await page.fill('[data-testid="elevation-input"]', sighting.elevation.toString());

    // Submit sighting
    await page.click('[data-testid="submit-sighting-btn"]');

    // Verify success
    await page.waitForSelector('[data-testid="success-message"]');
    await expect(page.locator('[data-testid="success-message"]')).toContainText('Sighting reported successfully');

    // Verify redirect to sighting detail
    await page.waitForURL('**/sighting/**');
    await expect(page.locator('[data-testid="sighting-title"]')).toContainText(sighting.title);
    await expect(page.locator('[data-testid="sighting-description"]')).toContainText(sighting.description);
  });

  test('should allow photo upload with sighting', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/capture');
    
    // Fill basic details
    await page.fill('[data-testid="sighting-title"]', 'Test Sighting with Photo');
    await page.fill('[data-testid="sighting-description"]', 'UFO sighting with photo evidence');
    await page.selectOption('[data-testid="category-select"]', 'ufo');

    // Upload photo (simulate file selection)
    const fileInput = page.locator('[data-testid="photo-upload"]');
    await fileInput.setInputFiles({
      name: 'ufo-photo.jpg',
      mimeType: 'image/jpeg',
      buffer: Buffer.from('fake-image-data')
    });

    // Verify photo preview
    await expect(page.locator('[data-testid="photo-preview"]')).toBeVisible();
    await expect(page.locator('[data-testid="photo-filename"]')).toContainText('ufo-photo.jpg');

    await page.fill('[data-testid="compass-input"]', '180');
    await page.fill('[data-testid="elevation-input"]', '45');

    await page.click('[data-testid="submit-sighting-btn"]');

    // Verify photo is displayed in sighting detail
    await page.waitForURL('**/sighting/**');
    await expect(page.locator('[data-testid="sighting-photo"]')).toBeVisible();
  });

  test('should validate required fields for sighting capture', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/capture');

    // Try to submit empty form
    await page.click('[data-testid="submit-sighting-btn"]');

    // Verify validation errors
    await expect(page.locator('[data-testid="title-error"]')).toContainText('Title is required');
    await expect(page.locator('[data-testid="description-error"]')).toContainText('Description is required');
    await expect(page.locator('[data-testid="category-error"]')).toContainText('Category is required');

    // Test title length validation
    await page.fill('[data-testid="sighting-title"]', 'x'.repeat(101));
    await page.click('[data-testid="submit-sighting-btn"]');
    await expect(page.locator('[data-testid="title-error"]')).toContainText('Title must be 100 characters or less');

    // Test description length validation
    await page.fill('[data-testid="sighting-title"]', 'Valid Title');
    await page.fill('[data-testid="sighting-description"]', 'x'.repeat(2001));
    await page.click('[data-testid="submit-sighting-btn"]');
    await expect(page.locator('[data-testid="description-error"]')).toContainText('Description must be 2000 characters or less');
  });

  test('should handle location permission denied', async ({ page, context }) => {
    // Deny location permission
    await context.setGeolocation({ latitude: 0, longitude: 0 });
    await context.grantPermissions([]);

    await page.goto('/capture');

    // Verify location error message
    await expect(page.locator('[data-testid="location-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="location-error"]')).toContainText('Location access required');

    // Should allow manual location entry
    await page.click('[data-testid="manual-location-btn"]');
    await page.fill('[data-testid="manual-latitude"]', '37.7749');
    await page.fill('[data-testid="manual-longitude"]', '-122.4194');
    await page.click('[data-testid="confirm-location-btn"]');

    // Verify location status updated
    await expect(page.locator('[data-testid="location-status"]')).toContainText('Manual location set');
  });

  test('should save draft and restore sighting data', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/capture');

    // Fill partial form
    const title = 'Draft Sighting Test';
    const description = 'This is a draft sighting that should be saved';
    
    await page.fill('[data-testid="sighting-title"]', title);
    await page.fill('[data-testid="sighting-description"]', description);
    await page.selectOption('[data-testid="category-select"]', 'light');

    // Save as draft
    await page.click('[data-testid="save-draft-btn"]');
    await expect(page.locator('[data-testid="draft-saved-message"]')).toBeVisible();

    // Navigate away and back
    await page.goto('/dashboard');
    await page.goto('/capture');

    // Verify draft is restored
    await expect(page.locator('[data-testid="draft-restored-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="sighting-title"]')).toHaveValue(title);
    await expect(page.locator('[data-testid="sighting-description"]')).toHaveValue(description);
    await expect(page.locator('[data-testid="category-select"]')).toHaveValue('light');
  });

  test('should display compass with current heading @visual', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/capture');

    // Verify compass component is visible
    await expect(page.locator('[data-testid="compass-component"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-needle"]')).toBeVisible();
    await expect(page.locator('[data-testid="compass-degrees"]')).toBeVisible();

    // Test manual compass adjustment
    await page.click('[data-testid="compass-component"]');
    await page.mouse.move(400, 300); // Simulate compass drag
    
    // Verify compass value updates
    const compassValue = await page.locator('[data-testid="compass-input"]').inputValue();
    expect(parseInt(compassValue)).toBeGreaterThanOrEqual(0);
    expect(parseInt(compassValue)).toBeLessThanOrEqual(359);
  });

  test('should handle offline sighting capture', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    // Simulate offline mode
    await context.setOffline(true);

    await page.goto('/capture');

    // Fill sighting form
    await page.fill('[data-testid="sighting-title"]', 'Offline Sighting');
    await page.fill('[data-testid="sighting-description"]', 'Captured while offline');
    await page.selectOption('[data-testid="category-select"]', 'formation');
    await page.fill('[data-testid="compass-input"]', '90');
    await page.fill('[data-testid="elevation-input"]', '30');

    // Submit sighting
    await page.click('[data-testid="submit-sighting-btn"]');

    // Verify offline message
    await expect(page.locator('[data-testid="offline-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="offline-message"]')).toContainText('Sighting saved locally');

    // Go back online
    await context.setOffline(false);

    // Verify sync notification
    await page.reload();
    await expect(page.locator('[data-testid="sync-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="sync-message"]')).toContainText('Offline sightings synced');
  });

  test('should show enrichment data after sighting submission', async ({ page, context, request }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.goto('/capture');

    // Submit a sighting
    await page.fill('[data-testid="sighting-title"]', 'Enrichment Test Sighting');
    await page.fill('[data-testid="sighting-description"]', 'Testing enrichment data display');
    await page.selectOption('[data-testid="category-select"]', 'ufo');
    await page.fill('[data-testid="compass-input"]', '270');
    await page.fill('[data-testid="elevation-input"]', '60');

    await page.click('[data-testid="submit-sighting-btn"]');
    await page.waitForURL('**/sighting/**');

    // Wait for enrichment data to load
    await page.waitForSelector('[data-testid="enrichment-section"]', { timeout: 10000 });

    // Verify enrichment sections are present
    await expect(page.locator('[data-testid="weather-data"]')).toBeVisible();
    await expect(page.locator('[data-testid="celestial-data"]')).toBeVisible();
    await expect(page.locator('[data-testid="aircraft-data"]')).toBeVisible();

    // Verify weather data display
    await expect(page.locator('[data-testid="weather-temperature"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-visibility"]')).toBeVisible();
    await expect(page.locator('[data-testid="weather-conditions"]')).toBeVisible();

    // Verify celestial data
    await expect(page.locator('[data-testid="sun-position"]')).toBeVisible();
    await expect(page.locator('[data-testid="moon-phase"]')).toBeVisible();
  });
});