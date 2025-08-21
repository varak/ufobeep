import { Page, Locator } from '@playwright/test';
import { BasePage } from './base-page';

export class HomePage extends BasePage {
  readonly heroTitle: Locator;
  readonly heroSubtitle: Locator;
  readonly downloadAppButton: Locator;
  readonly viewSightingsButton: Locator;
  readonly recentSightingsSection: Locator;
  readonly miniMap: Locator;
  readonly featuresSection: Locator;

  constructor(page: Page) {
    super(page);
    this.heroTitle = page.locator('[data-testid="hero-title"]');
    this.heroSubtitle = page.locator('[data-testid="hero-subtitle"]');
    this.downloadAppButton = page.locator('[data-testid="download-app-btn"]');
    this.viewSightingsButton = page.locator('[data-testid="view-sightings-btn"]');
    this.recentSightingsSection = page.locator('[data-testid="recent-sightings"]');
    this.miniMap = page.locator('[data-testid="mini-map"]');
    this.featuresSection = page.locator('[data-testid="features-section"]');
  }

  async open() {
    await this.navigateTo('/');
  }

  async clickDownloadApp() {
    await this.downloadAppButton.click();
  }

  async clickViewSightings() {
    await this.viewSightingsButton.click();
  }

  async verifyHeroSection() {
    await this.verifyElementVisible('[data-testid="hero-title"]');
    await this.verifyElementVisible('[data-testid="hero-subtitle"]');
    await this.verifyElementVisible('[data-testid="download-app-btn"]');
    await this.verifyElementVisible('[data-testid="view-sightings-btn"]');
  }

  async verifyFeaturesSection() {
    await this.verifyElementVisible('[data-testid="features-section"]');
    
    // Check for feature cards
    const features = [
      'realtime-reporting',
      'global-community', 
      'scientific-analysis'
    ];
    
    for (const feature of features) {
      await this.verifyElementVisible(`[data-testid="feature-${feature}"]`);
    }
  }

  async verifyRecentSightings() {
    await this.verifyElementVisible('[data-testid="recent-sightings"]');
    await this.verifyElementVisible('[data-testid="mini-map"]');
  }

  async getRecentSightingsCount(): Promise<number> {
    const sightings = this.page.locator('[data-testid="sighting-card"]');
    return await sightings.count();
  }

  async clickSighting(index: number = 0) {
    const sightings = this.page.locator('[data-testid="sighting-card"]');
    await sightings.nth(index).click();
  }

  async verifyLanguageContent(language: 'en' | 'es' | 'de') {
    const expectedTitles = {
      en: 'Spot Something Strange in the Sky?',
      es: '¿Has visto algo extraño en el cielo?',
      de: 'Etwas Seltsames am Himmel gesehen?'
    };
    
    await this.verifyElementText(
      '[data-testid="hero-title"]', 
      expectedTitles[language]
    );
  }

  async navigateToAlerts() {
    await this.clickElement('[data-testid="nav-alerts"]');
  }

  async navigateToApp() {
    await this.clickElement('[data-testid="nav-app"]');
  }
}