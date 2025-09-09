export default function LanguagesPage() {
  const languages = [
    { code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸' },
    { code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸' },
    { code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪' },
    { code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷' },
    { code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹' },
    { code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺' },
    { code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵' },
    { code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳' },
    { code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹' },
    { code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦' },
    { code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷' },
    { code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷' },
    { code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳' },
    { code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱' },
    { code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿' },
    { code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱' },
    { code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪' },
    { code: 'da', name: 'Danish', nativeName: 'Dansk', flag: '🇩🇰' },
    { code: 'no', name: 'Norwegian', nativeName: 'Norsk', flag: '🇳🇴' },
    { code: 'fi', name: 'Finnish', nativeName: 'Suomi', flag: '🇫🇮' },
    { code: 'el', name: 'Greek', nativeName: 'Ελληνικά', flag: '🇬🇷' },
    { code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱' },
  ];

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-text-primary mb-4">
          🌐 UFOBeep Supports 22 Languages
        </h1>
        <p className="text-text-secondary">
          Choose your preferred language to view UFOBeep in your native language
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {languages.map((lang) => (
          <a
            key={lang.code}
            href={lang.code === 'en' ? '/beep' : `/${lang.code}/beep`}
            className="block p-4 border border-dark-border rounded-lg hover:bg-dark-surface-elevated transition-colors"
          >
            <div className="flex items-center gap-3">
              <span className="text-2xl">{lang.flag}</span>
              <div>
                <div className="font-medium text-text-primary">
                  {lang.nativeName}
                </div>
                <div className="text-sm text-text-secondary">
                  {lang.name}
                </div>
              </div>
            </div>
          </a>
        ))}
      </div>

      <div className="mt-8 p-6 border border-dark-border rounded-lg bg-dark-surface">
        <h2 className="text-lg font-semibold text-text-primary mb-4">
          How to Change Language
        </h2>
        <div className="space-y-3 text-sm text-text-secondary">
          <div>
            <strong className="text-text-primary">Method 1: Click above</strong> - 
            Click any language above to switch immediately
          </div>
          <div>
            <strong className="text-text-primary">Method 2: URL change</strong> - 
            Add language code to URL: <code className="bg-dark-background px-1 rounded">/es/beep</code> for Spanish
          </div>
          <div>
            <strong className="text-text-primary">Method 3: Browser setting</strong> - 
            UFOBeep automatically detects your browser&apos;s language preference
          </div>
        </div>
      </div>

      <div className="mt-6 text-center">
        <a 
          href="/beep"
          className="inline-block px-6 py-2 bg-brand-primary text-white rounded-lg hover:bg-brand-primary/90 transition-colors"
        >
          Back to Alerts
        </a>
      </div>
    </div>
  );
}