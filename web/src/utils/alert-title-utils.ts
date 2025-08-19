interface Alert {
  id: string
  title: string | null
  description: string | null
  created_at: string
  media_files?: Array<{
    id: string
    type: string
    url: string
    thumbnail_url: string
    is_primary: boolean
    upload_order: number
    display_priority: number
  }>
}

export class AlertTitleUtils {
  /**
   * Generate a contextual title for an alert based on available data
   */
  static getContextualTitle(alert: Alert): string {
    // If user provided a title, use it
    if (alert.title && alert.title.trim().length > 0) {
      return alert.title;
    }
    
    // If user provided description, use first few words as title
    if (alert.description && alert.description.trim().length > 0) {
      const words = alert.description.trim().split(' ');
      if (words.length <= 4) {
        return alert.description;
      } else {
        return `${words.slice(0, 4).join(' ')}...`;
      }
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
}