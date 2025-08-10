#!/bin/bash

# UFOBeep E2E Test Runner
# Comprehensive test execution with multiple reporting formats

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_ENV=${TEST_ENV:-"development"}
BROWSER=${BROWSER:-"all"}
HEADED=${HEADED:-"false"}
PARALLEL=${PARALLEL:-"true"}
RETRIES=${RETRIES:-"1"}
TIMEOUT=${TIMEOUT:-"60000"}

echo -e "${BLUE}🚀 UFOBeep E2E Test Suite${NC}"
echo -e "Environment: ${TEST_ENV}"
echo -e "Browser: ${BROWSER}"
echo -e "Headed: ${HEADED}"
echo -e "Parallel: ${PARALLEL}"
echo ""

# Create reports directory
mkdir -p reports/{html,junit,json,allure-results,screenshots,videos}

# Function to run tests for specific tags
run_tagged_tests() {
    local tag=$1
    local description=$2
    
    echo -e "${YELLOW}Running $description tests...${NC}"
    
    local cmd="npx playwright test --grep='@$tag'"
    
    if [ "$BROWSER" != "all" ]; then
        cmd="$cmd --project=$BROWSER"
    fi
    
    if [ "$HEADED" = "true" ]; then
        cmd="$cmd --headed"
    fi
    
    if [ "$PARALLEL" = "false" ]; then
        cmd="$cmd --workers=1"
    fi
    
    cmd="$cmd --retries=$RETRIES --timeout=$TIMEOUT"
    
    eval $cmd || echo -e "${RED}Some $description tests failed${NC}"
}

# Function to run acceptance criteria tests
run_acceptance_tests() {
    echo -e "${BLUE}📋 Running Acceptance Criteria Tests${NC}"
    
    local acceptance_criteria=(
        "AC-1:User Registration"
        "AC-2:Sighting Capture" 
        "AC-3:Browse Alerts"
        "AC-4:Alert Details"
        "AC-5:Compass Navigation"
        "AC-6:Pilot Mode"
    )
    
    for ac in "${acceptance_criteria[@]}"; do
        local ac_tag=$(echo $ac | cut -d':' -f1)
        local ac_desc=$(echo $ac | cut -d':' -f2)
        echo -e "${YELLOW}Testing $ac_tag: $ac_desc${NC}"
        
        npx playwright test "tests/acceptance/$ac_tag*.spec.ts" \
            --project=$BROWSER \
            --retries=$RETRIES \
            --timeout=$TIMEOUT \
            || echo -e "${RED}$ac_tag tests failed${NC}"
    done
}

# Main test execution
main() {
    case "${1:-full}" in
        "smoke")
            echo -e "${GREEN}🔥 Running Smoke Tests${NC}"
            run_tagged_tests "smoke" "Smoke"
            ;;
        "critical")
            echo -e "${GREEN}⚠️ Running Critical Path Tests${NC}"
            run_tagged_tests "critical" "Critical"
            ;;
        "acceptance")
            echo -e "${GREEN}✅ Running Acceptance Criteria Tests${NC}"
            run_acceptance_tests
            ;;
        "visual")
            echo -e "${GREEN}👁️ Running Visual Tests${NC}"
            run_tagged_tests "visual" "Visual"
            ;;
        "mobile")
            echo -e "${GREEN}📱 Running Mobile Tests${NC}"
            BROWSER="mobile-chrome"
            npx playwright test --project=mobile-chrome --project=mobile-safari
            ;;
        "i18n")
            echo -e "${GREEN}🌍 Running Internationalization Tests${NC}"
            npx playwright test --project=spanish --project=german
            ;;
        "full")
            echo -e "${GREEN}🎯 Running Full Test Suite${NC}"
            npx playwright test
            ;;
        *)
            echo -e "${RED}Unknown test type: $1${NC}"
            echo "Available options: smoke, critical, acceptance, visual, mobile, i18n, full"
            exit 1
            ;;
    esac
}

# Cleanup function
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up test artifacts...${NC}"
    
    # Archive old reports
    if [ -d "reports/archive" ]; then
        timestamp=$(date +"%Y%m%d_%H%M%S")
        mkdir -p "reports/archive/$timestamp"
        cp -r reports/html reports/json reports/junit "reports/archive/$timestamp/" 2>/dev/null || true
    fi
    
    # Clean up temporary files
    find . -name "*.tmp" -delete 2>/dev/null || true
    find . -name "test-results-*" -delete 2>/dev/null || true
}

# Error handling
handle_error() {
    echo -e "${RED}❌ Test execution failed with error: $1${NC}"
    cleanup
    exit 1
}

# Trap errors
trap 'handle_error "Unexpected error occurred"' ERR

# Pre-test checks
echo -e "${BLUE}🔍 Running pre-test checks...${NC}"

# Check if Playwright is installed
if ! npx playwright --version > /dev/null 2>&1; then
    echo -e "${RED}Playwright not found. Installing...${NC}"
    npm install -D @playwright/test
    npx playwright install
fi

# Check if required environment variables are set
required_vars=("BASE_URL")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${YELLOW}Warning: $var not set, using default${NC}"
    fi
done

# Run tests
main "$@"

# Post-test reporting
echo -e "${BLUE}📊 Generating reports...${NC}"

# Generate Allure report if allure is available
if command -v allure > /dev/null 2>&1; then
    echo -e "${YELLOW}Generating Allure report...${NC}"
    allure generate reports/allure-results -o reports/allure-report --clean
    echo -e "${GREEN}Allure report: reports/allure-report/index.html${NC}"
fi

# Display report locations
echo -e "${GREEN}📈 Reports generated:${NC}"
echo -e "  HTML: reports/html/index.html"
echo -e "  JSON: reports/json/results.json"
echo -e "  JUnit: reports/junit/results.xml"
echo -e "  Summary: reports/summary.md"

# Open report if not in CI
if [ "$CI" != "true" ] && [ "$HEADED" = "true" ]; then
    echo -e "${BLUE}Opening HTML report...${NC}"
    npx playwright show-report reports/html
fi

# Final cleanup
cleanup

echo -e "${GREEN}✅ E2E test execution completed!${NC}"