export enum Environment {
  DEVELOPMENT = 'development',
  STAGING = 'staging',
  PRODUCTION = 'production'
}

class EnvironmentConfig {
  private static _instance: EnvironmentConfig;
  private _environment: Environment;

  private constructor() {
    this._environment = this.getEnvironmentFromProcess();
  }

  public static get instance(): EnvironmentConfig {
    if (!EnvironmentConfig._instance) {
      EnvironmentConfig._instance = new EnvironmentConfig();
    }
    return EnvironmentConfig._instance;
  }

  private getEnvironmentFromProcess(): Environment {
    const env = process.env.NODE_ENV || 'development';
    const customEnv = process.env.NEXT_PUBLIC_ENVIRONMENT;
    
    if (customEnv) {
      switch (customEnv.toLowerCase()) {
        case 'staging':
          return Environment.STAGING;
        case 'production':
          return Environment.PRODUCTION;
        default:
          return Environment.DEVELOPMENT;
      }
    }
    
    switch (env) {
      case 'production':
        return Environment.PRODUCTION;
      case 'staging':
        return Environment.STAGING;
      case 'development':
        return Environment.DEVELOPMENT;
      default:
        return Environment.DEVELOPMENT;
    }
  }

  // Environment getters
  get environment(): Environment {
    return this._environment;
  }

  get isDevelopment(): boolean {
    return this._environment === Environment.DEVELOPMENT;
  }

  get isStaging(): boolean {
    return this._environment === Environment.STAGING;
  }

  get isProduction(): boolean {
    return this._environment === Environment.PRODUCTION;
  }

  // API Configuration
  get apiBaseUrl(): string {
    const url = process.env.NEXT_PUBLIC_API_BASE_URL;
    if (url) return url;

    switch (this._environment) {
      case Environment.STAGING:
        return 'https://api-staging.ufobeep.com';
      case Environment.PRODUCTION:
        return 'https://api.ufobeep.com';
      default:
        return 'http://localhost:8000';
    }
  }

  get apiVersion(): string {
    return process.env.NEXT_PUBLIC_API_VERSION || 'v1';
  }

  get apiFullUrl(): string {
    return `${this.apiBaseUrl}/${this.apiVersion}`;
  }

  // Matrix Configuration
  get matrixBaseUrl(): string {
    const url = process.env.NEXT_PUBLIC_MATRIX_BASE_URL;
    if (url) return url;

    switch (this._environment) {
      case Environment.STAGING:
        return 'https://matrix-staging.ufobeep.com';
      case Environment.PRODUCTION:
        return 'https://matrix.ufobeep.com';
      default:
        return 'http://localhost:8008';
    }
  }

  get matrixServerName(): string {
    const serverName = process.env.NEXT_PUBLIC_MATRIX_SERVER_NAME;
    if (serverName) return serverName;

    switch (this._environment) {
      case Environment.STAGING:
        return 'staging.ufobeep.com';
      case Environment.PRODUCTION:
        return 'ufobeep.com';
      default:
        return 'localhost';
    }
  }

  // App Configuration
  get appName(): string {
    return process.env.NEXT_PUBLIC_APP_NAME || 'UFOBeep';
  }

  get appUrl(): string {
    const url = process.env.NEXT_PUBLIC_APP_URL;
    if (url) return url;

    switch (this._environment) {
      case Environment.STAGING:
        return 'https://staging.ufobeep.com';
      case Environment.PRODUCTION:
        return 'https://ufobeep.com';
      default:
        return 'http://localhost:3000';
    }
  }

  get siteUrl(): string {
    return process.env.NEXT_PUBLIC_SITE_URL || this.appUrl;
  }

  get siteName(): string {
    return process.env.NEXT_PUBLIC_SITE_NAME || this.appName;
  }

  get siteDescription(): string {
    return process.env.NEXT_PUBLIC_SITE_DESCRIPTION || 'Real-time UFO and anomaly sighting alerts';
  }

  // Analytics
  get enableAnalytics(): boolean {
    return process.env.NEXT_PUBLIC_ENABLE_ANALYTICS === 'true' && !this.isDevelopment;
  }

  get googleAnalyticsId(): string | undefined {
    return process.env.NEXT_PUBLIC_GA_ID;
  }

  // Feature Flags
  get enablePwa(): boolean {
    return process.env.NEXT_PUBLIC_ENABLE_PWA !== 'false';
  }

  get enableShareApi(): boolean {
    return process.env.NEXT_PUBLIC_ENABLE_SHARE_API !== 'false';
  }

  // Maps Configuration
  get mapboxToken(): string | undefined {
    return process.env.NEXT_PUBLIC_MAPBOX_TOKEN;
  }

  get googleMapsApiKey(): string | undefined {
    return process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY;
  }

  // Locale Configuration
  get defaultLocale(): string {
    return process.env.NEXT_PUBLIC_DEFAULT_LOCALE || 'en';
  }

  get supportedLocales(): string[] {
    const locales = process.env.NEXT_PUBLIC_SUPPORTED_LOCALES;
    return locales ? locales.split(',') : ['en', 'es', 'de'];
  }

  // Debug and Logging
  logConfiguration(): void {
    if (this.isDevelopment) {
      console.log('=== UFOBeep Web Environment Configuration ===');
      console.log('Environment:', this._environment);
      console.log('API Base URL:', this.apiBaseUrl);
      console.log('Matrix Base URL:', this.matrixBaseUrl);
      console.log('App URL:', this.appUrl);
      console.log('Site URL:', this.siteUrl);
      console.log('Default Locale:', this.defaultLocale);
      console.log('Supported Locales:', this.supportedLocales.join(', '));
      console.log('Analytics Enabled:', this.enableAnalytics);
      console.log('PWA Enabled:', this.enablePwa);
      console.log('==============================================');
    }
  }
}

export const env = EnvironmentConfig.instance;