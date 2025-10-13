import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n/app_localizations.dart';

/// Service for managing app localization and language preferences
class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'es';
  
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = const Locale(_defaultLanguage);
  SharedPreferences? _prefs;

  /// Currently selected locale
  Locale get currentLocale => _currentLocale;

  /// Supported locales for the app
  static const List<Locale> supportedLocales = [
    Locale('es'), // Spanish (default)
    Locale('en'), // English
    Locale('pt'), // Portuguese
  ];

  /// Language names for display in UI
  static const Map<String, String> languageNames = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
  };

  /// Initialize the localization service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLanguage();
  }

  /// Load the saved language preference
  Future<void> _loadSavedLanguage() async {
    final savedLanguage = _prefs?.getString(_languageKey);
    
    if (savedLanguage != null && _isLanguageSupported(savedLanguage)) {
      _currentLocale = Locale(savedLanguage);
    } else {
      // Use system locale if supported, otherwise default to Spanish
      final systemLocale = PlatformDispatcher.instance.locale;
      if (_isLanguageSupported(systemLocale.languageCode)) {
        _currentLocale = Locale(systemLocale.languageCode);
      } else {
        _currentLocale = const Locale(_defaultLanguage);
      }
    }
    
    notifyListeners();
  }

  /// Check if a language code is supported
  bool _isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    if (!_isLanguageSupported(languageCode)) {
      throw ArgumentError('Language $languageCode is not supported');
    }

    _currentLocale = Locale(languageCode);
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners();
  }

  /// Get the current language code
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Get the display name for the current language
  String get currentLanguageName => languageNames[currentLanguageCode] ?? 'Unknown';

  /// Get the display name for a specific language code
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  /// Check if the current language is RTL (Right-to-Left)
  bool get isRTL {
    // None of our supported languages are RTL, but this can be extended
    return false;
  }

  /// Get localized strings for the current context
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  /// Get localized strings without context (useful for services)
  static AppLocalizations? get current {
    // This will be available after the app is initialized
    return AppLocalizations.delegate.isSupported(LocalizationService().currentLocale)
        ? lookupAppLocalizations(LocalizationService().currentLocale)
        : null;
  }

  /// Reset to default language
  Future<void> resetToDefault() async {
    await changeLanguage(_defaultLanguage);
  }

  /// Reset to system language if supported
  Future<void> resetToSystem() async {
    final systemLocale = PlatformDispatcher.instance.locale;
    if (_isLanguageSupported(systemLocale.languageCode)) {
      await changeLanguage(systemLocale.languageCode);
    } else {
      await resetToDefault();
    }
  }

  /// Get all available languages with their display names
  Map<String, String> get availableLanguages {
    return Map.fromEntries(
      supportedLocales.map(
        (locale) => MapEntry(
          locale.languageCode,
          getLanguageName(locale.languageCode),
        ),
      ),
    );
  }

  /// Check if a specific language is currently selected
  bool isLanguageSelected(String languageCode) {
    return currentLanguageCode == languageCode;
  }

  /// Get the locale resolution callback for MaterialApp
  static Locale? localeResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    if (locales == null || locales.isEmpty) {
      return const Locale(_defaultLanguage);
    }

    // Try to find exact match
    for (final locale in locales) {
      if (supportedLocales.any((supported) => 
          supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode)) {
        return locale;
      }
    }

    // Try to find language match
    for (final locale in locales) {
      if (supportedLocales.any((supported) => 
          supported.languageCode == locale.languageCode)) {
        return Locale(locale.languageCode);
      }
    }

    // Return default
    return const Locale(_defaultLanguage);
  }
}

/// Extension to make localization easier to use
extension LocalizationExtension on BuildContext {
  /// Get localized strings easily
  AppLocalizations get l10n => LocalizationService.of(this);
  
  /// Get current locale
  Locale get locale => Localizations.localeOf(this);
  
  /// Check if current locale is RTL
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
}