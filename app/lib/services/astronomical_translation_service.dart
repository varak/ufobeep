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

    if (altitude < 0) {
      return l10n.planetBelowHorizon(translatedName);
    } else if (altitude < 15) {
      return l10n.planetLowHorizon(translatedName, altitude.toStringAsFixed(0));
    } else if (altitude > 45 && isProminent) {
      return l10n.planetHighOverheadProminent(translatedName, altitude.toStringAsFixed(0));
    } else if (altitude > 45) {
      return l10n.planetHighOverhead(translatedName, altitude.toStringAsFixed(0));
    } else if (isProminent) {
      return l10n.planetMidSkyProminent(translatedName, altitude.toStringAsFixed(0));
    } else {
      return l10n.planetMidSky(translatedName, altitude.toStringAsFixed(0));
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

    if (magnitude != null && magnitude < 1.0) {
      return l10n.starVeryBright(translatedName, altitudeStr);
    } else if (altitude > 30) {
      return l10n.starProminent(translatedName, altitudeStr);
    } else {
      return l10n.starVisible(translatedName, altitudeStr);
    }
  }

  /// Generate satellite summary based on count and visibility
  static String translateSatelliteSummary(
    int totalCount,
    int visibleCount,
    bool couldExplainSighting,
    AppLocalizations l10n
  ) {
    if (visibleCount == 0) {
      return l10n.noSatellitesVisible;
    } else if (couldExplainSighting) {
      return l10n.satellitesVisibleMightExplain(visibleCount);
    } else {
      return l10n.satellitesVisibleUnlikelyExplain(visibleCount);
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
      return l10n.aircraftDetectedInRadius(aircraftCount, radius);
    }
  }

  /// Generate moon description based on phase and visibility
  static String translateMoonDescription(
    String phaseName,
    double illumination,
    double altitude,
    AppLocalizations l10n
  ) {
    final translatedPhase = _translateMoonPhase(phaseName, l10n);

    if (altitude < 0) {
      return l10n.moonBelowHorizon(translatedPhase);
    } else {
      return l10n.moonVisible(translatedPhase, illumination.toStringAsFixed(1));
    }
  }

  /// Translate moon phase names
  static String _translateMoonPhase(String phase, AppLocalizations l10n) {
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
}