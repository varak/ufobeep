interface Alert {
  id: string
  title: string | null
  description: string | null
  created_at: string
  reporter_username?: string | null
  source?: string | null
  enrichment?: {
    classification?: {
      type: string
      confidence?: number
    }
    [key: string]: any
  }
  media_files?: Array<{
    id?: string
    type: string
    url: string
    thumbnail_url: string
    web_url?: string
    preview_url?: string
    filename?: string
  }>
}

export class AlertTitleUtils {
  /**
   * Generate a contextual title for an alert based on available data
   */
  static getContextualTitle(alert: Alert, t?: (key: string) => string): string {
    // Check for MUFON alerts using both source and reporter_username
    const isMufonAlert = alert.source === 'mufon' || alert.reporter_username === 'MUFON';

    // Handle UFOBeep alerts - ALWAYS use proper title
    if (!isMufonAlert) {
      if (t) {
        return `UFOBeep ${t('ufo')} ${t('alert')}`;
      }
      return 'UFOBeep UFO Alert';
    }

    // Handle MUFON alerts - check for existing title first
    if (alert.title && alert.title.trim().length > 0) {
      // Handle MUFON titles: "MUFON Triangle Sighting" → "MUFON [Translated Shape] [Translated Sighting Report]"
      if (alert.title.startsWith('MUFON ') && t) {
        const parts = alert.title.split(' ');
        if (parts.length >= 3) {
          const shape = parts[1].toLowerCase();
          // Map shape to translation key
          const shapeKey = this.getShapeTranslationKey(shape);
          if (shapeKey) {
            return `MUFON ${t(shapeKey)} ${t('sightingReport')}`;
          }
        } else if (parts.length === 2 && parts[1] === 'Sighting') {
          // Generic MUFON sighting
          return `MUFON ${t('sightingReport')}`;
        }
      }

      // Return MUFON title as-is if it exists
      return alert.title;
    }
    
    // Check if alert has media
    const hasMedia = alert.media_files && alert.media_files.length > 0;
    
    // Generate contextual title based on available data
    if (hasMedia) {
      const hasPhoto = alert.media_files?.some((media) => 
        media.type.toLowerCase().includes('image')) || false;
      const hasVideo = alert.media_files?.some((media) => 
        media.type.toLowerCase().includes('video')) || false;
      
      if (hasPhoto && hasVideo) {
        return 'Visual sighting (photo & video)';
      } else if (hasVideo) {
        return 'Visual sighting (video)';
      } else if (hasPhoto) {
        return 'Visual sighting (photo)';
      } else {
        return 'Visual sighting';
      }
    }
    
    // Check if it's recent (within last hour)
    const now = new Date();
    const alertTime = new Date(alert.created_at);
    const timeDiff = now.getTime() - alertTime.getTime();
    const minutesDiff = timeDiff / (1000 * 60);
    
    if (minutesDiff < 60) {
      return 'Recent sighting';
    } else if (minutesDiff < 24 * 60) {
      return 'Sighting today';
    }
    
    // Final fallback
    return 'Sighting';
  }
  
  /**
   * Get a short title for lists (more concise than contextual title)
   */
  static getShortTitle(alert: Alert): string {
    // If user provided a title, use it
    if (alert.title && alert.title.trim().length > 0) {
      return alert.title;
    }
    
    // If user provided description, use first 3 words
    if (alert.description && alert.description.trim().length > 0) {
      const words = alert.description.trim().split(' ');
      if (words.length <= 3) {
        return alert.description;
      } else {
        return `${words.slice(0, 3).join(' ')}...`;
      }
    }
    
    // Check for media
    if (alert.media_files && alert.media_files.length > 0) {
      return 'Visual sighting';
    }
    
    // Check timing
    const now = new Date();
    const alertTime = new Date(alert.created_at);
    const timeDiff = now.getTime() - alertTime.getTime();
    const minutesDiff = timeDiff / (1000 * 60);
    
    if (minutesDiff < 10) {
      return 'Live sighting';
    } else if (minutesDiff < 60) {
      return 'Recent sighting';
    }
    
    return 'Sighting';
  }

  /**
   * Map shape names to translation keys
   */
  private static getShapeTranslationKey(shape: string): string | null {
    const shapeMap: { [key: string]: string } = {
      'triangle': 'mufonTriangle',
      'sphere': 'mufonSphere',
      'disc': 'mufonDisc',
      'disk': 'mufonDisk',
      'light': 'mufonLight',
      'cigar': 'mufonCigar',
      'oval': 'mufonOval',
      'cylinder': 'mufonCylinder',
      'rectangle': 'mufonRectangle',
      'diamond': 'mufonDiamond',
      'fireball': 'mufonFireball',
      'formation': 'mufonFormation',
      'boomerang': 'mufonBoomerang',
      'cone': 'mufonCone',
      'cross': 'mufonCross',
      'changing': 'mufonChanging',
      'chevron': 'mufonChevron',
      'egg': 'mufonEgg',
      'flash': 'mufonFlash',
      'other': 'mufonOther'
    };

    return shapeMap[shape.toLowerCase()] || null;
  }
}