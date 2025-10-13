import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logger.dart';

class FontHelper {
  static const String _tag = 'FontHelper';
  
  /// Safe wrapper for GoogleFonts that handles platform exceptions
  static TextStyle safeGoogleFont({
    String fontFamily = 'Roboto',
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    try {
      // Try to load the requested Google Font
      switch (fontFamily.toLowerCase()) {
        case 'roboto':
          return GoogleFonts.roboto(
            textStyle: textStyle,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            textBaseline: textBaseline,
            height: height,
            locale: locale,
            foreground: foreground,
            background: background,
            shadows: shadows,
            fontFeatures: fontFeatures,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
          );
        case 'opensans':
        case 'open sans':
          return GoogleFonts.openSans(
            textStyle: textStyle,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            textBaseline: textBaseline,
            height: height,
            locale: locale,
            foreground: foreground,
            background: background,
            shadows: shadows,
            fontFeatures: fontFeatures,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
          );
        case 'lato':
          return GoogleFonts.lato(
            textStyle: textStyle,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            textBaseline: textBaseline,
            height: height,
            locale: locale,
            foreground: foreground,
            background: background,
            shadows: shadows,
            fontFeatures: fontFeatures,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
          );
        default:
          // Default to Roboto for unsupported fonts
          return GoogleFonts.roboto(
            textStyle: textStyle,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            textBaseline: textBaseline,
            height: height,
            locale: locale,
            foreground: foreground,
            background: background,
            shadows: shadows,
            fontFeatures: fontFeatures,
            decoration: decoration,
            decorationColor: decorationColor,
            decorationStyle: decorationStyle,
            decorationThickness: decorationThickness,
          );
      }
    } on PlatformException catch (e) {
      Logger.instance.warning(
        'Failed to load Google Font $fontFamily, falling back to system font',
        tag: _tag,
        data: {'error': e.toString()},
      );
      
      // Fallback to system font
      return _getSystemFontStyle(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    } catch (e) {
      Logger.instance.error(
        'Unexpected error loading Google Font $fontFamily',
        tag: _tag,
        data: {'error': e.toString()},
      );
      
      // Fallback to system font
      return _getSystemFontStyle(
        textStyle: textStyle,
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }
  }

  /// Returns a fallback TextStyle using system fonts
  static TextStyle _getSystemFontStyle({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    return TextStyle(
      inherit: textStyle?.inherit ?? true,
      color: color ?? textStyle?.color,
      backgroundColor: backgroundColor ?? textStyle?.backgroundColor,
      fontSize: fontSize ?? textStyle?.fontSize,
      fontWeight: fontWeight ?? textStyle?.fontWeight,
      fontStyle: fontStyle ?? textStyle?.fontStyle,
      letterSpacing: letterSpacing ?? textStyle?.letterSpacing,
      wordSpacing: wordSpacing ?? textStyle?.wordSpacing,
      textBaseline: textBaseline ?? textStyle?.textBaseline,
      height: height ?? textStyle?.height,
      locale: locale ?? textStyle?.locale,
      foreground: foreground ?? textStyle?.foreground,
      background: background ?? textStyle?.background,
      shadows: shadows ?? textStyle?.shadows,
      fontFeatures: fontFeatures ?? textStyle?.fontFeatures,
      decoration: decoration ?? textStyle?.decoration,
      decorationColor: decorationColor ?? textStyle?.decorationColor,
      decorationStyle: decorationStyle ?? textStyle?.decorationStyle,
      decorationThickness: decorationThickness ?? textStyle?.decorationThickness,
      fontFamily: 'SF Pro Text', // Default iOS font
    );
  }

  /// Safely initializes fonts
  static Future<void> initializeFonts() async {
    try {
      Logger.instance.info(
        'Initializing fonts...',
        tag: _tag,
      );
      
      // Pre-load common fonts to avoid runtime errors
      await Future.wait([
        _preloadFont('Roboto'),
        _preloadFont('Open Sans'),
        _preloadFont('Lato'),
      ]);
      
      Logger.instance.info(
        'Fonts initialized successfully',
        tag: _tag,
      );
    } catch (e) {
      Logger.instance.warning(
        'Error initializing fonts',
        tag: _tag,
        data: {'error': e.toString()},
      );
    }
  }

  /// Pre-loads a specific font
  static Future<void> _preloadFont(String fontFamily) async {
    try {
      final textStyle = safeGoogleFont(fontFamily: fontFamily, fontSize: 14);
      Logger.instance.debug(
        'Font $fontFamily pre-loaded successfully',
        tag: _tag,
      );
    } catch (e) {
      Logger.instance.warning(
        'Error pre-loading font $fontFamily',
        tag: _tag,
        data: {'error': e.toString()},
      );
    }
  }
}