import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff31628d),
      surfaceTint: Color(0xff31628d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffcfe5ff),
      onPrimaryContainer: Color(0xff124a73),
      secondary: Color(0xff526070),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd5e4f7),
      onSecondaryContainer: Color(0xff3a4857),
      tertiary: Color(0xff695779),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff0dbff),
      onTertiaryContainer: Color(0xff504060),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff181c20),
      onSurfaceVariant: Color(0xff42474e),
      outline: Color(0xff72777f),
      outlineVariant: Color(0xffc2c7cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff9dcbfb),
      primaryFixed: Color(0xffcfe5ff),
      onPrimaryFixed: Color(0xff001d34),
      primaryFixedDim: Color(0xff9dcbfb),
      onPrimaryFixedVariant: Color(0xff124a73),
      secondaryFixed: Color(0xffd5e4f7),
      onSecondaryFixed: Color(0xff0e1d2a),
      secondaryFixedDim: Color(0xffb9c8da),
      onSecondaryFixedVariant: Color(0xff3a4857),
      tertiaryFixed: Color(0xfff0dbff),
      onTertiaryFixed: Color(0xff231532),
      tertiaryFixedDim: Color(0xffd4bee6),
      onTertiaryFixedVariant: Color(0xff504060),
      surfaceDim: Color(0xffd8dae0),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3f9),
      surfaceContainer: Color(0xffeceef4),
      surfaceContainerHigh: Color(0xffe6e8ee),
      surfaceContainerHighest: Color(0xffe0e2e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00395e),
      surfaceTint: Color(0xff31628d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff41719c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2a3746),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff606e7f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3f2f4f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff786689),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff0e1115),
      onSurfaceVariant: Color(0xff32373d),
      outline: Color(0xff4e535a),
      outlineVariant: Color(0xff686d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff9dcbfb),
      primaryFixed: Color(0xff41719c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff265882),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff606e7f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff485666),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff786689),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5f4e6f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc4c6cc),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3f9),
      surfaceContainer: Color(0xffe6e8ee),
      surfaceContainerHigh: Color(0xffdbdde2),
      surfaceContainerHighest: Color(0xffcfd1d7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002e4e),
      surfaceTint: Color(0xff31628d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff164c76),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff202d3c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3d4a5a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff352544),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff534263),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff272d33),
      outlineVariant: Color(0xff454a50),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff9dcbfb),
      primaryFixed: Color(0xff164c76),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003558),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3d4a5a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff263442),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff534263),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3c2c4b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb6b9be),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff1f6),
      surfaceContainer: Color(0xffe0e2e8),
      surfaceContainerHigh: Color(0xffd2d4da),
      surfaceContainerHighest: Color(0xffc4c6cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9dcbfb),
      surfaceTint: Color(0xff9dcbfb),
      onPrimary: Color(0xff003355),
      primaryContainer: Color(0xff124a73),
      onPrimaryContainer: Color(0xffcfe5ff),
      secondary: Color(0xffb9c8da),
      onSecondary: Color(0xff243240),
      secondaryContainer: Color(0xff3a4857),
      onSecondaryContainer: Color(0xffd5e4f7),
      tertiary: Color(0xffd4bee6),
      onTertiary: Color(0xff392a49),
      tertiaryContainer: Color(0xff504060),
      onTertiaryContainer: Color(0xfff0dbff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101418),
      onSurface: Color(0xffe0e2e8),
      onSurfaceVariant: Color(0xffc2c7cf),
      outline: Color(0xff8c9199),
      outlineVariant: Color(0xff42474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2e8),
      inversePrimary: Color(0xff31628d),
      primaryFixed: Color(0xffcfe5ff),
      onPrimaryFixed: Color(0xff001d34),
      primaryFixedDim: Color(0xff9dcbfb),
      onPrimaryFixedVariant: Color(0xff124a73),
      secondaryFixed: Color(0xffd5e4f7),
      onSecondaryFixed: Color(0xff0e1d2a),
      secondaryFixedDim: Color(0xffb9c8da),
      onSecondaryFixedVariant: Color(0xff3a4857),
      tertiaryFixed: Color(0xfff0dbff),
      onTertiaryFixed: Color(0xff231532),
      tertiaryFixedDim: Color(0xffd4bee6),
      onTertiaryFixedVariant: Color(0xff504060),
      surfaceDim: Color(0xff101418),
      surfaceBright: Color(0xff36393e),
      surfaceContainerLowest: Color(0xff0b0e12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff272a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc4dfff),
      surfaceTint: Color(0xff9dcbfb),
      onPrimary: Color(0xff002844),
      primaryContainer: Color(0xff6795c2),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffcfdef1),
      onSecondary: Color(0xff192735),
      secondaryContainer: Color(0xff8492a3),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffebd4fc),
      onTertiary: Color(0xff2e1f3d),
      tertiaryContainer: Color(0xff9d89ae),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101418),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd8dce5),
      outline: Color(0xffadb2ba),
      outlineVariant: Color(0xff8c9198),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2e8),
      inversePrimary: Color(0xff144b75),
      primaryFixed: Color(0xffcfe5ff),
      onPrimaryFixed: Color(0xff001223),
      primaryFixedDim: Color(0xff9dcbfb),
      onPrimaryFixedVariant: Color(0xff00395e),
      secondaryFixed: Color(0xffd5e4f7),
      onSecondaryFixed: Color(0xff04121f),
      secondaryFixedDim: Color(0xffb9c8da),
      onSecondaryFixedVariant: Color(0xff2a3746),
      tertiaryFixed: Color(0xfff0dbff),
      onTertiaryFixed: Color(0xff190a27),
      tertiaryFixedDim: Color(0xffd4bee6),
      onTertiaryFixedVariant: Color(0xff3f2f4f),
      surfaceDim: Color(0xff101418),
      surfaceBright: Color(0xff414549),
      surfaceContainerLowest: Color(0xff05080b),
      surfaceContainerLow: Color(0xff1a1e22),
      surfaceContainer: Color(0xff25282c),
      surfaceContainerHigh: Color(0xff2f3337),
      surfaceContainerHighest: Color(0xff3b3e43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe7f1ff),
      surfaceTint: Color(0xff9dcbfb),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff99c7f7),
      onPrimaryContainer: Color(0xff000c1a),
      secondary: Color(0xffe7f1ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffb6c4d6),
      onSecondaryContainer: Color(0xff010c19),
      tertiary: Color(0xfff9ebff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffd0bae2),
      onTertiaryContainer: Color(0xff120421),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff101418),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffecf0f9),
      outlineVariant: Color(0xffbec3cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e2e8),
      inversePrimary: Color(0xff144b75),
      primaryFixed: Color(0xffcfe5ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff9dcbfb),
      onPrimaryFixedVariant: Color(0xff001223),
      secondaryFixed: Color(0xffd5e4f7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb9c8da),
      onSecondaryFixedVariant: Color(0xff04121f),
      tertiaryFixed: Color(0xfff0dbff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd4bee6),
      onTertiaryFixedVariant: Color(0xff190a27),
      surfaceDim: Color(0xff101418),
      surfaceBright: Color(0xff4d5055),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1d2024),
      surfaceContainer: Color(0xff2d3135),
      surfaceContainerHigh: Color(0xff383c40),
      surfaceContainerHighest: Color(0xff44474c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  // ألوان التحذير
  static const Color warningLight = Color(0xFFDDA12A);
  static const Color onWarningLight = Color(0xffffffff);
  static const Color warningDark = Color(0xfff0bf6d);
  static const Color onWarningDark = Color(0xff422c00);

  // ألوان النجاح
  static const Color successLight = Color(0xFF2EB837);
  static const Color onSuccessLight = Color(0xffffffff);
  static const Color successDark = Color(0xff9ed49c);
  static const Color onSuccessDark = Color(0xff053911);

  // ألوان المعلومات
  static const Color infoLight = Color(0xFF29A0B3);
  static const Color onInfoLight = Color(0xffffffff);
  static const Color infoDark = Color(0xff83d2e4);
  static const Color onInfoDark = Color(0xff00363f);

  /// دوال مختصرة لجلب اللون المناسب حسب الثيم
  static Color warning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? warningDark
          : warningLight;
  static Color onWarning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? onWarningDark
          : onWarningLight;

  static Color success(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? successDark
          : successLight;
  static Color onSuccess(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? onSuccessDark
          : onSuccessLight;

  static Color info(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? infoDark : infoLight;
  static Color onInfo(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? onInfoDark
          : onInfoLight;
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
