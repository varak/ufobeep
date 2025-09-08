import { useState, useEffect } from 'react'

interface GeolocationPosition {
  latitude: number
  longitude: number
}

interface GeolocationState {
  position: GeolocationPosition | null
  loading: boolean
  error: string | null
}

export function useGeolocation(): GeolocationState {
  const [state, setState] = useState<GeolocationState>({
    position: null,
    loading: true,
    error: null
  })

  useEffect(() => {
    if (!navigator.geolocation) {
      setState({
        position: null,
        loading: false,
        error: 'Geolocation is not supported by this browser'
      })
      return
    }

    const success = (position: any) => {
      setState({
        position: {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        },
        loading: false,
        error: null
      })
    }

    const error = (err: any) => {
      setState({
        position: null,
        loading: false,
        error: err.message || 'Unable to retrieve location'
      })
    }

    navigator.geolocation.getCurrentPosition(success, error, {
      enableHighAccuracy: false,
      timeout: 10000,
      maximumAge: 600000 // 10 minutes
    })
  }, [])

  return state
}

export function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371 // Earth's radius in kilometers
  const dLat = toRad(lat2 - lat1)
  const dLon = toRad(lon2 - lon1)
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

function toRad(value: number): number {
  return (value * Math.PI) / 180
}

export function formatDistance(distanceKm: number): string {
  if (distanceKm < 1) {
    return `${Math.round(distanceKm * 1000)}m away`
  } else if (distanceKm < 10) {
    return `${distanceKm.toFixed(1)}km away`
  } else {
    return `${Math.round(distanceKm)}km away`
  }
}