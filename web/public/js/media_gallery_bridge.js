/**
 * JavaScript bridge for MediaGallery
 * Exposes MediaGalleryCore to Flutter web apps
 */

// Import the shared core logic (adjust path as needed)
// For production, you'd bundle this properly
// For now, we'll include the core logic directly

class MediaGalleryCore {
  constructor(config, callbacks = {}) {
    this.config = {
      enableDeepLinking: true,
      enableKeyboardNav: true,
      enableLazyLoading: true,
      thumbnailCols: { mobile: 2, tablet: 3, desktop: 4 },
      ...config
    };

    this.state = {
      currentIndex: null,
      isFullscreen: false,
      loadedItems: new Set()
    };

    this.callbacks = callbacks;

    // Bind keyboard events if enabled
    if (this.config.enableKeyboardNav) {
      this._bindKeyboardEvents();
    }
  }

  _bindKeyboardEvents() {
    document.addEventListener('keydown', (e) => {
      this.handleKeyPress(e.key);
    });
  }

  // State getters
  getCurrentItem() {
    if (this.state.currentIndex === null) return null;
    return this.config.items[this.state.currentIndex] || null;
  }

  getCurrentIndex() {
    return this.state.currentIndex;
  }

  getItems() {
    return this.config.items;
  }

  isFullscreen() {
    return this.state.isFullscreen;
  }

  // Navigation actions
  openMedia(index) {
    if (index < 0 || index >= this.config.items.length) return;

    this.state.currentIndex = index;
    this.state.isFullscreen = true;

    const item = this.config.items[index];
    this.callbacks.onMediaOpen?.(item, index);
    this.callbacks.onMediaChange?.(item, index);
  }

  openMediaById(id) {
    const index = this.config.items.findIndex(item => item.id === id);
    if (index !== -1) {
      this.openMedia(index);
    }
  }

  closeMedia() {
    this.state.currentIndex = null;
    this.state.isFullscreen = false;
    this.callbacks.onMediaClose?.();
  }

  nextMedia() {
    if (this.state.currentIndex === null) return false;
    if (this.state.currentIndex >= this.config.items.length - 1) return false;

    const newIndex = this.state.currentIndex + 1;
    this.state.currentIndex = newIndex;

    const item = this.config.items[newIndex];
    this.callbacks.onMediaChange?.(item, newIndex);
    return true;
  }

  prevMedia() {
    if (this.state.currentIndex === null) return false;
    if (this.state.currentIndex <= 0) return false;

    const newIndex = this.state.currentIndex - 1;
    this.state.currentIndex = newIndex;

    const item = this.config.items[newIndex];
    this.callbacks.onMediaChange?.(item, newIndex);
    return true;
  }

  // Keyboard handling
  handleKeyPress(key) {
    if (!this.config.enableKeyboardNav || !this.state.isFullscreen) return false;

    switch (key) {
      case 'Escape':
        this.closeMedia();
        return true;
      case 'ArrowLeft':
        return this.prevMedia();
      case 'ArrowRight':
        return this.nextMedia();
      default:
        return false;
    }
  }

  // Deep linking
  generateDeepLink(baseUrl, mediaId) {
    if (!this.config.enableDeepLinking || !mediaId) return baseUrl;

    const url = new URL(baseUrl);
    url.searchParams.set('media', mediaId);
    return url.toString();
  }

  parseDeepLink(url) {
    if (!this.config.enableDeepLinking) return null;

    try {
      const urlObj = new URL(url);
      return urlObj.searchParams.get('media');
    } catch {
      return null;
    }
  }

  // Lazy loading support
  markItemLoaded(itemId) {
    this.state.loadedItems.add(itemId);
  }

  isItemLoaded(itemId) {
    return this.state.loadedItems.has(itemId);
  }

  // Preloading logic
  getPreloadItems() {
    if (this.state.currentIndex === null) return [];

    const items = [];
    const current = this.state.currentIndex;

    // Preload previous item
    if (current > 0) {
      items.push(this.config.items[current - 1]);
    }

    // Preload next item
    if (current < this.config.items.length - 1) {
      items.push(this.config.items[current + 1]);
    }

    return items.filter(item => item.type === 'image'); // Only preload images
  }

  // Share functionality
  shareCurrentMedia() {
    const currentItem = this.getCurrentItem();
    if (currentItem && this.callbacks.onShare) {
      this.callbacks.onShare(currentItem);
    }
  }

  // Grid layout helpers
  getThumbnailCols(screenSize) {
    return this.config.thumbnailCols?.[screenSize] || 2;
  }

  // Utility methods
  getMediaCount() {
    return this.config.items.length;
  }

  hasMultipleItems() {
    return this.config.items.length > 1;
  }

  canNavigateNext() {
    return this.state.currentIndex !== null &&
           this.state.currentIndex < this.config.items.length - 1;
  }

  canNavigatePrev() {
    return this.state.currentIndex !== null && this.state.currentIndex > 0;
  }

  // Platform communication (for Flutter web bridge)
  toJSON() {
    return {
      config: this.config,
      state: {
        ...this.state,
        loadedItems: Array.from(this.state.loadedItems)
      },
      currentItem: this.getCurrentItem()
    };
  }
}

// Expose to global scope for Flutter web
window.MediaGalleryCore = MediaGalleryCore;

// Utility functions for bandwidth-aware loading
window.MediaGalleryUtils = {
  // Create optimized thumbnail URLs
  createThumbnailUrl(originalUrl, width = 300, height = 300) {
    // Add your thumbnail generation logic here
    // This could integrate with Cloudinary, ImageKit, or your own service
    return originalUrl; // Fallback to original
  },

  // Check if user is on slow connection
  isSlowConnection() {
    if ('connection' in navigator) {
      const conn = navigator.connection;
      return conn.effectiveType === 'slow-2g' || conn.effectiveType === '2g';
    }
    return false;
  },

  // Preload images with priority
  preloadImage(url, priority = 'low') {
    return new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = () => resolve(img);
      img.onerror = reject;
      img.loading = 'lazy';
      img.fetchPriority = priority;
      img.src = url;
    });
  },

  // Lazy loading intersection observer
  createLazyLoader(callback, rootMargin = '50px') {
    return new IntersectionObserver(callback, { rootMargin });
  }
};