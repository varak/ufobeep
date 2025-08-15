'use client';

import { useEffect, useState } from 'react';
import dynamic from 'next/dynamic';
import { MapPin, Camera, FileText, Calendar, Users, AlertCircle } from 'lucide-react';

// Dynamic import for map component to avoid SSR issues
const Map = dynamic(() => import('./Map'), { ssr: false });

interface Sighting {
  id: string;
  title: string;
  description: string;
  location: {
    latitude: number;
    longitude: number;
    name: string;
  };
  created_at: string;
  source: 'ufobeep' | 'mufon';
  media_count?: number;
  witness_count?: number;
  alert_level?: string;
}

export default function UnifiedSightingsMap() {
  const [sightings, setSightings] = useState<Sighting[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'ufobeep' | 'mufon'>('all');

  useEffect(() => {
    fetchSightings();
  }, []);

  const fetchSightings = async () => {
    try {
      // Fetch UFOBeep sightings
      const ufobeepRes = await fetch('https://api.ufobeep.com/alerts?limit=100');
      const ufobeepData = await ufobeepRes.json();
      
      // Fetch MUFON sightings
      const mufonRes = await fetch('https://api.ufobeep.com/mufon/recent?days=30');
      const mufonData = await mufonRes.json();
      
      // Combine and format
      const combined: Sighting[] = [];
      
      // Add UFOBeep sightings
      if (ufobeepData.success && ufobeepData.data?.alerts) {
        ufobeepData.data.alerts.forEach((alert: any) => {
          if (alert.location?.latitude && alert.location?.longitude) {
            combined.push({
              id: alert.id,
              title: alert.title,
              description: alert.description,
              location: alert.location,
              created_at: alert.created_at,
              source: 'ufobeep',
              media_count: alert.media_files?.length || 0,
              witness_count: alert.witness_count,
              alert_level: alert.alert_level
            });
          }
        });
      }
      
      // Add MUFON sightings
      if (mufonData.success && mufonData.sightings) {
        mufonData.sightings.forEach((sighting: any) => {
          if (sighting.location?.latitude && sighting.location?.longitude) {
            combined.push({
              id: sighting.id,
              title: sighting.short_description || 'MUFON Report',
              description: sighting.long_description || sighting.short_description,
              location: {
                latitude: sighting.location.latitude,
                longitude: sighting.location.longitude,
                name: sighting.location.raw || 'Unknown Location'
              },
              created_at: sighting.date_event || sighting.import_date,
              source: 'mufon',
              media_count: sighting.attachments?.length || 0
            });
          }
        });
      }
      
      setSightings(combined);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching sightings:', error);
      setLoading(false);
    }
  };

  const filteredSightings = sightings.filter(s => 
    filter === 'all' || s.source === filter
  );

  const getMarkerIcon = (sighting: Sighting) => {
    if (sighting.source === 'ufobeep') {
      return '🔔'; // Bell for UFOBeep (beep alerts)
    } else {
      return '📋'; // Clipboard for MUFON reports
    }
  };

  const getMarkerColor = (sighting: Sighting) => {
    if (sighting.source === 'ufobeep') {
      return sighting.alert_level === 'high' ? '#FF0000' : '#00FF00';
    } else {
      return '#FFA500'; // Orange for MUFON
    }
  };

  return (
    <div className="unified-sightings-map">
      {/* Filter Controls */}
      <div className="bg-gray-900 p-4 rounded-lg mb-4">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-bold text-white">UFO Sightings Map</h2>
          <div className="flex gap-2">
            <button
              onClick={() => setFilter('all')}
              className={`px-4 py-2 rounded ${
                filter === 'all' 
                  ? 'bg-blue-600 text-white' 
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              All ({sightings.length})
            </button>
            <button
              onClick={() => setFilter('ufobeep')}
              className={`px-4 py-2 rounded flex items-center gap-2 ${
                filter === 'ufobeep'
                  ? 'bg-green-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              🔔 UFOBeep ({sightings.filter(s => s.source === 'ufobeep').length})
            </button>
            <button
              onClick={() => setFilter('mufon')}
              className={`px-4 py-2 rounded flex items-center gap-2 ${
                filter === 'mufon'
                  ? 'bg-orange-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              📋 MUFON ({sightings.filter(s => s.source === 'mufon').length})
            </button>
          </div>
        </div>
        
        {/* Legend */}
        <div className="mt-4 flex gap-4 text-sm text-gray-400">
          <div className="flex items-center gap-2">
            <span className="text-2xl">🔔</span>
            <span>Live UFOBeep Alert (notifies nearby users)</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-2xl">📋</span>
            <span>MUFON Report (historical data, no alerts)</span>
          </div>
        </div>
      </div>

      {/* Map */}
      <div className="h-[600px] rounded-lg overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center h-full bg-gray-900">
            <div className="text-white">Loading sightings...</div>
          </div>
        ) : (
          <Map 
            sightings={filteredSightings}
            getMarkerIcon={getMarkerIcon}
            getMarkerColor={getMarkerColor}
          />
        )}
      </div>

      {/* Stats */}
      <div className="mt-4 grid grid-cols-3 gap-4">
        <div className="bg-gray-900 p-4 rounded-lg text-center">
          <div className="text-3xl font-bold text-green-400">
            {sightings.filter(s => s.source === 'ufobeep').length}
          </div>
          <div className="text-gray-400 text-sm">Live UFOBeep Alerts</div>
        </div>
        <div className="bg-gray-900 p-4 rounded-lg text-center">
          <div className="text-3xl font-bold text-orange-400">
            {sightings.filter(s => s.source === 'mufon').length}
          </div>
          <div className="text-gray-400 text-sm">MUFON Reports</div>
        </div>
        <div className="bg-gray-900 p-4 rounded-lg text-center">
          <div className="text-3xl font-bold text-blue-400">
            {sightings.filter(s => s.media_count && s.media_count > 0).length}
          </div>
          <div className="text-gray-400 text-sm">With Media</div>
        </div>
      </div>

      {/* Recent Sightings List */}
      <div className="mt-6 bg-gray-900 p-4 rounded-lg">
        <h3 className="text-lg font-bold text-white mb-4">Recent Sightings</h3>
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {filteredSightings.slice(0, 20).map(sighting => (
            <div 
              key={sighting.id}
              className="bg-gray-800 p-3 rounded flex items-start gap-3 hover:bg-gray-700 transition-colors"
            >
              <span className="text-2xl">{getMarkerIcon(sighting)}</span>
              <div className="flex-1">
                <div className="font-semibold text-white">{sighting.title}</div>
                <div className="text-sm text-gray-400 flex items-center gap-4 mt-1">
                  <span className="flex items-center gap-1">
                    <MapPin size={14} />
                    {sighting.location.name}
                  </span>
                  <span className="flex items-center gap-1">
                    <Calendar size={14} />
                    {new Date(sighting.created_at).toLocaleDateString()}
                  </span>
                  {sighting.media_count > 0 && (
                    <span className="flex items-center gap-1">
                      <Camera size={14} />
                      {sighting.media_count}
                    </span>
                  )}
                </div>
              </div>
              {sighting.source === 'ufobeep' && sighting.alert_level === 'high' && (
                <AlertCircle className="text-red-500" size={20} />
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}