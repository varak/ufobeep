#!/usr/bin/env node
/**
 * SINGLE SOURCE OF TRUTH for slug generation
 * Used by web frontend, mufon.sh, and any other scripts
 * Uses ARB files as the single source for translations
 * 
 * USAGE:
 * - CLI: node shared/generate_slug.js '{"title":"MUFON Report","location":"Las Vegas, NV","created_at":"2025-09-11T12:40:58Z","source":"mufon","short_url":"arnm6"}' es
 * - mufon.sh: SLUG=$(node shared/generate_slug.js "$ALERT_JSON" "$LOCALE")
 * - Web: const { generateAlertSlug } = require('../../shared/generate_slug.js')
 */

// Universal imports - work in both Node.js and browser
const { getShortHash } = require('./get_short_hash.js');

// Detect environment
const isBrowser = typeof window !== 'undefined';

// Node.js-only imports - guard against Edge Runtime
let fs, path;
if (!isBrowser && typeof process !== 'undefined') {
  try {
    fs = require('fs');
    path = require('path');
  } catch (e) {
    // Ignore import errors in Edge Runtime or other restricted environments
  }
}

// Load ARB files for translations (Node.js only)
function loadArbTranslations(locale = 'en') {
  if (isBrowser || !fs || !path) {
    // Browser or Edge Runtime: return empty translations (web should fetch via API)
    return {};
  }
  
  const arbPath = path.join(__dirname, `../app/lib/l10n/app_${locale}.arb`);
  
  if (!fs.existsSync(arbPath)) {
    // Fallback to English if locale not found
    const fallbackPath = path.join(__dirname, '../app/lib/l10n/app_en.arb');
    if (fs.existsSync(fallbackPath)) {
      return JSON.parse(fs.readFileSync(fallbackPath, 'utf8'));
    }
    return {};
  }
  
  return JSON.parse(fs.readFileSync(arbPath, 'utf8'));
}

function formatLocation(location) {
  if (!location) return 'unknown';
  
  // If location is an object with name property
  if (typeof location === 'object' && location.name) {
    location = location.name;
  }
  
  // If location is a string, clean it up
  if (typeof location === 'string') {
    // Extract city and state from "Bensalem, PA" format
    const cleanLocation = location
      .replace(/, US$/, '')
      .replace(/, United States$/, '');
    
    const locationParts = cleanLocation.split(',').map(p => p.trim());
    const city = locationParts[0]?.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, '-') || '';
    const state = locationParts[1]?.toLowerCase().replace(/[^a-z0-9]/g, '') || '';
    
    if (city) {
      const locationSlug = state ? `${city}-${state}` : city;
      return locationSlug.substring(0, 25); // Slightly longer for city-state
    }
    return '';
  }
  
  return 'unknown';
}

function formatDate(dateString) {
  if (!dateString) return new Date().toISOString().split('T')[0];
  
  try {
    return new Date(dateString).toISOString().split('T')[0];
  } catch {
    return new Date().toISOString().split('T')[0];
  }
}

/**
 * Generate SEO-friendly slug for an alert using ARB translations
 * @param {Object} alert - Alert object with id, title, created_at, location, source, short_url, shape
 * @param {string} locale - Language locale (default: 'en')
 * @param {string} shortId - Override short ID (optional)
 * @returns {string} Generated slug
 */
function generateAlertSlug(alert, locale = 'en', shortId = null) {
  // Load translations from ARB files
  const translations = loadArbTranslations(locale);
  
  // Priority order for short ID (CRITICAL!)
  // 1. Provided shortId parameter (from URL)
  // 2. alert.short_url from database  
  // 3. Generated from alert.id (fallback only)
  const id = shortId || alert.short_url || getShortHash(alert.id);
  
  // Get translated terms from ARB files
  const ufoTerm = translations.ufo || 'ufo';
  const sightingTerm = translations.sighting || 'sighting';
  const mufonTerm = translations.mufon || 'mufon';
  const reportTerm = translations.report || 'report';
  
  // Get translated shape terms from ARB files
  const getShapeTranslation = (shape) => {
    if (!shape) return '';
    
    // Dynamically find shape keys from ARB file
    // Look for keys that start with 'shape' and match our input
    const shapeInput = shape.toLowerCase();
    
    // Find matching ARB key
    let translated = shape; // fallback to original
    
    // Look through all translation keys to find shape matches
    for (const key in translations) {
      if (key.startsWith('shape')) {
        // Extract the shape name from the key (e.g., 'shapeSphere' -> 'sphere')
        const arbShapeName = key.replace('shape', '').toLowerCase();
        
        if (arbShapeName === shapeInput) {
          translated = translations[key];
          break;
        }
      }
    }
    
    // Make URL-safe by removing accents and special characters
    return translated
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove diacritical marks
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, '-');
  };
  
  // Handle MUFON vs UFOBeep titles with shape data
  const isMufon = alert.source === 'mufon';
  let title = '';
  
  if (isMufon) {
    // Include shape in MUFON titles: "mufon-sphere-ufo-sighting" or "mufon-ufo-sighting"
    if (alert.shape) {
      const shapeTranslation = getShapeTranslation(alert.shape);
      title = `${mufonTerm}-${shapeTranslation}-${ufoTerm}-${sightingTerm}`;
    } else {
      title = `${mufonTerm}-${ufoTerm}-${sightingTerm}`;
    }
  } else {
    // Include shape in UFOBeep titles: "sphere-ufo-sighting" or "ufo-sighting"
    if (alert.shape) {
      const shapeTranslation = getShapeTranslation(alert.shape);
      title = `${shapeTranslation}-${ufoTerm}-${sightingTerm}`;
    } else {
      title = `${ufoTerm}-${sightingTerm}`;
    }
  }
  
  // Build location part
  const location = formatLocation(alert.location);
  
  // Build date part  
  const date = formatDate(alert.created_at);
  
  // Combine all parts
  const slug = `${title}-${location}-${date}-${id}`;
  
  // Clean up slug
  return slug
    .replace(/--+/g, '-')
    .replace(/^-|-$/g, '')
    .toLowerCase();
}

// CLI usage: node generate_slug.js '{"alert":"data"}' es
// Only run CLI code in Node.js environment with process available
if (typeof process !== 'undefined' && typeof require !== 'undefined' && require.main === module) {
  const alertJson = process.argv[2];
  const locale = process.argv[3] || 'en';
  
  if (!alertJson) {
    console.error('Usage: node generate_slug.js <alert_json> [locale]');
    console.error('Example: node generate_slug.js \'{"title":"MUFON Report","location":"Las Vegas, NV","created_at":"2025-09-11T12:40:58Z","source":"mufon","short_url":"arnm6","shape":"sphere"}\' es');
    process.exit(1);
  }
  
  try {
    const alert = JSON.parse(alertJson);
    const slug = generateAlertSlug(alert, locale);
    console.log(slug);
  } catch (error) {
    console.error('Error parsing alert JSON:', error.message);
    process.exit(1);
  }
}

// Export for module usage
module.exports = { generateAlertSlug, loadArbTranslations };