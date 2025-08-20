'use client'

import { useEffect, useState } from 'react'
import { UnitConversion } from '../utils/unitConversion'

interface WitnessLocation {
  lat: number
  lon: number
  alt?: number
}

interface Witness {
  device_id: string
  location: WitnessLocation
  bearing_deg?: number
  distance_km?: number
  accuracy_m?: number
  still_visible: boolean
  confirmed_at: string
  type: string
}

interface Triangulation {
  estimated_location: {
    lat: number
    lon: number
  }
  confidence_percent: number
  witness_bearings_used: number
  method: string
}

interface HeatMapCell {
  cell_center: {
    lat: number
    lon: number
  }
  witness_count: number
  intensity: number
}

interface Consensus {
  visibility_consensus_percent: number
  average_distance_km?: number
  confirmation_time_span_minutes: number
  total_witnesses: number
  still_visible_count: number
}

interface WitnessAggregationData {
  sighting_id: string
  witness_count: number
  witnesses: Witness[]
  triangulation?: Triangulation
  heat_map_data: HeatMapCell[]
  consensus?: Consensus
  escalation_level: string
  timestamp: string
}

interface WitnessAggregationProps {
  sightingId: string
}

export default function WitnessAggregation({ sightingId }: WitnessAggregationProps) {
  const [data, setData] = useState<WitnessAggregationData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  // Website defaults to imperial units
  const units = 'imperial';

  useEffect(() => {
    fetchWitnessAggregation()
  }, [sightingId])

  const fetchWitnessAggregation = async () => {
    try {
      setLoading(true)
      const response = await fetch(`https://api.ufobeep.com/alerts/${sightingId}/witness-aggregation`)
      
      if (!response.ok) {
        throw new Error(`Failed to fetch witness aggregation: ${response.statusText}`)
      }
      
      const aggregationData = await response.json()
      setData(aggregationData)
    } catch (err) {
      console.error('Error fetching witness aggregation:', err)
      setError(err instanceof Error ? err.message : 'Failed to load witness data')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="p-6 bg-gray-900 rounded-lg border border-gray-700">
        <div className="flex items-center justify-center space-x-2">
          <div className="w-4 h-4 bg-blue-500 rounded-full animate-pulse"></div>
          <span className="text-gray-300">Loading witness analysis...</span>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-6 bg-gray-900 rounded-lg border border-red-800">
        <div className="text-red-400">
          <h3 className="font-semibold mb-2">Analysis Error</h3>
          <p className="text-sm">{error}</p>
        </div>
      </div>
    )
  }

  if (!data || data.witness_count === 0) {
    return (
      <div className="p-6 bg-gray-900 rounded-lg border border-gray-700">
        <div className="text-center text-gray-400">
          <h3 className="font-semibold mb-2">👁️ No Witness Confirmations Yet</h3>
          <p className="text-sm">Once people confirm &quot;I SEE IT TOO&quot;, witness analysis will appear here.</p>
        </div>
      </div>
    )
  }

  const getEscalationColor = (level: string) => {
    switch (level) {
      case 'emergency': return 'text-red-400 bg-red-900/20 border-red-800'
      case 'urgent': return 'text-orange-400 bg-orange-900/20 border-orange-800'
      default: return 'text-green-400 bg-green-900/20 border-green-800'
    }
  }

  return (
    <div className="space-y-6">
      {/* Header with escalation status */}
      <div className="flex items-center justify-between">
        <h3 className="text-xl font-bold text-white">Witness Analysis</h3>
        <div className={`px-3 py-1 rounded-full border text-sm font-medium ${getEscalationColor(data.escalation_level)}`}>
          {data.escalation_level.toUpperCase()} ({data.witness_count} witnesses)
        </div>
      </div>

      {/* Consensus metrics */}
      {data.consensus && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="bg-gray-800 p-4 rounded-lg border border-gray-700">
            <div className="text-2xl font-bold text-green-400">
              {Math.round(data.consensus.visibility_consensus_percent)}%
            </div>
            <div className="text-sm text-gray-400">Still Visible</div>
            <div className="text-xs text-gray-500">
              {data.consensus.still_visible_count}/{data.consensus.total_witnesses} witnesses
            </div>
          </div>

          {data.consensus.average_distance_km && (
            <div className="bg-gray-800 p-4 rounded-lg border border-gray-700">
              <div className="text-2xl font-bold text-blue-400">
                {UnitConversion.formatDistanceFromKm(data.consensus.average_distance_km, units)}
              </div>
              <div className="text-sm text-gray-400">Avg Distance</div>
              <div className="text-xs text-gray-500">Estimated range</div>
            </div>
          )}

          <div className="bg-gray-800 p-4 rounded-lg border border-gray-700">
            <div className="text-2xl font-bold text-purple-400">
              {Math.round(data.consensus.confirmation_time_span_minutes)}min
            </div>
            <div className="text-sm text-gray-400">Time Span</div>
            <div className="text-xs text-gray-500">Duration of sighting</div>
          </div>

          <div className="bg-gray-800 p-4 rounded-lg border border-gray-700">
            <div className="text-2xl font-bold text-yellow-400">
              {data.witness_count}
            </div>
            <div className="text-sm text-gray-400">Total Witnesses</div>
            <div className="text-xs text-gray-500">Confirmed sighting</div>
          </div>
        </div>
      )}

      {/* Triangulation results */}
      {data.triangulation && (
        <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
          <h4 className="text-lg font-semibold text-white mb-4">📐 Location Triangulation</h4>
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <div className="text-sm text-gray-400 mb-2">Estimated Object Location</div>
              <div className="text-white font-mono">
                {data.triangulation.estimated_location.lat.toFixed(6)}, {data.triangulation.estimated_location.lon.toFixed(6)}
              </div>
            </div>
            <div>
              <div className="text-sm text-gray-400 mb-2">Confidence</div>
              <div className="flex items-center space-x-2">
                <div className="text-white font-semibold">
                  {Math.round(data.triangulation.confidence_percent)}%
                </div>
                <div className="text-xs text-gray-500">
                  ({data.triangulation.witness_bearings_used} bearings)
                </div>
              </div>
            </div>
          </div>
          <div className="mt-3 text-xs text-gray-500">
            Method: {data.triangulation.method}
          </div>
        </div>
      )}

      {/* Witness heat map data */}
      {data.heat_map_data.length > 0 && (
        <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
          <h4 className="text-lg font-semibold text-white mb-4">🔥 Witness Density Map</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {data.heat_map_data.slice(0, 6).map((cell, index) => (
              <div key={index} className="bg-gray-900 p-3 rounded border border-gray-600">
                <div className="text-sm text-gray-300">
                  {cell.cell_center.lat.toFixed(4)}, {cell.cell_center.lon.toFixed(4)}
                </div>
                <div className="flex items-center justify-between mt-1">
                  <span className="text-white font-semibold">{cell.witness_count} witnesses</span>
                  <div 
                    className="w-4 h-4 rounded-full bg-red-500"
                    style={{ opacity: cell.intensity }}
                    title={`Intensity: ${Math.round(cell.intensity * 100)}%`}
                  ></div>
                </div>
              </div>
            ))}
          </div>
          {data.heat_map_data.length > 6 && (
            <div className="mt-3 text-sm text-gray-400">
              +{data.heat_map_data.length - 6} more density areas
            </div>
          )}
        </div>
      )}

      {/* Recent witnesses list */}
      <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
        <h4 className="text-lg font-semibold text-white mb-4">👥 Recent Witnesses</h4>
        <div className="space-y-3 max-h-64 overflow-y-auto">
          {data.witnesses.slice(0, 10).map((witness, index) => (
            <div key={witness.device_id} className="flex items-center justify-between p-3 bg-gray-900 rounded border border-gray-600">
              <div className="flex items-center space-x-3">
                <div className="text-sm text-gray-400">#{index + 1}</div>
                <div>
                  <div className="text-white text-sm">
                    {witness.location.lat.toFixed(4)}, {witness.location.lon.toFixed(4)}
                  </div>
                  <div className="text-xs text-gray-500">
                    {new Date(witness.confirmed_at).toLocaleTimeString()}
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className={`text-sm ${witness.still_visible ? 'text-green-400' : 'text-gray-400'}`}>
                  {witness.still_visible ? '👁️ Visible' : '⚫ Gone'}
                </div>
                {witness.distance_km && (
                  <div className="text-xs text-gray-500">
                    ~{UnitConversion.formatDistanceFromKm(witness.distance_km, units)} away
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
        {data.witnesses.length > 10 && (
          <div className="mt-3 text-sm text-gray-400">
            +{data.witnesses.length - 10} more witnesses
          </div>
        )}
      </div>

      <div className="text-xs text-gray-500 text-center">
        Last updated: {new Date(data.timestamp).toLocaleString()}
      </div>
    </div>
  )
}