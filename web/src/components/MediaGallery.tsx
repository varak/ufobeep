'use client';

import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { MediaGalleryCore } from '../../../shared/media_gallery_core';
import { MediaItem, MediaGalleryConfig } from '../../../shared/types/media_gallery';

interface MediaGalleryProps extends Partial<MediaGalleryConfig> {
  items: MediaItem[];
  className?: string;
  baseUrl?: string;
}

export default function MediaGallery({ items, className = '', baseUrl = '' }: MediaGalleryProps) {
  const [currentIndex, setCurrentIndex] = useState<number | null>(null);
  const [loadedImages, setLoadedImages] = useState<Set<string>>(new Set());
  const router = useRouter();
  const searchParams = useSearchParams();

  // Handle deep linking
  useEffect(() => {
    const mediaParam = searchParams.get('media');
    if (mediaParam) {
      const index = items.findIndex(item => item.id === mediaParam);
      if (index !== -1) {
        setCurrentIndex(index);
      }
    }
  }, [searchParams, items]);

  // Update URL when media changes
  const updateUrl = useCallback((mediaId: string | null) => {
    const params = new URLSearchParams(searchParams);
    if (mediaId) {
      params.set('media', mediaId);
    } else {
      params.delete('media');
    }

    const newUrl = `${baseUrl}${params.toString() ? '?' + params.toString() : ''}`;
    router.replace(newUrl, { scroll: false });
  }, [router, searchParams, baseUrl]);

  const openMedia = (index: number) => {
    setCurrentIndex(index);
    updateUrl(items[index].id);
  };

  const closeMedia = () => {
    setCurrentIndex(null);
    updateUrl(null);
  };

  const nextMedia = () => {
    if (currentIndex !== null && currentIndex < items.length - 1) {
      const newIndex = currentIndex + 1;
      setCurrentIndex(newIndex);
      updateUrl(items[newIndex].id);
    }
  };

  const prevMedia = () => {
    if (currentIndex !== null && currentIndex > 0) {
      const newIndex = currentIndex - 1;
      setCurrentIndex(newIndex);
      updateUrl(items[newIndex].id);
    }
  };

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (currentIndex === null) return;

      switch (e.key) {
        case 'Escape':
          closeMedia();
          break;
        case 'ArrowLeft':
          prevMedia();
          break;
        case 'ArrowRight':
          nextMedia();
          break;
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [currentIndex]);

  // Lazy loading intersection observer
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const img = entry.target as HTMLImageElement;
            const src = img.dataset.src;
            if (src && !loadedImages.has(src)) {
              img.src = src;
              img.onload = () => {
                setLoadedImages(prev => new Set(prev).add(src));
                img.classList.add('loaded');
              };
              observer.unobserve(img);
            }
          }
        });
      },
      { rootMargin: '50px' }
    );

    const images = document.querySelectorAll('img[data-src]');
    images.forEach(img => observer.observe(img));

    return () => observer.disconnect();
  }, [items, loadedImages]);

  const renderThumbnail = (item: MediaItem, index: number) => {
    const thumbnailUrl = item.thumbnail || item.url;
    const isMuseAiVideo = item.type === 'muse_ai_video';

    return (
      <div
        key={item.id}
        className="relative aspect-square cursor-pointer group overflow-hidden rounded-lg bg-gray-200"
        onClick={() => openMedia(index)}
      >
        {/* Muse.ai video - show video icon placeholder instead of trying to load as image */}
        {isMuseAiVideo ? (
          <div className="absolute inset-0 bg-gradient-to-br from-purple-900 to-blue-900 flex items-center justify-center">
            <div className="text-center">
              <svg className="w-16 h-16 text-white mx-auto mb-2" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clipRule="evenodd" />
              </svg>
              <div className="text-white text-xs font-medium">Click to Play Video</div>
            </div>
          </div>
        ) : (
          <>
            {/* Lazy loaded thumbnail */}
            <img
              data-src={thumbnailUrl}
              alt={item.alt || item.title || `Media ${index + 1}`}
              className="w-full h-full object-cover transition-all duration-300 opacity-0 group-hover:scale-105"
              style={{ willChange: 'transform' }}
            />

            {/* Loading placeholder */}
            <div className="absolute inset-0 bg-gray-300 animate-pulse" />

            {/* Video overlay for regular videos */}
            {item.type === 'video' && (
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="bg-black bg-opacity-50 rounded-full p-3">
                  <svg className="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clipRule="evenodd" />
                  </svg>
                </div>
              </div>
            )}
          </>
        )}

        {/* Hover overlay */}
        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-all duration-300" />
      </div>
    );
  };

  const renderFullscreen = () => {
    if (currentIndex === null) return null;
    const item = items[currentIndex];

    return (
      <div className="fixed inset-0 z-50 bg-black bg-opacity-95 flex items-center justify-center">
        {/* Background overlay */}
        <div
          className="absolute inset-0 cursor-pointer"
          onClick={closeMedia}
        />

        {/* Media container */}
        <div className="relative max-w-[90vw] max-h-[90vh] flex items-center justify-center">
          {item.type === 'image' ? (
            <img
              src={item.url}
              alt={item.alt || item.title || 'Full size image'}
              className="max-w-full max-h-full object-contain"
              style={{ willChange: 'transform' }}
            />
          ) : (
            <video
              src={item.url}
              controls
              autoPlay
              className="max-w-full max-h-full"
              style={{ willChange: 'transform' }}
            />
          )}
        </div>

        {/* Navigation */}
        {items.length > 1 && (
          <>
            {currentIndex > 0 && (
              <button
                onClick={prevMedia}
                className="absolute left-4 top-1/2 -translate-y-1/2 bg-black bg-opacity-50 hover:bg-opacity-75 text-white p-3 rounded-full transition-all duration-200"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
              </button>
            )}

            {currentIndex < items.length - 1 && (
              <button
                onClick={nextMedia}
                className="absolute right-4 top-1/2 -translate-y-1/2 bg-black bg-opacity-50 hover:bg-opacity-75 text-white p-3 rounded-full transition-all duration-200"
              >
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </button>
            )}
          </>
        )}

        {/* Close button */}
        <button
          onClick={closeMedia}
          className="absolute top-4 right-4 bg-black bg-opacity-50 hover:bg-opacity-75 text-white p-3 rounded-full transition-all duration-200"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        {/* Counter */}
        {items.length > 1 && (
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black bg-opacity-50 text-white px-4 py-2 rounded-full text-sm">
            {currentIndex + 1} / {items.length}
          </div>
        )}
      </div>
    );
  };

  return (
    <>
      {/* Thumbnail grid */}
      <div className={`grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 ${className}`}>
        {items.map((item, index) => renderThumbnail(item, index))}
      </div>

      {/* Fullscreen modal */}
      {renderFullscreen()}

      {/* Preload next/prev images for smooth navigation */}
      {currentIndex !== null && (
        <>
          {currentIndex > 0 && items[currentIndex - 1].type === 'image' && (
            <link rel="prefetch" href={items[currentIndex - 1].url} />
          )}
          {currentIndex < items.length - 1 && items[currentIndex + 1].type === 'image' && (
            <link rel="prefetch" href={items[currentIndex + 1].url} />
          )}
        </>
      )}

      <style jsx>{`
        img.loaded {
          opacity: 1 !important;
        }
      `}</style>
    </>
  );
}