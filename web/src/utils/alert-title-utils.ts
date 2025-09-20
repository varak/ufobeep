interface Alert {
  id: string
  title: string | null
  description: string | null
  created_at: string
  reporter_username?: string | null
  source?: string | null
  enrichment_data?: {
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
  static getContextualTitle(alert: Alert, t: (key: string) => string): string {
    // Check for MUFON alerts using both source and reporter_username
    const isMufonAlert = alert.source === 'mufon' || alert.reporter_username === 'MUFON';

    // Handle UFOBeep alerts - ALWAYS use proper title
    if (!isMufonAlert) {
      return `UFOBeep ${t('ufo')} ${t('alert')}`;
    }

    // For MUFON alerts, try to extract classification for shape-based titles
    const classification = this.extractCleanClassification(alert.enrichment_data);

    if (classification && classification !== 'unknown' && classification !== 'other') {
      // Use shape-based title like "MUFON Triangle Sighting Report"
      const shapeKey = this.getShapeTranslationKey(classification);
      if (shapeKey) {
        return `MUFON ${t(shapeKey)} ${t('sightingReport')}`;
      }
    }

    // Fallback to generic MUFON title (no case number in hero)
    return `MUFON ${t('sightingReport')}`;
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
   * Extract clean classification from enrichment data
   */
  private static extractCleanClassification(enrichment: any): string | null {
    if (!enrichment) return null;

    let classification: string | null = null;
    let confidence = 0.0;

    // Always check confidence first from classification field
    const classField = enrichment.classification;
    if (classField && typeof classField === 'object') {
      // Get confidence from the classification object
      const confValue = classField.confidence;
      if (typeof confValue === 'number') {
        confidence = confValue;
      }
      // Get type from the classification object
      classification = classField.type?.toString().toLowerCase().trim();
    } else if (typeof classField === 'string') {
      // Extract from string format like "type: sphere"
      const match = classField.match(/type:\s*(\w+)/);
      classification = match?.[1]?.toLowerCase().trim() || classField.toLowerCase().trim();
    }

    // Apply same 0.5 confidence threshold as backend
    if (confidence > 0.0 && confidence < 0.5) {
      return null;  // Too low confidence, don't show classification
    }

    return classification;
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