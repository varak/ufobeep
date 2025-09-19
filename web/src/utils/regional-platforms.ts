// Regional social media platforms configuration
// Supports URL-based sharing for platforms across different languages/regions

export interface PlatformConfig {
  key: string
  name: string
  icon: string
  url: string
  global?: boolean // Available to all languages
}

// Global platforms (shown to all users regardless of language)
export const globalPlatforms: PlatformConfig[] = [
  {
    key: 'twitter',
    name: 'Twitter/X',
    icon: '🐦',
    url: 'https://twitter.com/intent/tweet?text={text}&url={url}',
    global: true
  },
  {
    key: 'facebook',
    name: 'Facebook',
    icon: '📘',
    url: 'https://www.facebook.com/sharer/sharer.php?u={url}&quote={text}',
    global: true
  },
  {
    key: 'reddit',
    name: 'Reddit',
    icon: '🔴',
    url: 'https://reddit.com/submit?url={url}&title={text}',
    global: true
  },
  {
    key: 'telegram',
    name: 'Telegram',
    icon: '✈️',
    url: 'https://t.me/share/url?url={url}&text={text}',
    global: true
  },
  {
    key: 'whatsapp',
    name: 'WhatsApp',
    icon: '💚',
    url: 'https://wa.me/?text={text} {url}',
    global: true
  },
  {
    key: 'instagram',
    name: 'Instagram',
    icon: '📷',
    url: 'https://www.instagram.com/', // Note: Instagram doesn't support direct URL sharing
    global: true
  },
  {
    key: 'tiktok',
    name: 'TikTok',
    icon: '🎵',
    url: 'https://www.tiktok.com/', // Note: TikTok doesn't support direct URL sharing
    global: true
  }
]

// Regional platforms (shown based on user's language/locale)
export const regionalPlatforms: Record<string, PlatformConfig[]> = {
  'ru': [
    {
      key: 'vkontakte',
      name: 'VKontakte',
      icon: '🔵',
      url: 'http://vk.com/share.php?url={url}&title={text}'
    }
  ],
  'zh': [
    {
      key: 'weibo',
      name: 'Weibo',
      icon: '🇨🇳',
      url: 'http://service.weibo.com/share/share.php?url={url}&title={text}'
    }
  ],
  'ja': [
    {
      key: 'line',
      name: 'LINE',
      icon: '📱',
      url: 'https://lineit.line.me/share/ui?url={url}&text={text}'
    }
  ],
  'de': [
    {
      key: 'xing',
      name: 'XING',
      icon: '🇩🇪',
      url: 'https://www.xing.com/app/user?op=share&url={url}&title={text}'
    }
  ]
}

// Get available platforms for a specific locale
export function getPlatformsForLocale(locale: string): PlatformConfig[] {
  const baseLanguage = locale.split('-')[0] // 'en-US' -> 'en'
  const regional = regionalPlatforms[baseLanguage] || []

  return [
    ...globalPlatforms.filter(p => p.key !== 'instagram' && p.key !== 'tiktok'), // Remove non-URL platforms
    ...regional
  ]
}

// Generate share URL for a platform
export function generateShareUrl(platform: PlatformConfig, text: string, url: string): string {
  return platform.url
    .replace('{text}', encodeURIComponent(text))
    .replace('{url}', encodeURIComponent(url))
    .replace('{title}', encodeURIComponent(text))
}