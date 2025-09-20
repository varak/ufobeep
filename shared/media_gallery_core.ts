/**
 * Shared MediaGallery core logic
 * Platform-agnostic business logic for media gallery functionality
 */

import { MediaItem, MediaGalleryConfig, MediaGalleryState, MediaGalleryCallbacks } from './types/media_gallery';

export class MediaGalleryCore {
  private config: MediaGalleryConfig;
  private state: MediaGalleryState;
  private callbacks: MediaGalleryCallbacks;

  constructor(config: MediaGalleryConfig, callbacks: MediaGalleryCallbacks = {}) {
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
  }

  // State getters
  getCurrentItem(): MediaItem | null {
    if (this.state.currentIndex === null) return null;
    return this.config.items[this.state.currentIndex] || null;
  }

  getCurrentIndex(): number | null {
    return this.state.currentIndex;
  }

  getItems(): MediaItem[] {
    return this.config.items;
  }

  isFullscreen(): boolean {
    return this.state.isFullscreen;
  }

  // Navigation actions
  openMedia(index: number): void {
    if (index < 0 || index >= this.config.items.length) return;

    this.state.currentIndex = index;
    this.state.isFullscreen = true;

    const item = this.config.items[index];
    this.callbacks.onMediaOpen?.(item, index);
    this.callbacks.onMediaChange?.(item, index);
  }

  openMediaById(id: string): void {
    const index = this.config.items.findIndex(item => item.id === id);
    if (index !== -1) {
      this.openMedia(index);
    }
  }

  closeMedia(): void {
    this.state.currentIndex = null;
    this.state.isFullscreen = false;
    this.callbacks.onMediaClose?.();
  }

  nextMedia(): boolean {
    if (this.state.currentIndex === null) return false;
    if (this.state.currentIndex >= this.config.items.length - 1) return false;

    const newIndex = this.state.currentIndex + 1;
    this.state.currentIndex = newIndex;

    const item = this.config.items[newIndex];
    this.callbacks.onMediaChange?.(item, newIndex);
    return true;
  }

  prevMedia(): boolean {
    if (this.state.currentIndex === null) return false;
    if (this.state.currentIndex <= 0) return false;

    const newIndex = this.state.currentIndex - 1;
    this.state.currentIndex = newIndex;

    const item = this.config.items[newIndex];
    this.callbacks.onMediaChange?.(item, newIndex);
    return true;
  }

  // Keyboard handling
  handleKeyPress(key: string): boolean {
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
  generateDeepLink(baseUrl: string, mediaId?: string): string {
    if (!this.config.enableDeepLinking || !mediaId) return baseUrl;

    const url = new URL(baseUrl);
    url.searchParams.set('media', mediaId);
    return url.toString();
  }

  parseDeepLink(url: string): string | null {
    if (!this.config.enableDeepLinking) return null;

    try {
      const urlObj = new URL(url);
      return urlObj.searchParams.get('media');
    } catch {
      return null;
    }
  }

  // Lazy loading support
  markItemLoaded(itemId: string): void {
    this.state.loadedItems.add(itemId);
  }

  isItemLoaded(itemId: string): boolean {
    return this.state.loadedItems.has(itemId);
  }

  // Preloading logic
  getPreloadItems(): MediaItem[] {
    if (this.state.currentIndex === null) return [];

    const items: MediaItem[] = [];
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
  shareCurrentMedia(): void {
    const currentItem = this.getCurrentItem();
    if (currentItem && this.callbacks.onShare) {
      this.callbacks.onShare(currentItem);
    }
  }

  // Grid layout helpers
  getThumbnailCols(screenSize: 'mobile' | 'tablet' | 'desktop'): number {
    return this.config.thumbnailCols?.[screenSize] || 2;
  }

  // Utility methods
  getMediaCount(): number {
    return this.config.items.length;
  }

  hasMultipleItems(): boolean {
    return this.config.items.length > 1;
  }

  canNavigateNext(): boolean {
    return this.state.currentIndex !== null &&
           this.state.currentIndex < this.config.items.length - 1;
  }

  canNavigatePrev(): boolean {
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