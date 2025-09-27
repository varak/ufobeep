import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/astronomical_translation_service.dart';

/// Helper methods for generating multilingual celestial descriptions
/// Used by CelestialCardFromJson to replace English API explanations
class CelestialDescriptionHelpers {

  static String generateSunDescription(Map<String, dynamic>? sunData, BuildContext context) {
    if (sunData == null) {
      print('DEBUG: sunData is null');
      return AppLocalizations.of(context)!.celestialSunDark;
    }

    print('DEBUG: sunData keys: ${sunData.keys.toList()}');
    print('DEBUG: sunData: $sunData');

    final category = sunData['visibility_category'] as String? ?? 'dark';
    print('DEBUG: visibility_category: $category');

    switch (category) {
      case 'daylight': return AppLocalizations.of(context)!.celestialSunDaylight;
      case 'twilight': return AppLocalizations.of(context)!.celestialSunTwilight;
      default: return AppLocalizations.of(context)!.celestialSunDark;
    }
  }

  static String generateMoonDescription(Map<String, dynamic>? moonData, BuildContext context) {
    if (moonData == null) return AppLocalizations.of(context)!.celestialMoonHidden('New Moon');
    final phaseName = moonData['phase_name'] as String? ?? 'New Moon';
    final category = moonData['brightness_category'] as String? ?? 'thin';
    final translatedPhase = AstronomicalTranslationService.translateMoonPhase(phaseName, AppLocalizations.of(context)!);

    switch (category) {
      case 'bright': return AppLocalizations.of(context)!.celestialMoonBright(translatedPhase);
      case 'moderate': return AppLocalizations.of(context)!.celestialMoonModerate(translatedPhase);
      case 'thin': return AppLocalizations.of(context)!.celestialMoonThin(translatedPhase);
      default: return AppLocalizations.of(context)!.celestialMoonHidden(translatedPhase);
    }
  }

  static String generatePlanetsDescription(List<dynamic> planets, BuildContext context) {
    if (planets.isEmpty) return AppLocalizations.of(context)!.celestialNoPlanets;

    final descriptions = planets.map((planet) {
      final name = planet['name'] as String? ?? 'Unknown';
      final altitude = planet['altitude'] as double? ?? 0.0;
      final category = planet['visibility_category'] as String? ?? 'low';
      final translatedName = AstronomicalTranslationService.translatePlanetName(name, AppLocalizations.of(context)!);

      switch (category) {
        case 'high': return AppLocalizations.of(context)!.celestialPlanetHigh(translatedName, altitude.toStringAsFixed(0));
        case 'medium': return AppLocalizations.of(context)!.celestialPlanetMedium(translatedName, altitude.toStringAsFixed(0));
        default: return AppLocalizations.of(context)!.celestialPlanetLow(translatedName, altitude.toStringAsFixed(0));
      }
    }).toList();

    return descriptions.join('; ');
  }

  static String generateStarsDescription(List<dynamic> stars, BuildContext context) {
    if (stars.isEmpty) return AppLocalizations.of(context)!.celestialNoStars;

    if (stars.length == 1) {
      final star = stars.first;
      final name = star['name'] as String? ?? 'Unknown';
      final altitude = star['altitude'] as double? ?? 0.0;
      final translatedName = AstronomicalTranslationService.translateStarName(name, AppLocalizations.of(context)!);
      return AppLocalizations.of(context)!.celestialStarSingle(translatedName, altitude.toStringAsFixed(0));
    } else {
      final names = stars.map((s) => AstronomicalTranslationService.translateStarName(
        s['name'] as String? ?? 'Unknown',
        AppLocalizations.of(context)!
      )).join(', ');
      return AppLocalizations.of(context)!.celestialStarsMultiple(stars.length, names);
    }
  }
}