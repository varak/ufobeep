'use client'

import { useState } from 'react'
import Image from 'next/image'

interface ImageWithLoadingProps {
  src: string
  alt: string
  fill?: boolean
  className?: string
  onError?: (e: any) => void
  width?: number
  height?: number
  priority?: boolean
  sizes?: string
}

export default function ImageWithLoading({
  src,
  alt,
  fill = false,
  className = '',
  onError,
  width,
  height,
  priority = false,
  sizes
}: ImageWithLoadingProps) {
  const [isLoading, setIsLoading] = useState(true)
  const [hasError, setHasError] = useState(false)

  const handleLoad = () => {
    console.log('Image loaded successfully:', src)
    setIsLoading(false)
  }

  const handleError = (e: any) => {
    console.error('Image failed to load:', src, e)
    setIsLoading(false)
    setHasError(true)
    if (onError) onError(e)
  }

  return (
    <div className="relative">
      {/* Loading skeleton */}
      {isLoading && !hasError && (
        <div className="absolute inset-0 bg-gray-800 animate-pulse flex items-center justify-center">
          <div className="text-center">
            <div className="text-2xl mb-2">📸</div>
            <div className="text-xs text-text-tertiary">Loading...</div>
          </div>
        </div>
      )}

      {/* Error fallback */}
      {hasError && (
        <div className="absolute inset-0 bg-gray-800 flex items-center justify-center">
          <div className="text-center">
            <div className="text-2xl mb-2">📸</div>
            <div className="text-xs text-text-tertiary">Image unavailable</div>
          </div>
        </div>
      )}

      {/* Actual image */}
      {src.includes('api.ufobeep.com') ? (
        // Use regular img tag for API images to bypass Next.js optimization issues
        <img
          src={src}
          alt={alt}
          className={`${className} ${isLoading ? 'opacity-0' : 'opacity-100'} transition-opacity duration-300 ${fill ? 'w-full h-full object-cover' : ''}`}
          onLoad={handleLoad}
          onError={handleError}
          style={fill ? { position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' } : { width, height }}
        />
      ) : (
        <Image
          src={src}
          alt={alt}
          fill={fill}
          width={!fill ? width : undefined}
          height={!fill ? height : undefined}
          className={`${className} ${isLoading ? 'opacity-0' : 'opacity-100'} transition-opacity duration-300`}
          onLoad={handleLoad}
          onError={handleError}
          priority={priority}
          sizes={sizes || (fill ? "100vw" : undefined)}
        />
      )}
    </div>
  )
}