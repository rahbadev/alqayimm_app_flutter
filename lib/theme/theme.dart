import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff435e91),
      surfaceTint: Color(0xff435e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd8e2ff),
      onPrimaryContainer: Color(0xff2a4678),
      secondary: Color(0xff2b638b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcce5ff),
      onSecondaryContainer: Color(0xff044b71),
      tertiary: Color(0xff7e570f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffddb0),
      onTertiaryContainer: Color(0xff614000),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff44474f),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc7ff),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a41),
      primaryFixedDim: Color(0xffadc7ff),
      onPrimaryFixedVariant: Color(0xff2a4678),
      secondaryFixed: Color(0xffcce5ff),
      onSecondaryFixed: Color(0xff001e31),
      secondaryFixedDim: Color(0xff98ccf9),
      onSecondaryFixedVariant: Color(0xff044b71),
      tertiaryFixed: Color(0xffffddb0),
      onTertiaryFixed: Color(0xff281800),
      tertiaryFixedDim: Color(0xfff2be6e),
      onTertiaryFixedVariant: Color(0xff614000),
      surfaceDim: Color(0xffd9d9e0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe8e7ee),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff173566),
      surfaceTint: Color(0xff435e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff526da1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003959),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff3c729a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4b3100),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8f651e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff33363e),
      outline: Color(0xff50525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc7ff),
      primaryFixed: Color(0xff526da1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff395487),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff3c729a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1e5980),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8f651e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff734d03),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c6cd),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f3fa),
      surfaceContainer: Color(0xffe8e7ee),
      surfaceContainerHigh: Color(0xffdcdce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff092b5b),
      surfaceTint: Color(0xff435e91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2d487a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff002f4a),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff0a4d74),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3e2800),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff644200),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffadc7ff),
      primaryFixed: Color(0xff2d487a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff133162),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff0a4d74),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003654),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff644200),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff472e00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd4d4db),
      surfaceContainerHighest: Color(0xffc6c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffadc7ff),
      surfaceTint: Color(0xffadc7ff),
      onPrimary: Color(0xff0f2f60),
      primaryContainer: Color(0xff2a4678),
      onPrimaryContainer: Color(0xffd8e2ff),
      secondary: Color(0xff98ccf9),
      onSecondary: Color(0xff003350),
      secondaryContainer: Color(0xff044b71),
      onSecondaryContainer: Color(0xffcce5ff),
      tertiary: Color(0xfff2be6e),
      onTertiary: Color(0xff442c00),
      tertiaryContainer: Color(0xff614000),
      onTertiaryContainer: Color(0xffffddb0),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc4c6d0),
      outline: Color(0xff8e9099),
      outlineVariant: Color(0xff44474f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff435e91),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff001a41),
      primaryFixedDim: Color(0xffadc7ff),
      onPrimaryFixedVariant: Color(0xff2a4678),
      secondaryFixed: Color(0xffcce5ff),
      onSecondaryFixed: Color(0xff001e31),
      secondaryFixedDim: Color(0xff98ccf9),
      onSecondaryFixedVariant: Color(0xff044b71),
      tertiaryFixed: Color(0xffffddb0),
      onTertiaryFixed: Color(0xff281800),
      tertiaryFixedDim: Color(0xfff2be6e),
      onTertiaryFixedVariant: Color(0xff614000),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1e1f25),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33353a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcedcff),
      surfaceTint: Color(0xffadc7ff),
      onPrimary: Color(0xff002454),
      primaryContainer: Color(0xff7691c7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc0e0ff),
      onSecondary: Color(0xff002840),
      secondaryContainer: Color(0xff6296c0),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd69c),
      onTertiary: Color(0xff362200),
      tertiaryContainer: Color(0xffb7883e),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce6),
      outline: Color(0xffb0b1bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff2c4779),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff00102d),
      primaryFixedDim: Color(0xffadc7ff),
      onPrimaryFixedVariant: Color(0xff173566),
      secondaryFixed: Color(0xffcce5ff),
      onSecondaryFixed: Color(0xff001321),
      secondaryFixedDim: Color(0xff98ccf9),
      onSecondaryFixedVariant: Color(0xff003959),
      tertiaryFixed: Color(0xffffddb0),
      onTertiaryFixed: Color(0xff1b0f00),
      tertiaryFixedDim: Color(0xfff2be6e),
      onTertiaryFixedVariant: Color(0xff4b3100),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1d22),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffecefff),
      surfaceTint: Color(0xffadc7ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffa8c3fc),
      onPrimaryContainer: Color(0xff000a22),
      secondary: Color(0xffe5f1ff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff94c8f5),
      onSecondaryContainer: Color(0xff000c18),
      tertiary: Color(0xffffedd9),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffeeba6a),
      onTertiaryContainer: Color(0xff130900),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff111318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeeeff9),
      outlineVariant: Color(0xffc0c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff2c4779),
      primaryFixed: Color(0xffd8e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffadc7ff),
      onPrimaryFixedVariant: Color(0xff00102d),
      secondaryFixed: Color(0xffcce5ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff98ccf9),
      onSecondaryFixedVariant: Color(0xff001321),
      tertiaryFixed: Color(0xffffddb0),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff2be6e),
      onTertiaryFixedVariant: Color(0xff1b0f00),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff4e5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f25),
      surfaceContainer: Color(0xff2f3036),
      surfaceContainerHigh: Color(0xff3a3b41),
      surfaceContainerHighest: Color(0xff45474c),
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

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
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
