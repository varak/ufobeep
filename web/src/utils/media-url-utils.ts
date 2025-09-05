/**
 * Utility functions for handling media URLs and ensuring compatibility
 * with networks that block api.ufobeep.com subdomain
 */

/**
 * Converts API subdomain URLs to use the main domain media proxy
 * @param url The original media URL
 * @returns URL that uses the main domain proxy
 */
export function convertToProxyUrl(url: string): string {
  if (!url) return url
  
  // If URL points to api.ufobeep.com, convert to use main domain proxy
  if (url.includes('api.ufobeep.com')) {
    // Extract the path after the domain
    const urlParts = url.split('api.ufobeep.com')
    if (urlParts.length === 2) {
      // Return main domain + path (which will be handled by nginx proxy)
      return urlParts[1].startsWith('/') ? urlParts[1] : `/${urlParts[1]}`
    }
  }
  
  // If URL already starts with a path, it's ready to use
  if (url.startsWith('/')) {
    return url
  }
  
  // For any other full URLs, return as-is
  return url
}

/**
 * Processes media file object to ensure all URLs use the proxy
 */
export function convertMediaFileUrls(mediaFile: any): any {
  if (!mediaFile) return mediaFile
  
  return {
    ...mediaFile,
    url: convertToProxyUrl(mediaFile.url),
    thumbnail_url: convertToProxyUrl(mediaFile.thumbnail_url),
    web_url: mediaFile.web_url ? convertToProxyUrl(mediaFile.web_url) : mediaFile.web_url,
    preview_url: mediaFile.preview_url ? convertToProxyUrl(mediaFile.preview_url) : mediaFile.preview_url,
  }
}

/**
 * Processes array of media files to ensure all URLs use the proxy
 */
export function convertMediaFilesUrls(mediaFiles: any[]): any[] {
  if (!mediaFiles || !Array.isArray(mediaFiles)) return mediaFiles
  
  return mediaFiles.map(convertMediaFileUrls)
}