// BuildContext extensions: shortcut accessors for theme + localization.

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isTablet => mediaQuery.size.shortestSide >= 600;
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  NavigatorState get navigator => Navigator.of(this);
}
