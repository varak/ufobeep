/**
 * Shared MediaGallery types and interfaces
 * Used by both Flutter (via dart:js interop) and Next.js web
 */

export interface MediaItem {
  id: string;
  type: 'image' | 'video' | 'muse_ai_video';
  url: string;
  thumbnail?: string;
  title?: string;
  alt?: string;
  width?: number;
  height?: number;
}

export interface MediaGalleryConfig {
  items: MediaItem[];
  enableDeepLinking?: boolean;
  enableKeyboardNav?: boolean;
  enableLazyLoading?: boolean;
  thumbnailCols?: {
    mobile: number;
    tablet: number;
    desktop: number;
  };
  loadingPlaceholder?: string;
  className?: string;
}

export interface MediaGalleryState {
  currentIndex: number | null;
  isFullscreen: boolean;
  loadedItems: Set<string>;
}

export interface MediaGalleryCallbacks {
  onMediaOpen?: (item: MediaItem, index: number) => void;
  onMediaClose?: () => void;
  onMediaChange?: (item: MediaItem, index: number) => void;
  onShare?: (item: MediaItem) => void;
}