import { chromium, FullConfig } from '@playwright/test';
import { promises as fs } from 'fs';
import path from 'path';

async function globalSetup(config: FullConfig) {
  console.log('🚀 Starting UFOBeep E2E Test Suite');
  
  // Create reports directory structure
  const reportsDir = path.resolve(__dirname, 'reports');
  const dirs = ['html', 'junit', 'json', 'allure-results', 'screenshots', 'videos'];
  
  for (const dir of dirs) {
    const fullPath = path.join(reportsDir, dir);
    await fs.mkdir(fullPath, { recursive: true });
  }

  // Create test manifest
  const manifest = {
    testRun: {
      id: `run-${Date.now()}`,
      startTime: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'test',
      baseUrl: config.use?.baseURL || 'http://localhost:3000',
      browsers: config.projects?.map(p => p.name) || [],
      version: process.env.APP_VERSION || 'development'
    },
    acceptanceCriteria: [
      'AC-1: User Registration and Profile Setup',
      'AC-2: Capture and Report UFO Sighting',
      'AC-3: Browse and Filter UFO Alerts',
      'AC-4: View Alert Details and Join Discussion',
      'AC-5: Compass Navigation (Standard Mode)',
      'AC-6: Pilot Mode Navigation'
    ]
  };

  await fs.writeFile(
    path.join(reportsDir, 'test-manifest.json'),
    JSON.stringify(manifest, null, 2)
  );

  // Warm up the application
  if (!process.env.CI) {
    console.log('🌡️ Warming up application...');
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();
    
    try {
      await page.goto(config.use?.baseURL || 'http://localhost:3000', {
        timeout: 30000,
        waitUntil: 'networkidle'
      });
      console.log('✅ Application ready');
    } catch (error) {
      console.warn('⚠️ Application warm-up failed:', error);
    } finally {
      await browser.close();
    }
  }

  console.log('🏁 Test setup complete');
}

export default globalSetup;