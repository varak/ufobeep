import { test, expect } from '@playwright/test';
import { TestDataGenerator } from '../utils/test-data';
import { APIHelpers } from '../utils/api-helpers';

test.describe('AC-1: User Registration and Profile Setup', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should allow new user registration with email @smoke @critical', async ({ 
    page, 
    request 
  }) => {
    const testUser = TestDataGenerator.generateUser();
    const apiHelpers = new APIHelpers(request);

    // Navigate to registration
    await page.click('[data-testid="register-btn"]');
    await page.waitForURL('**/register');

    // Fill registration form
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.fill('[data-testid="confirm-password-input"]', testUser.password);
    await page.fill('[data-testid="first-name-input"]', testUser.firstName);
    await page.fill('[data-testid="last-name-input"]', testUser.lastName);
    await page.fill('[data-testid="phone-input"]', testUser.phone);

    // Select language
    await page.selectOption('[data-testid="language-select"]', testUser.preferredLanguage);

    // Agree to terms
    await page.check('[data-testid="terms-checkbox"]');
    await page.check('[data-testid="privacy-checkbox"]');

    // Submit registration
    await page.click('[data-testid="register-submit"]');

    // Verify registration success
    await page.waitForURL('**/profile-setup');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText(testUser.firstName);

    // Complete profile setup
    await page.fill('[data-testid="observation-range"]', '50');
    await page.check('[data-testid="notification-sightings"]');
    await page.check('[data-testid="notification-discussions"]');
    await page.click('[data-testid="complete-profile-btn"]');

    // Verify redirect to dashboard
    await page.waitForURL('**/dashboard');
    await expect(page.locator('[data-testid="user-profile"]')).toContainText(testUser.firstName);

    // Verify profile data persistence
    await page.reload();
    await expect(page.locator('[data-testid="user-profile"]')).toContainText(testUser.firstName);
  });

  test('should allow user registration with phone number', async ({ page }) => {
    const testUser = TestDataGenerator.generateUser();

    await page.click('[data-testid="register-btn"]');
    await page.waitForURL('**/register');

    // Switch to phone registration
    await page.click('[data-testid="phone-registration-tab"]');

    await page.fill('[data-testid="phone-input"]', testUser.phone);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.fill('[data-testid="first-name-input"]', testUser.firstName);
    await page.fill('[data-testid="last-name-input"]', testUser.lastName);

    await page.check('[data-testid="terms-checkbox"]');
    await page.click('[data-testid="register-submit"]');

    // Handle phone verification
    await page.waitForSelector('[data-testid="verification-code-input"]');
    await page.fill('[data-testid="verification-code-input"]', '123456'); // Mock code
    await page.click('[data-testid="verify-phone-btn"]');

    await page.waitForURL('**/profile-setup');
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });

  test('should validate registration form inputs', async ({ page }) => {
    await page.click('[data-testid="register-btn"]');
    await page.waitForURL('**/register');

    // Try to submit empty form
    await page.click('[data-testid="register-submit"]');

    // Verify validation errors
    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="password-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="first-name-error"]')).toBeVisible();

    // Test invalid email
    await page.fill('[data-testid="email-input"]', 'invalid-email');
    await page.click('[data-testid="register-submit"]');
    await expect(page.locator('[data-testid="email-error"]')).toContainText('valid email');

    // Test password requirements
    await page.fill('[data-testid="password-input"]', '123');
    await page.click('[data-testid="register-submit"]');
    await expect(page.locator('[data-testid="password-error"]')).toContainText('8 characters');

    // Test password confirmation mismatch
    await page.fill('[data-testid="password-input"]', 'ValidPassword123!');
    await page.fill('[data-testid="confirm-password-input"]', 'DifferentPassword');
    await page.click('[data-testid="register-submit"]');
    await expect(page.locator('[data-testid="confirm-password-error"]')).toContainText('match');
  });

  test('should allow editing profile after registration', async ({ page, request }) => {
    // Create a user via API first
    const testUser = TestDataGenerator.generateUser();
    const apiHelpers = new APIHelpers(request);
    const { token } = await apiHelpers.createTestUser(testUser);

    // Login with the created user
    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');

    // Navigate to profile settings
    await page.click('[data-testid="user-menu"]');
    await page.click('[data-testid="profile-settings"]');
    await page.waitForURL('**/profile');

    // Edit profile information
    const newFirstName = 'Updated' + testUser.firstName;
    await page.fill('[data-testid="first-name-input"]', newFirstName);
    await page.fill('[data-testid="observation-range"]', '75');
    await page.selectOption('[data-testid="language-select"]', 'es');

    // Save changes
    await page.click('[data-testid="save-profile-btn"]');

    // Verify success message
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="success-message"]')).toContainText('Profile updated');

    // Verify changes were saved
    await page.reload();
    await expect(page.locator('[data-testid="first-name-input"]')).toHaveValue(newFirstName);
    await expect(page.locator('[data-testid="observation-range"]')).toHaveValue('75');
  });

  test('should persist user preferences across sessions', async ({ page, context, request }) => {
    // Create and login user
    const testUser = TestDataGenerator.generateUser();
    const apiHelpers = new APIHelpers(request);
    await apiHelpers.createTestUser(testUser);

    await page.goto('/login');
    await page.fill('[data-testid="email-input"]', testUser.email);
    await page.fill('[data-testid="password-input"]', testUser.password);
    await page.click('[data-testid="login-submit"]');

    // Set language preference
    await page.click('[data-testid="language-switcher"]');
    await page.click('[data-testid="language-option-es"]');
    await page.waitForLoadState('networkidle');

    // Verify Spanish content is displayed
    await expect(page.locator('[data-testid="welcome-message"]')).toContainText('Bienvenido');

    // Close and reopen browser
    await context.close();
    const newContext = await page.context().browser()?.newContext();
    const newPage = await newContext!.newPage();

    // Navigate to home and verify language preference is remembered
    await newPage.goto('/');
    await expect(newPage.locator('html')).toHaveAttribute('lang', 'es');
  });

  test('should support all three languages (EN/ES/DE)', async ({ page }) => {
    const languages = [
      { code: 'en', expectedText: 'Register' },
      { code: 'es', expectedText: 'Registrarse' },
      { code: 'de', expectedText: 'Registrieren' },
    ];

    for (const lang of languages) {
      await page.goto(`/${lang.code}`);
      await page.click('[data-testid="register-btn"]');
      
      await expect(page.locator('[data-testid="register-title"]')).toContainText(lang.expectedText);
      await expect(page.locator('html')).toHaveAttribute('lang', lang.code);
    }
  });
});