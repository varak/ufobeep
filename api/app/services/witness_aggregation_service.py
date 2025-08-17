"""
Witness Aggregation Service - Task 7
Handles triangulation, consensus building, and auto-escalation
"""

import math
import logging
from typing import List, Dict, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass
import asyncio
import asyncpg

logger = logging.getLogger(__name__)

@dataclass
class WitnessPoint:
    """Single witness observation point"""
    device_id: str
    latitude: float
    longitude: float
    bearing_deg: Optional[float]
    timestamp: datetime
    accuracy: Optional[float] = None
    altitude: Optional[float] = None
    still_visible: bool = True

@dataclass
class TriangulationResult:
    """Result of triangulation analysis"""
    object_latitude: Optional[float]
    object_longitude: Optional[float] 
    confidence_score: float  # 0.0 - 1.0
    consensus_quality: str  # "excellent", "good", "poor", "insufficient"
    witness_count: int
    agreement_percentage: float
    average_bearing_error: Optional[float]
    estimated_radius_meters: Optional[float]
    should_escalate: bool

class WitnessAggregationService:
    """Service for analyzing witness reports and building consensus"""
    
    def __init__(self, db_pool):
        self.db_pool = db_pool
        
    async def analyze_sighting_consensus(self, sighting_id: str) -> TriangulationResult:
        """
        Analyze all witnesses for a sighting and determine consensus
        """
        try:
            async with self.db_pool.acquire() as conn:
                # Get all witnesses for this sighting
                witnesses = await self._get_witnesses(conn, sighting_id)
                
                if len(witnesses) < 2:
                    return TriangulationResult(
                        object_latitude=None,
                        object_longitude=None,
                        confidence_score=0.0,
                        consensus_quality="insufficient",
                        witness_count=len(witnesses),
                        agreement_percentage=0.0,
                        average_bearing_error=None,
                        estimated_radius_meters=None,
                        should_escalate=False
                    )
                
                # Calculate triangulation if we have bearings
                triangulated_location = await self._triangulate_object_location(witnesses)
                
                # Calculate consensus metrics
                consensus_metrics = await self._calculate_consensus_metrics(witnesses, triangulated_location)
                
                # Determine if auto-escalation should trigger
                should_escalate = await self._should_auto_escalate(sighting_id, witnesses, consensus_metrics)
                
                return TriangulationResult(
                    object_latitude=triangulated_location[0] if triangulated_location else None,
                    object_longitude=triangulated_location[1] if triangulated_location else None,
                    confidence_score=consensus_metrics['confidence_score'],
                    consensus_quality=consensus_metrics['quality_rating'],
                    witness_count=len(witnesses),
                    agreement_percentage=consensus_metrics['agreement_percentage'],
                    average_bearing_error=consensus_metrics['bearing_error'],
                    estimated_radius_meters=consensus_metrics['radius_meters'],
                    should_escalate=should_escalate
                )
                
        except Exception as e:
            logger.error(f"Error analyzing consensus for sighting {sighting_id}: {e}")
            raise
    
    async def _get_witnesses(self, conn, sighting_id: str) -> List[WitnessPoint]:
        """Get all witness confirmations for a sighting"""
        query = """
        SELECT 
            device_id,
            latitude,
            longitude, 
            bearing_deg,
            timestamp,
            accuracy,
            altitude,
            still_visible
        FROM witness_confirmations 
        WHERE sighting_id = $1
        ORDER BY timestamp ASC
        """
        
        rows = await conn.fetch(query, sighting_id)
        witnesses = []
        
        for row in rows:
            witnesses.append(WitnessPoint(
                device_id=row['device_id'],
                latitude=row['latitude'],
                longitude=row['longitude'],
                bearing_deg=row['bearing_deg'],
                timestamp=row['timestamp'],
                accuracy=row['accuracy'],
                altitude=row['altitude'],
                still_visible=row['still_visible']
            ))
            
        return witnesses
    
    async def _triangulate_object_location(self, witnesses: List[WitnessPoint]) -> Optional[Tuple[float, float]]:
        """
        Triangulate object location from witness bearing lines
        Uses least squares intersection method
        """
        if len(witnesses) < 2:
            return None
            
        # Filter witnesses with valid bearings
        bearing_witnesses = [w for w in witnesses if w.bearing_deg is not None]
        if len(bearing_witnesses) < 2:
            return None
            
        # Convert bearings to line equations
        lines = []
        for witness in bearing_witnesses:
            # Convert bearing to cartesian line
            bearing_rad = math.radians(witness.bearing_deg)
            
            # Line direction vector (bearing is clockwise from north)
            dx = math.sin(bearing_rad)
            dy = math.cos(bearing_rad)
            
            lines.append({
                'x0': witness.longitude,
                'y0': witness.latitude,
                'dx': dx,
                'dy': dy
            })
        
        # Find best intersection point using least squares
        if len(lines) == 2:
            # Simple two-line intersection
            return self._intersect_two_lines(lines[0], lines[1])
        else:
            # Multiple lines - use least squares method
            return self._intersect_multiple_lines(lines)
    
    def _intersect_two_lines(self, line1: Dict, line2: Dict) -> Optional[Tuple[float, float]]:
        """Find intersection of two bearing lines"""
        x1, y1, dx1, dy1 = line1['x0'], line1['y0'], line1['dx'], line1['dy']
        x2, y2, dx2, dy2 = line2['x0'], line2['y0'], line2['dx'], line2['dy']
        
        # Solve parametric line intersection
        denominator = dx1 * dy2 - dy1 * dx2
        if abs(denominator) < 1e-10:  # Lines are parallel
            return None
            
        t = ((x2 - x1) * dy2 - (y2 - y1) * dx2) / denominator
        
        # Calculate intersection point
        intersection_x = x1 + t * dx1
        intersection_y = y1 + t * dy1
        
        return (intersection_y, intersection_x)  # Return as (lat, lon)
    
    def _intersect_multiple_lines(self, lines: List[Dict]) -> Optional[Tuple[float, float]]:
        """Find best-fit intersection of multiple lines using least squares"""
        # This is a simplified implementation
        # For production, consider using proper least squares line intersection
        
        intersections = []
        
        # Get all pairwise intersections
        for i in range(len(lines)):
            for j in range(i + 1, len(lines)):
                intersection = self._intersect_two_lines(lines[i], lines[j])
                if intersection:
                    intersections.append(intersection)
        
        if not intersections:
            return None
            
        # Return centroid of all intersections
        avg_lat = sum(p[0] for p in intersections) / len(intersections)
        avg_lon = sum(p[1] for p in intersections) / len(intersections)
        
        return (avg_lat, avg_lon)
    
    async def _calculate_consensus_metrics(self, witnesses: List[WitnessPoint], triangulated_location: Optional[Tuple[float, float]]) -> Dict:
        """Calculate consensus quality metrics"""
        witness_count = len(witnesses)
        
        if witness_count < 2:
            return {
                'confidence_score': 0.0,
                'quality_rating': 'insufficient',
                'agreement_percentage': 0.0,
                'bearing_error': None,
                'radius_meters': None
            }
        
        # Calculate temporal clustering (witnesses reporting within timeframe)
        time_spread = self._calculate_time_spread(witnesses)
        temporal_score = max(0.0, 1.0 - (time_spread.total_seconds() / 3600))  # Decay over 1 hour
        
        # Calculate spatial clustering (witnesses from different locations)
        spatial_spread = self._calculate_spatial_spread(witnesses)
        spatial_score = min(1.0, spatial_spread / 1000)  # Normalize to 1km = 1.0
        
        # Calculate bearing agreement if we have triangulated location
        bearing_score = 0.5  # Default
        bearing_error = None
        if triangulated_location and len([w for w in witnesses if w.bearing_deg is not None]) >= 2:
            bearing_error = self._calculate_bearing_agreement(witnesses, triangulated_location)
            bearing_score = max(0.0, 1.0 - (bearing_error / 45.0))  # 45 degrees = 0 score
        
        # Combined confidence score
        confidence_score = (temporal_score * 0.3 + spatial_score * 0.3 + bearing_score * 0.4)
        
        # Quality rating
        if confidence_score >= 0.8:
            quality_rating = "excellent"
        elif confidence_score >= 0.6:
            quality_rating = "good"
        elif confidence_score >= 0.3:
            quality_rating = "poor"
        else:
            quality_rating = "insufficient"
        
        # Agreement percentage (simplified)
        agreement_percentage = confidence_score * 100
        
        # Estimated radius (uncertainty)
        radius_meters = None
        if triangulated_location:
            radius_meters = max(100, (1.0 - confidence_score) * 5000)  # 100m to 5km uncertainty
        
        return {
            'confidence_score': confidence_score,
            'quality_rating': quality_rating,
            'agreement_percentage': agreement_percentage,
            'bearing_error': bearing_error,
            'radius_meters': radius_meters
        }
    
    def _calculate_time_spread(self, witnesses: List[WitnessPoint]) -> timedelta:
        """Calculate time spread between first and last witness"""
        if len(witnesses) < 2:
            return timedelta(0)
            
        timestamps = [w.timestamp for w in witnesses]
        return max(timestamps) - min(timestamps)
    
    def _calculate_spatial_spread(self, witnesses: List[WitnessPoint]) -> float:
        """Calculate spatial spread of witnesses in meters"""
        if len(witnesses) < 2:
            return 0.0
            
        max_distance = 0.0
        for i in range(len(witnesses)):
            for j in range(i + 1, len(witnesses)):
                distance = self._haversine_distance(
                    witnesses[i].latitude, witnesses[i].longitude,
                    witnesses[j].latitude, witnesses[j].longitude
                )
                max_distance = max(max_distance, distance)
                
        return max_distance
    
    def _calculate_bearing_agreement(self, witnesses: List[WitnessPoint], object_location: Tuple[float, float]) -> float:
        """Calculate average bearing error from witnesses to triangulated object"""
        bearing_witnesses = [w for w in witnesses if w.bearing_deg is not None]
        if not bearing_witnesses:
            return 0.0
            
        errors = []
        obj_lat, obj_lon = object_location
        
        for witness in bearing_witnesses:
            # Calculate expected bearing to object
            expected_bearing = self._calculate_bearing(
                witness.latitude, witness.longitude,
                obj_lat, obj_lon
            )
            
            # Calculate angular difference
            reported_bearing = witness.bearing_deg
            error = abs(self._angle_difference(reported_bearing, expected_bearing))
            errors.append(error)
        
        return sum(errors) / len(errors) if errors else 0.0
    
    async def _should_auto_escalate(self, sighting_id: str, witnesses: List[WitnessPoint], consensus_metrics: Dict) -> bool:
        """Determine if sighting should be auto-escalated based on consensus"""
        witness_count = len(witnesses)
        confidence_score = consensus_metrics['confidence_score']
        
        # Auto-escalate conditions:
        # 1. 3+ witnesses within 60 seconds with good consensus
        # 2. 5+ witnesses regardless of timing
        # 3. High confidence score (>0.8) with 3+ witnesses
        
        recent_witnesses = [
            w for w in witnesses 
            if (datetime.utcnow() - w.timestamp).total_seconds() <= 60
        ]
        
        # Condition 1: 3+ recent witnesses with good consensus
        if len(recent_witnesses) >= 3 and confidence_score >= 0.6:
            logger.info(f"Auto-escalating {sighting_id}: {len(recent_witnesses)} recent witnesses, confidence {confidence_score:.2f}")
            return True
            
        # Condition 2: 5+ total witnesses
        if witness_count >= 5:
            logger.info(f"Auto-escalating {sighting_id}: {witness_count} total witnesses")
            return True
            
        # Condition 3: High confidence with 3+ witnesses
        if witness_count >= 3 and confidence_score >= 0.8:
            logger.info(f"Auto-escalating {sighting_id}: High confidence {confidence_score:.2f} with {witness_count} witnesses")
            return True
        
        return False
    
    def _haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points in meters"""
        R = 6371000  # Earth's radius in meters
        
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lon = math.radians(lon2 - lon1)
        
        a = (math.sin(delta_lat / 2) ** 2 +
             math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        return R * c
    
    def _calculate_bearing(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate bearing from point 1 to point 2 in degrees"""
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lon = math.radians(lon2 - lon1)
        
        y = math.sin(delta_lon) * math.cos(lat2_rad)
        x = (math.cos(lat1_rad) * math.sin(lat2_rad) -
             math.sin(lat1_rad) * math.cos(lat2_rad) * math.cos(delta_lon))
        
        bearing_rad = math.atan2(y, x)
        bearing_deg = math.degrees(bearing_rad)
        
        # Normalize to 0-360
        return (bearing_deg + 360) % 360
    
    def _angle_difference(self, angle1: float, angle2: float) -> float:
        """Calculate smallest angle difference between two bearings"""
        diff = abs(angle1 - angle2)
        return min(diff, 360 - diff)
    
    async def get_witness_heat_map_data(self, sighting_id: str) -> Dict:
        """Get heat map data for admin dashboard"""
        try:
            async with self.db_pool.acquire() as conn:
                witnesses = await self._get_witnesses(conn, sighting_id)
                
                # Format for heat map visualization
                heat_map_points = []
                for witness in witnesses:
                    heat_map_points.append({
                        'latitude': witness.latitude,
                        'longitude': witness.longitude,
                        'timestamp': witness.timestamp.isoformat(),
                        'bearing': witness.bearing_deg,
                        'accuracy': witness.accuracy,
                        'still_visible': witness.still_visible
                    })
                
                # Get aggregation analysis
                analysis = await self.analyze_sighting_consensus(sighting_id)
                
                return {
                    'sighting_id': sighting_id,
                    'witness_points': heat_map_points,
                    'triangulation': {
                        'object_latitude': analysis.object_latitude,
                        'object_longitude': analysis.object_longitude,
                        'confidence_score': analysis.confidence_score,
                        'consensus_quality': analysis.consensus_quality,
                        'estimated_radius_meters': analysis.estimated_radius_meters
                    },
                    'summary': {
                        'total_witnesses': analysis.witness_count,
                        'agreement_percentage': analysis.agreement_percentage,
                        'should_escalate': analysis.should_escalate
                    }
                }
                
        except Exception as e:
            logger.error(f"Error getting heat map data for {sighting_id}: {e}")
            raise

# Global instance
witness_aggregation_service = None

def get_witness_aggregation_service(db_pool):
    """Get or create witness aggregation service instance"""
    global witness_aggregation_service
    if witness_aggregation_service is None:
        witness_aggregation_service = WitnessAggregationService(db_pool)
    return witness_aggregation_service