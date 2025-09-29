# UFOBeep MCP Server - AI Access to UFO Data

## Overview
UFOBeep now provides a Model Context Protocol (MCP) server for AI systems to access UFO sighting data. This enables AI researchers and UFO enthusiasts to analyze patterns, search sightings, and investigate anomalies using their preferred AI tools.

## Available Endpoints

### Base URL
```
http://ufobeep.com:8000/mcp/
```

### 1. Get Database Statistics
```
GET /mcp/stats
```

**Response:**
```json
{
  "tool": "get_basic_stats",
  "total_sightings": 2879,
  "sightings_with_media": 45,
  "server": "ufobeep"
}
```

### 2. Search UFO Sightings
```
GET /mcp/search?lat=36.2&lon=-115.2&radius=50&limit=20
```

**Parameters:**
- `lat` (required): Latitude for search center
- `lon` (required): Longitude for search center
- `radius` (optional): Search radius in km (default: 50)
- `limit` (optional): Max results to return (default: 20)

**Response:**
```json
{
  "tool": "search_ufo_sightings",
  "sightings": [
    {
      "id": "abc123",
      "title": "UFO Sighting",
      "description": "Triangular craft with three lights",
      "location": {
        "latitude": 36.2456,
        "longitude": -115.2411,
        "name": "Las Vegas, NV"
      },
      "created_at": "2024-09-27T19:30:00Z",
      "witness_count": 3,
      "media_files": [
        {
          "type": "video",
          "url": "https://ufobeep.com/api/media/...",
          "thumbnail_url": "...",
          "filename": "ufo_video.mp4"
        }
      ],
      "enrichment_data": {
        "weather": { "condition": "clear", "temperature_c": 22 },
        "celestial": { "moon_phase": "new", "visible_planets": [...] },
        "aircraft_tracking": { "total": 0 },
        "satellites": { "total_visible_now": 3 }
      }
    }
  ],
  "total_count": 1,
  "search_location": [36.2, -115.2],
  "radius_km": 50
}
```

## Example AI Queries

### Claude Desktop Configuration
```json
{
  "mcpServers": {
    "ufobeep": {
      "command": "node",
      "args": ["-e", "
        const http = require('http');
        const url = require('url');

        const server = http.createServer((req, res) => {
          const parsedUrl = url.parse(req.url, true);
          const endpoint = parsedUrl.pathname.replace('/mcp/', '');
          const query = parsedUrl.query;

          let ufoUrl = `http://ufobeep.com:8000/mcp/${endpoint}`;
          if (Object.keys(query).length > 0) {
            ufoUrl += '?' + new URLSearchParams(query).toString();
          }

          http.get(ufoUrl, (ufoRes) => {
            res.writeHead(ufoRes.statusCode, ufoRes.headers);
            ufoRes.pipe(res);
          });
        });

        server.listen(process.env.MCP_PORT || 3001);
      "]
    }
  }
}
```

### Example Prompts for AI Systems
- **"Find UFO sightings near Area 51 in the last month"**
- **"What are the most common UFO shapes reported in Nevada?"**
- **"Show me sightings with video evidence from September 2024"**
- **"Analyze UFO patterns during clear weather conditions"**
- **"Find sightings that happened when Jupiter was visible"**

## Data Includes

**Core Sighting Data:**
- Location coordinates and names
- Timestamps and descriptions
- Witness counts and verification scores
- Photos and videos with URLs

**Environmental Context:**
- Weather conditions at time of sighting
- Celestial objects (sun, moon, planets, stars)
- Aircraft tracking data
- Satellite positions and passes

**Community Data:**
- Comments and discussions
- Witness confirmations
- MUFON cross-references

## Use Cases

### Research Applications
- **Pattern Recognition**: Find correlations between UFO sightings and environmental factors
- **Geographic Analysis**: Identify UFO hotspots and activity clusters
- **Temporal Studies**: Analyze sighting frequency by time, season, celestial events
- **Cross-Reference Studies**: Correlate with military activity, weather patterns, astronomical events

### AI-Powered Investigations
- **Automated Analysis**: Let AI systems discover patterns humans might miss
- **Data Mining**: Extract insights from thousands of sighting reports
- **Hypothesis Testing**: Test theories about UFO behavior and preferences
- **Report Generation**: Create summaries and analyses for researchers

## Technical Notes

**Rate Limiting**: Currently none - fair use expected
**Authentication**: Public access (no API keys required)
**Data Freshness**: Real-time access to live UFOBeep database
**Format**: Standard JSON responses, easy to parse
**Performance**: Reuses existing optimized database queries

## Limitations

**Current Scope:**
- Read-only access (no data submission)
- Basic search functionality (geographic and temporal)
- Public sightings only (respects privacy settings)

**Future Enhancements:**
- Advanced pattern analysis endpoints
- Machine learning classification APIs
- Real-time alert subscriptions
- Historical trend analysis

## Getting Started

1. **Test the endpoints** using the examples above
2. **Configure your AI tool** to access the MCP server
3. **Start querying** UFO data for your research
4. **Share discoveries** with the UFO community

## Support

For questions about the MCP server or data access:
- **Documentation**: This file and examples
- **Issues**: GitHub repository issues
- **Community**: UFOBeep app user discussions

---

*The UFOBeep MCP server is a community service to advance UFO research through AI analysis. Data is provided as-is for research purposes.*