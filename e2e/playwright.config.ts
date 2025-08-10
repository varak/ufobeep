import { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '.env.test' });

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { 
      outputFolder: './reports/html',
      open: process.env.CI ? 'never' : 'on-failure'
    }],
    ['junit', { 
      outputFile: './reports/junit/results.xml' 
    }],
    ['json', { 
      outputFile: './reports/json/results.json' 
    }],
    ['allure-playwright', {
      detail: true,
      outputFolder: './reports/allure-results',
      suiteTitle: 'UFOBeep E2E Tests'
    }],
    ['github', {
      includeProjectInTestName: true
    }],
    ['line']
  ],
  
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15000,
    navigationTimeout: 30000,
  },

  projects: [
    // Desktop browsers
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    // Mobile browsers
    {
      name: 'mobile-chrome',
      use: { 
        ...devices['Pixel 5'],
        permissions: ['geolocation', 'camera'],
        geolocation: { latitude: 37.7749, longitude: -122.4194 },
        locale: 'en-US',
      },
    },
    {
      name: 'mobile-safari',
      use: { 
        ...devices['iPhone 13'],
        permissions: ['geolocation', 'camera'],
        geolocation: { latitude: 37.7749, longitude: -122.4194 },
        locale: 'en-US',
      },
    },

    // Test different languages
    {
      name: 'spanish',
      use: { 
        ...devices['Desktop Chrome'],
        locale: 'es-ES',
        timezoneId: 'Europe/Madrid',
      },
    },
    {
      name: 'german',
      use: { 
        ...devices['Desktop Chrome'],
        locale: 'de-DE',
        timezoneId: 'Europe/Berlin',
      },
    },
  ],

  webServer: [
    {
      command: 'cd ../web && npm run dev',
      port: 3000,
      reuseExistingServer: !process.env.CI,
      timeout: 120000,
    },
    {
      command: 'cd ../api && python -m uvicorn app.main:app --reload',
      port: 8000,
      reuseExistingServer: !process.env.CI,
      timeout: 120000,
    },
  ],
});