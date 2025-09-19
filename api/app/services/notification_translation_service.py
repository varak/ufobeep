"""
Notification translation service for UFOBeep
Provides fast lookups for pre-translated push notification strings
"""

import json
import logging
from pathlib import Path
from typing import Dict, Optional

logger = logging.getLogger(__name__)


class NotificationTranslationService:
    """Fast translation service for push notifications using pre-generated translations"""

    def __init__(self):
        self.translations: Dict[str, Dict[str, str]] = {}
        self.default_language = "en"
        self._load_translations()

    def _load_translations(self):
        """Load pre-generated translations from JSON file"""
        try:
            # Look for notification_translations.json in the API root
            translations_path = Path(__file__).parent.parent.parent / "notification_translations.json"

            if not translations_path.exists():
                logger.warning(f"Notification translations file not found at {translations_path}")
                logger.warning("Push notifications will use English fallbacks")
                return

            with open(translations_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.translations = data.get('translations', {})

            logger.info(f"✅ Loaded push notification translations for {len(self.translations)} languages")

        except Exception as e:
            logger.error(f"Failed to load notification translations: {e}")
            logger.warning("Push notifications will use English fallbacks")

    def get_translation(self, language_code: str, key: str, fallback: str = None) -> str:
        """
        Get translated notification string for user's language

        Args:
            language_code: User's preferred language (e.g., 'es', 'de', 'fr')
            key: Translation key (e.g., 'pushNotificationUfoAlert')
            fallback: Fallback text if translation not found

        Returns:
            Translated string or fallback
        """

        # Get user's language translations
        lang_translations = self.translations.get(language_code)

        if lang_translations and key in lang_translations:
            return lang_translations[key]

        # Fallback to English
        en_translations = self.translations.get(self.default_language, {})
        if key in en_translations:
            return en_translations[key]

        # Final fallback to provided string or generic message
        return fallback or f"[TRANSLATION MISSING: {key}]"

    def format_translation(self, language_code: str, key: str, **kwargs) -> str:
        """
        Get translated string and format with parameters

        Args:
            language_code: User's preferred language
            key: Translation key
            **kwargs: Format parameters (e.g., username="Alice", beepTitle="UFO Sighting")

        Returns:
            Formatted translated string
        """

        template = self.get_translation(language_code, key)

        try:
            return template.format(**kwargs)
        except KeyError as e:
            logger.warning(f"Missing format parameter {e} for key '{key}' in language '{language_code}'")
            return template
        except Exception as e:
            logger.error(f"Failed to format translation '{key}' for language '{language_code}': {e}")
            return template

    def get_available_languages(self) -> list:
        """Get list of available language codes"""
        return list(self.translations.keys())

    def is_language_supported(self, language_code: str) -> bool:
        """Check if a language is supported"""
        return language_code in self.translations


# Global service instance
notification_translation_service = NotificationTranslationService()


# Convenience functions for common notification types
def get_ufo_alert_title(language_code: str) -> str:
    """Get 'UFO Alert' in user's language"""
    return notification_translation_service.get_translation(
        language_code, 'pushNotificationUfoAlert', 'UFO Alert'
    )

def get_comment_notification_title(language_code: str, username: str, beep_title: str = None) -> str:
    """Get comment notification title in user's language"""
    if beep_title:
        return notification_translation_service.format_translation(
            language_code, 'pushNotificationCommentedOn',
            username=username, beepTitle=beep_title
        )
    else:
        return notification_translation_service.format_translation(
            language_code, 'pushNotificationCommented',
            username=username
        )

def get_sighting_notification_body(language_code: str) -> str:
    """Get sighting notification body in user's language"""
    return notification_translation_service.get_translation(
        language_code, 'pushNotificationInYourArea', 'in your area. Tap to view details.'
    )