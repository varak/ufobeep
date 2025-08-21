import { FullConfig } from '@playwright/test';
import { promises as fs } from 'fs';
import path from 'path';

async function globalTeardown(config: FullConfig) {
  console.log('🧹 Starting test cleanup and reporting...');
  
  const reportsDir = path.resolve(__dirname, 'reports');

  try {
    // Update test manifest with completion info
    const manifestPath = path.join(reportsDir, 'test-manifest.json');
    const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf8'));
    
    manifest.testRun.endTime = new Date().toISOString();
    manifest.testRun.duration = new Date().getTime() - new Date(manifest.testRun.startTime).getTime();
    
    // Read test results if available
    const jsonResultsPath = path.join(reportsDir, 'json', 'results.json');
    try {
      const results = JSON.parse(await fs.readFile(jsonResultsPath, 'utf8'));
      manifest.summary = {
        total: results.stats?.total || 0,
        passed: results.stats?.passed || 0,
        failed: results.stats?.failed || 0,
        skipped: results.stats?.skipped || 0,
        flaky: results.stats?.flaky || 0,
        duration: results.stats?.duration || 0
      };
    } catch (e) {
      console.warn('Could not read test results for summary');
    }

    await fs.writeFile(manifestPath, JSON.stringify(manifest, null, 2));

    // Generate summary report
    const summaryReport = generateSummaryReport(manifest);
    await fs.writeFile(
      path.join(reportsDir, 'summary.md'),
      summaryReport
    );

    console.log('📊 Test reports generated:');
    console.log(`   - HTML Report: ${path.join(reportsDir, 'html/index.html')}`);
    console.log(`   - JUnit XML: ${path.join(reportsDir, 'junit/results.xml')}`);
    console.log(`   - JSON Results: ${path.join(reportsDir, 'json/results.json')}`);
    console.log(`   - Summary: ${path.join(reportsDir, 'summary.md')}`);

    if (manifest.summary) {
      const { total, passed, failed, skipped } = manifest.summary;
      const successRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0';
      
      console.log('\n📈 Test Summary:');
      console.log(`   Total: ${total}`);
      console.log(`   ✅ Passed: ${passed}`);
      console.log(`   ❌ Failed: ${failed}`);
      console.log(`   ⏭️ Skipped: ${skipped}`);
      console.log(`   📊 Success Rate: ${successRate}%`);
      
      if (failed > 0) {
        console.log('\n❗ Some tests failed. Check the detailed reports for more information.');
      }
    }

  } catch (error) {
    console.error('Failed to generate test reports:', error);
  }

  console.log('✅ Teardown complete');
}

function generateSummaryReport(manifest: any): string {
  const { testRun, summary, acceptanceCriteria } = manifest;
  const duration = summary?.duration ? `${(summary.duration / 1000).toFixed(1)}s` : 'Unknown';
  const successRate = summary?.total > 0 ? ((summary.passed / summary.total) * 100).toFixed(1) : '0';

  return `# UFOBeep E2E Test Report

## Test Run Information
- **Run ID**: ${testRun.id}
- **Start Time**: ${new Date(testRun.startTime).toLocaleString()}
- **End Time**: ${new Date(testRun.endTime).toLocaleString()}
- **Duration**: ${duration}
- **Environment**: ${testRun.environment}
- **Base URL**: ${testRun.baseUrl}
- **App Version**: ${testRun.version}

## Test Summary
${summary ? `
| Metric | Count |
|--------|--------|
| **Total Tests** | ${summary.total} |
| **✅ Passed** | ${summary.passed} |
| **❌ Failed** | ${summary.failed} |
| **⏭️ Skipped** | ${summary.skipped} |
| **🔄 Flaky** | ${summary.flaky || 0} |
| **📊 Success Rate** | ${successRate}% |
` : '📊 Test results not available'}

## Browsers Tested
${testRun.browsers.map((browser: string) => `- ${browser}`).join('\n')}

## Acceptance Criteria Coverage
${acceptanceCriteria.map((ac: string) => `- [${summary && summary.failed === 0 ? 'x' : ' '}] ${ac}`).join('\n')}

## Reports Generated
- **HTML Report**: \`reports/html/index.html\` - Interactive test report with screenshots and videos
- **JUnit XML**: \`reports/junit/results.xml\` - CI/CD integration format
- **JSON Results**: \`reports/json/results.json\` - Machine-readable results
- **Allure Results**: \`reports/allure-results/\` - Advanced reporting with Allure

## How to View Reports

### HTML Report (Recommended)
\`\`\`bash
npx playwright show-report reports/html
\`\`\`

### Allure Report (Advanced)
\`\`\`bash
npx allure serve reports/allure-results
\`\`\`

---
*Generated on ${new Date().toLocaleString()}*
`;
}

export default globalTeardown;