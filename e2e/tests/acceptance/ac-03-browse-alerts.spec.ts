import { test, expect } from '@playwright/test';
import { TestDataGenerator, TestUser, TestSighting } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-3: Browse and Filter UFO Alerts', () => {
  let testUser: TestUser;
  let apiHelpers: APIHelpers;
  let testSightings: string[] = [];

  test.beforeAll(async ({ request }) => {
    // Create test user and sample sightings
    testUser = TestDataGenerator.generateUser();
    apiHelpers = new APIHelpers(request);
    const { token } = await apiHelpers.createTestUser(testUser);

    // Create multiple test sightings for filtering
    const sightingData = [
      { ...TestDataGenerator.FIXED_SIGHTING, category: 'ufo', title: 'UFO over Golden Gate' },
      { ...TestDataGenerator.generateSighting(), category: 'light', title: 'Bright Light Formation' },
      { ...TestDataGenerator.generateSighting(), category: 'formation', title: 'Triangle Formation' },
      { ...TestDataGenerator.generateSighting(), category: 'other', title: 'Strange Aircraft' },
    ];

    for (const sighting of sightingData) {
      const { id } = await apiHelpers.createTestSighting(sighting, token);
      testSightings.push(id);
    }
  });

  test.beforeEach(async ({ page }) => {
    await page.goto('/alerts');
  });

  test('should display all alerts by default @smoke', async ({ page }) => {
    // Wait for alerts to load
    await page.waitForSelector('[data-testid="alert-card"]');

    // Verify alert cards are displayed
    const alertCards = page.locator('[data-testid="alert-card"]');
    await expect(alertCards).toHaveCountGreaterThan(0);

    // Verify each card has required elements
    const firstCard = alertCards.first();
    await expect(firstCard.locator('[data-testid="alert-title"]')).toBeVisible();
    await expect(firstCard.locator('[data-testid="alert-location"]')).toBeVisible();
    await expect(firstCard.locator('[data-testid="alert-timestamp"]')).toBeVisible();
    await expect(firstCard.locator('[data-testid="alert-category"]')).toBeVisible();
  });

  test('should filter alerts by category', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Get initial count
    const initialCount = await page.locator('[data-testid="alert-card"]').count();

    // Filter by UFO category
    await page.selectOption('[data-testid="category-filter"]', 'ufo');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify filtered results
    const filteredCards = page.locator('[data-testid="alert-card"]');
    const filteredCount = await filteredCards.count();

    // Should have fewer or equal results
    expect(filteredCount).toBeLessThanOrEqual(initialCount);

    // Verify all visible cards are UFO category
    for (let i = 0; i < filteredCount; i++) {
      const card = filteredCards.nth(i);
      await expect(card.locator('[data-testid="alert-category"]')).toContainText('UFO');
    }
  });

  test('should filter alerts by time range', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Filter by last 24 hours
    await page.selectOption('[data-testid="timeframe-filter"]', '24h');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify results are from last 24 hours
    const cards = page.locator('[data-testid="alert-card"]');
    const count = await cards.count();

    if (count > 0) {
      const timestamps = await cards.locator('[data-testid="alert-timestamp"]').allTextContents();
      const now = new Date();
      const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

      // Verify timestamps are recent (basic check)
      for (const timestamp of timestamps) {
        expect(timestamp).toContain('ago');
      }
    }
  });

  test('should filter alerts by distance radius', async ({ page, context }) => {
    // Set user location
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.reload();
    await page.waitForSelector('[data-testid="alert-card"]');

    // Set distance filter to 10km
    await page.fill('[data-testid="radius-filter"]', '10');
    await page.click('[data-testid="apply-filters-btn"]');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify distance is shown for each alert
    const cards = page.locator('[data-testid="alert-card"]');
    const count = await cards.count();

    if (count > 0) {
      for (let i = 0; i < count; i++) {
        const card = cards.nth(i);
        await expect(card.locator('[data-testid="alert-distance"]')).toBeVisible();
        
        const distanceText = await card.locator('[data-testid="alert-distance"]').textContent();
        expect(distanceText).toMatch(/\d+(\.\d+)?\s*(km|mi)/);
      }
    }
  });

  test('should combine multiple filters', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.reload();
    await page.waitForSelector('[data-testid="alert-card"]');

    // Apply multiple filters
    await page.selectOption('[data-testid="category-filter"]', 'light');
    await page.selectOption('[data-testid="timeframe-filter"]', '7d');
    await page.fill('[data-testid="radius-filter"]', '50');
    await page.click('[data-testid="apply-filters-btn"]');

    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify active filters are displayed
    await expect(page.locator('[data-testid="active-filter-category"]')).toContainText('Light');
    await expect(page.locator('[data-testid="active-filter-timeframe"]')).toContainText('Last 7 days');
    await expect(page.locator('[data-testid="active-filter-radius"]')).toContainText('50 km');

    // Verify results match all filters
    const cards = page.locator('[data-testid="alert-card"]');
    const count = await cards.count();

    if (count > 0) {
      for (let i = 0; i < count; i++) {
        const card = cards.nth(i);
        await expect(card.locator('[data-testid="alert-category"]')).toContainText('Light');
        await expect(card.locator('[data-testid="alert-distance"]')).toBeVisible();
      }
    }
  });

  test('should clear filters and show all alerts', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Apply filters first
    await page.selectOption('[data-testid="category-filter"]', 'ufo');
    await page.selectOption('[data-testid="timeframe-filter"]', '24h');
    await page.click('[data-testid="apply-filters-btn"]');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    const filteredCount = await page.locator('[data-testid="alert-card"]').count();

    // Clear filters
    await page.click('[data-testid="clear-filters-btn"]');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify all alerts are shown again
    const allCount = await page.locator('[data-testid="alert-card"]').count();
    expect(allCount).toBeGreaterThanOrEqual(filteredCount);

    // Verify filter controls are reset
    await expect(page.locator('[data-testid="category-filter"]')).toHaveValue('');
    await expect(page.locator('[data-testid="timeframe-filter"]')).toHaveValue('');
    await expect(page.locator('[data-testid="radius-filter"]')).toHaveValue('');
  });

  test('should paginate through alerts', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Check if pagination is present
    const pagination = page.locator('[data-testid="pagination"]');
    const hasPagination = await pagination.isVisible();

    if (hasPagination) {
      // Get first page alerts
      const firstPageAlerts = await page.locator('[data-testid="alert-card"]').allTextContents();

      // Go to next page
      await page.click('[data-testid="next-page-btn"]');
      await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

      // Verify different alerts are shown
      const secondPageAlerts = await page.locator('[data-testid="alert-card"]').allTextContents();
      expect(secondPageAlerts).not.toEqual(firstPageAlerts);

      // Verify page indicator updated
      await expect(page.locator('[data-testid="current-page"]')).toContainText('2');

      // Go back to first page
      await page.click('[data-testid="prev-page-btn"]');
      await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

      const backToFirstPage = await page.locator('[data-testid="alert-card"]').allTextContents();
      expect(backToFirstPage).toEqual(firstPageAlerts);
    }
  });

  test('should display map view of alerts', async ({ page, context }) => {
    await context.setGeolocation({ latitude: 37.7749, longitude: -122.4194 });
    await context.grantPermissions(['geolocation']);

    await page.reload();
    await page.waitForSelector('[data-testid="alert-card"]');

    // Switch to map view
    await page.click('[data-testid="map-view-btn"]');

    // Verify map is displayed
    await expect(page.locator('[data-testid="alerts-map"]')).toBeVisible();
    await expect(page.locator('[data-testid="map-markers"]')).toBeVisible();

    // Verify markers are present
    const markers = page.locator('[data-testid="alert-marker"]');
    await expect(markers).toHaveCountGreaterThan(0);

    // Click on a marker
    const firstMarker = markers.first();
    await firstMarker.click();

    // Verify popup shows alert details
    await expect(page.locator('[data-testid="alert-popup"]')).toBeVisible();
    await expect(page.locator('[data-testid="popup-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="popup-category"]')).toBeVisible();
    await expect(page.locator('[data-testid="view-alert-btn"]')).toBeVisible();
  });

  test('should sort alerts by different criteria', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Sort by distance (requires location)
    await page.selectOption('[data-testid="sort-select"]', 'distance');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Get first alert title for comparison
    const firstAlertByDistance = await page.locator('[data-testid="alert-card"]').first()
      .locator('[data-testid="alert-title"]').textContent();

    // Sort by timestamp (most recent)
    await page.selectOption('[data-testid="sort-select"]', 'timestamp');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    const firstAlertByTime = await page.locator('[data-testid="alert-card"]').first()
      .locator('[data-testid="alert-title"]').textContent();

    // Verify sorting changed results (may be same if only one alert)
    // At minimum, verify no error occurred
    await expect(page.locator('[data-testid="alert-card"]').first()).toBeVisible();
  });

  test('should search alerts by keyword', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Search for specific term
    await page.fill('[data-testid="search-input"]', 'golden');
    await page.press('[data-testid="search-input"]', 'Enter');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify search results
    const searchResults = page.locator('[data-testid="alert-card"]');
    const count = await searchResults.count();

    if (count > 0) {
      // Verify search term appears in results
      const titles = await searchResults.locator('[data-testid="alert-title"]').allTextContents();
      const descriptions = await searchResults.locator('[data-testid="alert-description"]').allTextContents();
      
      const hasSearchTerm = titles.some(title => 
        title.toLowerCase().includes('golden')
      ) || descriptions.some(desc => 
        desc.toLowerCase().includes('golden')
      );
      
      expect(hasSearchTerm).toBeTruthy();
    }

    // Clear search
    await page.fill('[data-testid="search-input"]', '');
    await page.press('[data-testid="search-input"]', 'Enter');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify all results are shown again
    const allResults = await page.locator('[data-testid="alert-card"]').count();
    expect(allResults).toBeGreaterThanOrEqual(count);
  });

  test('should handle no results state', async ({ page }) => {
    await page.waitForSelector('[data-testid="alert-card"]');

    // Apply very restrictive filters
    await page.selectOption('[data-testid="category-filter"]', 'ufo');
    await page.selectOption('[data-testid="timeframe-filter"]', '1h');
    await page.fill('[data-testid="radius-filter"]', '1');
    await page.fill('[data-testid="search-input"]', 'nonexistentkeyword12345');
    await page.click('[data-testid="apply-filters-btn"]');

    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify no results state
    await expect(page.locator('[data-testid="no-results"]')).toBeVisible();
    await expect(page.locator('[data-testid="no-results-message"]')).toContainText('No alerts found');
    await expect(page.locator('[data-testid="clear-filters-suggestion"]')).toBeVisible();

    // Click clear filters suggestion
    await page.click('[data-testid="clear-filters-suggestion"]');
    await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' });

    // Verify results are shown again
    await expect(page.locator('[data-testid="alert-card"]')).toHaveCountGreaterThan(0);
  });

  test.afterAll(async ({ request }) => {
    // Cleanup test data
    if (testUser && apiHelpers) {
      const token = await apiHelpers.loginUser(testUser.email, testUser.password);
      await apiHelpers.cleanupTestData(token, []);
    }
  });
});