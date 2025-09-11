#!/usr/bin/env node
/**
 * SINGLE SOURCE OF TRUTH for short URL hash generation
 * Used by web, app (via transpilation), API, and mufon.sh
 * Based on the working web implementation
 * 
 * USAGE:
 * - CLI: node shared/get_short_hash.js "UFO-2024-12345"
 * - mufon.sh: SHORT_ID=$(node shared/get_short_hash.js "$SIGHTING_ID")
 * - Web: const { getShortHash } = require('../../shared/get_short_hash.js')
 * - App: Dart version maintains identical algorithm (see app/lib/utils/short_url_utils.dart)
 * 
 * CRITICAL: DO NOT MODIFY THE ALGORITHM - CHANGES BREAK URL CONSISTENCY
 */

// Characters safe for short IDs (excludes O,I,L,0,1,o,l,i for clarity)
const SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz';

/**
 * Generate a 5-character clean short ID from input string.
 * Updated to 5 chars for 120k NUFORC import without collisions (29^5 = 20.5M combinations)
 * This is the CANONICAL implementation - DO NOT CHANGE
 */
function getShortHash(input) {
  if (!input) return '';
  
  // Generate hash using the exact working algorithm from web
  let hash = 0;
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer (working web version)
  }
  
  // Convert hash to base-29 using safe characters  
  let shortId = '';
  let num = Math.abs(hash);
  
  for (let i = 0; i < 5; i++) {  // Updated from 4 to 5 characters
    shortId = SAFE_CHARS[num % SAFE_CHARS.length] + shortId;
    num = Math.floor(num / SAFE_CHARS.length);
  }
  
  return shortId;
}

// CLI usage: node get_short_hash.js "UFO-2024-12345"
// Only run CLI code in Node.js environment with process available
if (typeof process !== 'undefined' && typeof require !== 'undefined' && require.main === module) {
  const input = process.argv[2];
  if (!input) {
    console.error('Usage: node get_short_hash.js <input_string>');
    process.exit(1);
  }
  console.log(getShortHash(input));
}

// Universal export for module usage (Node.js and browser)
if (typeof module !== 'undefined' && module.exports) {
  // Node.js
  module.exports = { getShortHash, SAFE_CHARS };
} else if (typeof window !== 'undefined') {
  // Browser
  window.getShortHash = getShortHash;
  window.SAFE_CHARS = SAFE_CHARS;
}