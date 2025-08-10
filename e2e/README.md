# UFOBeep E2E Test Suite

Comprehensive end-to-end testing for the UFOBeep platform covering all acceptance criteria and user workflows.

## 🎯 Coverage

### Acceptance Criteria Tests
- **AC-1**: User Registration and Profile Setup
- **AC-2**: Capture and Report UFO Sighting  
- **AC-3**: Browse and Filter UFO Alerts
- **AC-4**: View Alert Details and Join Discussion
- **AC-5**: Compass Navigation (Standard Mode)
- **AC-6**: Pilot Mode Navigation

### Test Categories
- 🔥 **Smoke Tests** (`@smoke`) - Critical functionality verification
- ⚠️ **Critical Path** (`@critical`) - Must-have user journeys
- 👁️ **Visual Tests** (`@visual`) - UI/UX validation
- 📱 **Mobile Tests** - Cross-device compatibility
- 🌍 **i18n Tests** - Multi-language support

## 🚀 Quick Start

### Prerequisites
```bash
# Install dependencies
npm install

# Install Playwright browsers
npm run install:browsers
```

### Environment Setup
```bash
# Copy test environment file
cp .env.example .env.test

# Update with your test configuration
BASE_URL=http://localhost:3000
API_URL=http://localhost:8000
```

### Running Tests

#### Basic Commands
```bash
# Run all tests
npm test

# Run with browser UI
npm run test:ui

# Run in headed mode (see browser)
npm run test:headed

# Debug tests
npm run test:debug
```

#### Test Categories
```bash
# Smoke tests (fast, critical functionality)
npm run test:smoke

# Critical path tests
npm run test:critical

# All acceptance criteria
npm run test:acceptance

# Visual regression tests
npm run test:visual

# Mobile device tests
npm run test:mobile

# Internationalization tests
npm run test:i18n

# Full test suite
npm run test:full
```

#### Individual Acceptance Criteria
```bash
npm run test:ac1  # User Registration
npm run test:ac2  # Sighting Capture
npm run test:ac3  # Browse Alerts
npm run test:ac4  # Alert Details
npm run test:ac5  # Compass Navigation
npm run test:ac6  # Pilot Mode
```

## 📊 Test Reports

### Viewing Reports
```bash
# HTML report (interactive)
npm run test:report

# Allure report (advanced)
npm run allure:serve

# Generate static Allure report
npm run allure:generate
```

### Report Locations
- **HTML**: `reports/html/index.html`
- **JUnit**: `reports/junit/results.xml` (CI integration)
- **JSON**: `reports/json/results.json` (programmatic access)
- **Allure**: `reports/allure-report/` (advanced analytics)
- **Summary**: `reports/summary.md` (markdown overview)

## 🛠️ Advanced Usage

### Custom Test Script
```bash
# Use the comprehensive test runner
./scripts/run-tests.sh [type] [options]

# Examples
./scripts/run-tests.sh smoke
./scripts/run-tests.sh acceptance
./scripts/run-tests.sh full
```

### Environment Variables
```bash
# Test configuration
TEST_ENV=development|staging|production
BROWSER=chromium|firefox|webkit|mobile-chrome|mobile-safari|all
HEADED=true|false
PARALLEL=true|false
RETRIES=0|1|2
TIMEOUT=60000

# Example
BROWSER=firefox HEADED=true npm run test:smoke
```

### Browser Selection
```bash
# Single browser
npx playwright test --project=chromium

# Multiple browsers
npx playwright test --project=chromium --project=firefox

# Mobile browsers
npx playwright test --project=mobile-chrome --project=mobile-safari

# All browsers
npx playwright test
```

## 🏗️ Test Architecture

### File Structure
```
e2e/
├── tests/
│   ├── acceptance/        # AC-1 through AC-6 tests
│   │   ├── ac-01-registration.spec.ts
│   │   ├── ac-02-capture-sighting.spec.ts
│   │   ├── ac-03-browse-alerts.spec.ts
│   │   ├── ac-04-alert-details.spec.ts
│   │   ├── ac-05-compass-navigation.spec.ts
│   │   └── ac-06-pilot-mode.spec.ts
│   ├── pages/             # Page Object Models
│   │   ├── base-page.ts
│   │   └── home-page.ts
│   └── utils/             # Test utilities
│       ├── test-data.ts
│       └── api-helpers.ts
├── reports/               # Test reports and artifacts
├── scripts/               # Test execution scripts
├── playwright.config.ts   # Main configuration
├── global-setup.ts       # Test suite setup
└── global-teardown.ts    # Test suite cleanup
```

### Page Object Model
Tests use the Page Object Model pattern for maintainability:

```typescript
import { HomePage } from '../pages/home-page';

test('should display hero section', async ({ page }) => {
  const homePage = new HomePage(page);
  await homePage.open();
  await homePage.verifyHeroSection();
});
```

### Test Data Management
Centralized test data generation with faker.js:

```typescript
import { TestDataGenerator } from '../utils/test-data';

const testUser = TestDataGenerator.generateUser();
const testSighting = TestDataGenerator.generateSighting();
```

## 🔧 Configuration

### Playwright Config
Key settings in `playwright.config.ts`:
- Multi-browser support (Chromium, Firefox, WebKit)
- Mobile device emulation
- Multi-language testing
- Comprehensive reporting
- Parallel execution
- Retry logic

### CI/CD Integration
GitHub Actions workflow (`.github/workflows/e2e-tests.yml`):
- Automated test execution on PR/push
- Multi-browser matrix testing
- Test result publishing
- Report deployment to GitHub Pages
- Slack/Discord notifications

## 🐛 Debugging

### Debug Mode
```bash
# Interactive debugging
npm run test:debug

# Specific test debugging
npx playwright test --debug tests/acceptance/ac-01-registration.spec.ts
```

### Test Generation
```bash
# Record new tests
npm run codegen

# Record against specific URL
npx playwright codegen http://localhost:3000
```

### Trace Viewer
```bash
# View execution traces
npm run trace

# For specific trace file
npx playwright show-trace test-results/trace.zip
```

## 📱 Mobile Testing

### Device Emulation
Tests run on emulated mobile devices:
- **Pixel 5** (Android)
- **iPhone 13** (iOS)
- **iPad Pro** (tablet)

### Mobile-Specific Features
- Geolocation permissions
- Camera access
- Touch interactions
- Viewport responsiveness
- Orientation changes

## 🌍 Internationalization

### Language Testing
Automated testing in multiple locales:
- **English** (en-US)
- **Spanish** (es-ES) 
- **German** (de-DE)

### i18n Validation
- Text translation verification
- Date/time formatting
- Number formatting
- RTL language support (future)

## 📈 Performance

### Test Execution
- Parallel test execution
- Browser instance reuse
- Smart retry logic
- Timeout management

### Resource Management
- Automatic cleanup
- Memory optimization
- Screenshot/video on failure only
- Trace collection on retry

## 🔍 Best Practices

### Test Writing
- Use data-testid selectors
- Page Object Model pattern
- Descriptive test names
- Proper test isolation
- Async/await patterns

### Test Tags
- `@smoke` - Critical functionality
- `@critical` - Must-have features
- `@visual` - UI/UX validation
- `@mobile` - Mobile-specific tests
- `@slow` - Long-running tests

### Error Handling
- Explicit waits
- Error screenshots
- Video recording on failure
- Detailed error messages
- Clean test isolation

## 📚 Resources

### Documentation
- [Playwright Documentation](https://playwright.dev)
- [Test Best Practices](https://playwright.dev/docs/best-practices)
- [Page Object Model](https://playwright.dev/docs/test-pom)

### Tools
- **Playwright Inspector** - Interactive debugging
- **Trace Viewer** - Timeline analysis  
- **Codegen** - Test recording
- **Allure** - Advanced reporting

## 🤝 Contributing

### Adding New Tests
1. Follow acceptance criteria format
2. Use Page Object Model
3. Include proper test tags
4. Add to appropriate test suite
5. Update documentation

### Test Maintenance
- Regular test review
- Flaky test investigation
- Performance optimization
- Report analysis
- Documentation updates