import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Service for translating astronomical data with smart templates
/// Provides natural language descriptions for celestial objects, satellites, and aircraft
/// Based on data conditions (altitude, brightness, visibility, etc.)
class AstronomicalTranslationService {

  /// Translate planet names to localized versions
  static String translatePlanetName(String planetName, AppLocalizations l10n) {
    switch (planetName.toLowerCase()) {
      case 'venus':
        return l10n.planetVenus;
      case 'jupiter':
        return l10n.planetJupiter;
      case 'saturn':
        return l10n.planetSaturn;
      case 'mars':
        return l10n.planetMars;
      case 'mercury':
        return l10n.planetMercury;
      case 'uranus':
        return l10n.planetUranus;
      case 'neptune':
        return l10n.planetNeptune;
      default:
        return planetName; // Keep unknown planets as-is
    }
  }

  /// Translate star names to localized versions
  static String translateStarName(String starName, AppLocalizations l10n) {
    switch (starName.toLowerCase()) {
      case 'sirius':
        return l10n.starSirius;
      case 'canopus':
        return l10n.starCanopus;
      case 'arcturus':
        return l10n.starArcturus;
      case 'vega':
        return l10n.starVega;
      case 'capella':
        return l10n.starCapella;
      case 'rigel':
        return l10n.starRigel;
      case 'procyon':
        return l10n.starProcyon;
      case 'betelgeuse':
        return l10n.starBetelgeuse;
      default:
        return starName; // Keep unknown stars as-is
    }
  }

  /// Generate smart description for planet based on altitude and prominence
  static String translatePlanetDescription(
    String planetName,
    double altitude,
    bool isProminent,
    AppLocalizations l10n
  ) {
    final translatedName = translatePlanetName(planetName, l10n);

    if (altitude < 15) {
      return l10n.celestialPlanetLow(translatedName, altitude.toStringAsFixed(0));
    } else if (altitude > 45) {
      return l10n.celestialPlanetHigh(translatedName, altitude.toStringAsFixed(0));
    } else {
      return l10n.celestialPlanetMedium(translatedName, altitude.toStringAsFixed(0));
    }
  }

  /// Generate smart description for star based on altitude and brightness
  static String translateStarDescription(
    String starName,
    double altitude,
    double? magnitude,
    AppLocalizations l10n
  ) {
    final translatedName = translateStarName(starName, l10n);
    final altitudeStr = altitude.toStringAsFixed(0);

    return l10n.celestialStarSingle(translatedName, altitudeStr);
  }

  /// Generate satellite summary based on count and visibility
  static String translateSatelliteSummary(
    int totalCount,
    int visibleCount,
    bool couldExplainSighting,
    AppLocalizations l10n
  ) {
    if (totalCount == 0) {
      return l10n.noSatellitesVisibleAtTime;
    } else if (couldExplainSighting) {
      return l10n.satellitesVisibleMightExplain(totalCount);
    } else {
      return l10n.dimSatellitesUnlikely(totalCount);
    }
  }

  /// Generate aircraft summary based on detection results
  static String translateAircraftSummary(
    int aircraftCount,
    double? radiusKm,
    AppLocalizations l10n
  ) {
    if (aircraftCount == 0) {
      return l10n.noAircraftDetected;
    } else {
      final radius = radiusKm?.toStringAsFixed(0) ?? '50';
      return l10n.aircraftDetectedCurrentPositions(aircraftCount, radius);
    }
  }

  /// Generate moon description based on phase and visibility
  static String translateMoonDescription(
    String phaseName,
    double illumination,
    double altitude,
    AppLocalizations l10n
  ) {
    final translatedPhase = translateMoonPhase(phaseName, l10n);

    if (altitude < 0) {
      return l10n.celestialMoonHidden(translatedPhase);
    } else {
      return l10n.celestialMoonModerate(translatedPhase);
    }
  }

  /// Translate moon phase names
  static String translateMoonPhase(String phase, AppLocalizations l10n) {
    switch (phase.toLowerCase()) {
      case 'new moon':
        return l10n.moonPhaseNew;
      case 'waxing crescent':
        return l10n.moonPhaseWaxingCrescent;
      case 'first quarter':
        return l10n.moonPhaseFirstQuarter;
      case 'waxing gibbous':
        return l10n.moonPhaseWaxingGibbous;
      case 'full moon':
        return l10n.moonPhaseFull;
      case 'waning gibbous':
        return l10n.moonPhaseWaningGibbous;
      case 'third quarter':
        return l10n.moonPhaseThirdQuarter;
      case 'waning crescent':
        return l10n.moonPhaseWaningCrescent;
      default:
        return phase;
    }
  }

  /// Translate weather conditions from API to localized versions
  static String translateWeatherCondition(String condition, AppLocalizations l10n) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return l10n.weatherClear;
      case 'clouds':
        return l10n.clouds ?? condition;
      case 'rain':
        return l10n.rain ?? condition;
      case 'snow':
        return l10n.snow ?? condition;
      case 'thunderstorm':
        return l10n.thunderstorm ?? condition;
      case 'drizzle':
        return l10n.drizzle ?? condition;
      case 'mist':
      case 'fog':
        return l10n.fog ?? condition;
      default:
        return condition;
    }
  }

  /// Translate weather descriptions from API to localized versions
  static String translateWeatherDescription(String description, AppLocalizations l10n) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return l10n.weatherClearSky;
      case 'few clouds':
        return l10n.fewClouds ?? description;
      case 'scattered clouds':
        return l10n.scatteredClouds ?? description;
      case 'broken clouds':
        return l10n.brokenClouds ?? description;
      case 'overcast clouds':
        return l10n.overcastClouds ?? description;
      case 'light rain':
        return l10n.lightRain ?? description;
      case 'moderate rain':
        return l10n.moderateRain ?? description;
      case 'heavy rain':
        return l10n.heavyRain ?? description;
      default:
        return description;
    }
  }
}