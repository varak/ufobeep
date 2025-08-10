import { Page, Locator, expect } from '@playwright/test';

export abstract class BasePage {
  protected constructor(protected page: Page) {}

  async navigateTo(path: string) {
    await this.page.goto(path);
    await this.waitForPageLoad();
  }

  async waitForPageLoad(timeout = 30000) {
    await this.page.waitForLoadState('networkidle', { timeout });
  }

  async clickElement(selector: string | Locator) {
    const element = typeof selector === 'string' ? this.page.locator(selector) : selector;
    await element.waitFor({ state: 'visible' });
    await element.click();
  }

  async fillInput(selector: string | Locator, value: string) {
    const element = typeof selector === 'string' ? this.page.locator(selector) : selector;
    await element.waitFor({ state: 'visible' });
    await element.clear();
    await element.fill(value);
  }

  async selectOption(selector: string | Locator, value: string) {
    const element = typeof selector === 'string' ? this.page.locator(selector) : selector;
    await element.waitFor({ state: 'visible' });
    await element.selectOption(value);
  }

  async waitForText(text: string, timeout = 10000) {
    await this.page.waitForSelector(`text=${text}`, { timeout });
  }

  async verifyPageTitle(expectedTitle: string) {
    await expect(this.page).toHaveTitle(expectedTitle);
  }

  async verifyUrl(expectedUrl: string) {
    await expect(this.page).toHaveURL(expectedUrl);
  }

  async verifyElementVisible(selector: string) {
    await expect(this.page.locator(selector)).toBeVisible();
  }

  async verifyElementHidden(selector: string) {
    await expect(this.page.locator(selector)).toBeHidden();
  }

  async verifyElementText(selector: string, expectedText: string) {
    await expect(this.page.locator(selector)).toHaveText(expectedText);
  }

  async verifyElementCount(selector: string, expectedCount: number) {
    await expect(this.page.locator(selector)).toHaveCount(expectedCount);
  }

  async waitForNetworkIdle(timeout = 5000) {
    await this.page.waitForLoadState('networkidle', { timeout });
  }

  async takeScreenshot(name: string) {
    await this.page.screenshot({ 
      path: `screenshots/${name}.png`,
      fullPage: true 
    });
  }

  async scrollToElement(selector: string) {
    await this.page.locator(selector).scrollIntoViewIfNeeded();
  }

  async getElementText(selector: string): Promise<string> {
    return await this.page.locator(selector).textContent() || '';
  }

  async isElementVisible(selector: string): Promise<boolean> {
    return await this.page.locator(selector).isVisible();
  }

  async waitForSelector(selector: string, timeout = 10000) {
    await this.page.waitForSelector(selector, { timeout });
  }

  // Mobile-specific methods
  async enableGeolocation(latitude: number, longitude: number) {
    await this.page.context().setGeolocation({ latitude, longitude });
    await this.page.context().grantPermissions(['geolocation']);
  }

  async enableCamera() {
    await this.page.context().grantPermissions(['camera']);
  }

  async switchToLandscape() {
    await this.page.setViewportSize({ width: 1024, height: 768 });
  }

  async switchToPortrait() {
    await this.page.setViewportSize({ width: 375, height: 812 });
  }

  // Language switching
  async switchLanguage(language: 'en' | 'es' | 'de') {
    const languageSelector = this.page.locator('[data-testid="language-switcher"]');
    await languageSelector.click();
    await this.page.locator(`[data-testid="language-option-${language}"]`).click();
    await this.waitForPageLoad();
  }

  // Common navigation elements
  get navigationMenu() {
    return this.page.locator('[data-testid="nav-menu"]');
  }

  get languageSwitcher() {
    return this.page.locator('[data-testid="language-switcher"]');
  }

  get loadingIndicator() {
    return this.page.locator('[data-testid="loading"]');
  }

  get errorMessage() {
    return this.page.locator('[data-testid="error-message"]');
  }

  get successMessage() {
    return this.page.locator('[data-testid="success-message"]');
  }
}