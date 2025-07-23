import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

/// Responsive layout widget'ları
class ResponsiveLayout {
  /// Responsive grid layout
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
    EdgeInsets? padding,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final columnCount = PlatformUtils.getGridColumnCount(context);
    final platformPadding = padding ?? PlatformUtils.getPlatformPadding(context);

    return Padding(
      padding: platformPadding,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: _getChildAspectRatio(breakpoint),
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
        physics: PlatformUtils.getPlatformScrollPhysics(context),
      ),
    );
  }

  /// Responsive list layout
  static Widget responsiveList({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    final platformPadding = padding ?? PlatformUtils.getPlatformPadding(context);

    return Padding(
      padding: platformPadding,
      child: ListView.separated(
        controller: controller,
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(height: spacing),
        itemBuilder: (context, index) => children[index],
        physics: PlatformUtils.getPlatformScrollPhysics(context),
      ),
    );
  }

  /// Responsive card layout
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final platformPadding = padding ?? PlatformUtils.getPlatformPadding(context);
    final cardElevation = elevation ?? _getCardElevation(breakpoint);
    final cardBorderRadius = borderRadius ?? _getCardBorderRadius(breakpoint);

    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
      ),
      color: backgroundColor,
      child: Padding(
        padding: platformPadding,
        child: child,
      ),
    );
  }

  /// Responsive container layout
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    Color? color,
    BorderRadius? borderRadius,
    BoxBorder? border,
  }) {
    final platformPadding = padding ?? PlatformUtils.getPlatformPadding(context);
    final containerWidth = width ?? _getContainerWidth(context);
    final containerHeight = height ?? _getContainerHeight(context);

    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: platformPadding,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }

  /// Responsive row layout
  static Widget responsiveRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double spacing = 16.0,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);

    if (breakpoint == ResponsiveBreakpoint.smallMobile) {
      // Küçük mobilde dikey düzen
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          if (index < children.length - 1) {
            return Column(
              children: [
                child,
                SizedBox(height: spacing),
              ],
            );
          }
          return child;
        }).toList(),
      );
    }

    // Diğer ekranlarda yatay düzen
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        if (index < children.length - 1) {
          return Row(
            children: [
              child,
              SizedBox(width: spacing),
            ],
          );
        }
        return child;
      }).toList(),
    );
  }

  /// Responsive column layout
  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double spacing = 16.0,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        if (index < children.length - 1) {
          return Column(
            children: [
              child,
              SizedBox(height: spacing),
            ],
          );
        }
        return child;
      }).toList(),
    );
  }

  /// Responsive text widget
  static Widget responsiveText({
    required BuildContext context,
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final fontSize = PlatformUtils.getPlatformFontSize(context, style?.fontSize ?? 14.0);

    return Text(
      text,
      style: style?.copyWith(fontSize: fontSize) ?? TextStyle(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Responsive icon widget
  static Widget responsiveIcon({
    required BuildContext context,
    required IconData icon,
    double? size,
    Color? color,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final iconSize = size ?? PlatformUtils.getPlatformIconSize(context, 24.0);

    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }

  /// Responsive button widget
  static Widget responsiveButton({
    required BuildContext context,
    required Widget child,
    VoidCallback? onPressed,
    ButtonStyle? style,
    double? width,
    double? height,
    EdgeInsets? padding,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final buttonWidth = width ?? _getButtonWidth(context, breakpoint);
    final buttonHeight = height ?? _getButtonHeight(breakpoint);
    final buttonPadding = padding ?? _getButtonPadding(breakpoint);

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Padding(
          padding: buttonPadding,
          child: child,
        ),
      ),
    );
  }

  /// Responsive image widget
  static Widget responsiveImage({
    required BuildContext context,
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final imageWidth = width ?? _getImageWidth(context, breakpoint);
    final imageHeight = height ?? _getImageHeight(breakpoint);

    Widget image = Image.network(
      imageUrl,
      width: imageWidth,
      height: imageHeight,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: imageWidth,
          height: imageHeight,
          color: Colors.grey[300],
          child: Icon(
            Icons.image_not_supported,
            size: PlatformUtils.getPlatformIconSize(context, 24.0),
            color: Colors.grey[600],
          ),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }

  /// Responsive spacing widget
  static Widget responsiveSpacing({
    required BuildContext context,
    double? width,
    double? height,
  }) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final spacingWidth = width ?? _getSpacingWidth(breakpoint);
    final spacingHeight = height ?? _getSpacingHeight(breakpoint);

    return SizedBox(
      width: spacingWidth,
      height: spacingHeight,
    );
  }

  // Yardımcı fonksiyonlar

  static double _getChildAspectRatio(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 0.8; // Masaüstü: daha geniş kartlar
      case ResponsiveBreakpoint.tablet:
        return 0.7; // Tablet: orta boyut kartlar
      case ResponsiveBreakpoint.mobile:
        return 0.6; // Mobil: dar kartlar
      case ResponsiveBreakpoint.smallMobile:
        return 0.5; // Küçük mobil: çok dar kartlar
    }
  }

  static double _getCardElevation(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 4.0; // Masaüstü: daha belirgin gölge
      case ResponsiveBreakpoint.tablet:
        return 3.0; // Tablet: orta gölge
      case ResponsiveBreakpoint.mobile:
        return 2.0; // Mobil: hafif gölge
      case ResponsiveBreakpoint.smallMobile:
        return 1.0; // Küçük mobil: çok hafif gölge
    }
  }

  static BorderRadius _getCardBorderRadius(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return BorderRadius.circular(16.0); // Masaüstü: daha yuvarlak
      case ResponsiveBreakpoint.tablet:
        return BorderRadius.circular(12.0); // Tablet: orta yuvarlak
      case ResponsiveBreakpoint.mobile:
        return BorderRadius.circular(8.0); // Mobil: az yuvarlak
      case ResponsiveBreakpoint.smallMobile:
        return BorderRadius.circular(4.0); // Küçük mobil: çok az yuvarlak
    }
  }

  static double _getContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return screenWidth * 0.8; // Masaüstü: %80 genişlik
      case ResponsiveBreakpoint.tablet:
        return screenWidth * 0.9; // Tablet: %90 genişlik
      case ResponsiveBreakpoint.mobile:
        return screenWidth * 0.95; // Mobil: %95 genişlik
      case ResponsiveBreakpoint.smallMobile:
        return screenWidth; // Küçük mobil: tam genişlik
    }
  }

  static double _getContainerHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return screenHeight * 0.7; // Masaüstü: %70 yükseklik
      case ResponsiveBreakpoint.tablet:
        return screenHeight * 0.8; // Tablet: %80 yükseklik
      case ResponsiveBreakpoint.mobile:
        return screenHeight * 0.9; // Mobil: %90 yükseklik
      case ResponsiveBreakpoint.smallMobile:
        return screenHeight; // Küçük mobil: tam yükseklik
    }
  }

  static double _getButtonWidth(BuildContext context, ResponsiveBreakpoint breakpoint) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 200.0; // Masaüstü: sabit genişlik
      case ResponsiveBreakpoint.tablet:
        return screenWidth * 0.3; // Tablet: %30 genişlik
      case ResponsiveBreakpoint.mobile:
        return screenWidth * 0.5; // Mobil: %50 genişlik
      case ResponsiveBreakpoint.smallMobile:
        return screenWidth * 0.8; // Küçük mobil: %80 genişlik
    }
  }

  static double _getButtonHeight(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 56.0; // Masaüstü: büyük buton
      case ResponsiveBreakpoint.tablet:
        return 48.0; // Tablet: orta buton
      case ResponsiveBreakpoint.mobile:
        return 44.0; // Mobil: küçük buton
      case ResponsiveBreakpoint.smallMobile:
        return 40.0; // Küçük mobil: çok küçük buton
    }
  }

  static EdgeInsets _getButtonPadding(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
      case ResponsiveBreakpoint.tablet:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
      case ResponsiveBreakpoint.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case ResponsiveBreakpoint.smallMobile:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
    }
  }

  static double _getImageWidth(BuildContext context, ResponsiveBreakpoint breakpoint) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 300.0; // Masaüstü: büyük resim
      case ResponsiveBreakpoint.tablet:
        return screenWidth * 0.4; // Tablet: %40 genişlik
      case ResponsiveBreakpoint.mobile:
        return screenWidth * 0.6; // Mobil: %60 genişlik
      case ResponsiveBreakpoint.smallMobile:
        return screenWidth * 0.8; // Küçük mobil: %80 genişlik
    }
  }

  static double _getImageHeight(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 400.0; // Masaüstü: büyük resim
      case ResponsiveBreakpoint.tablet:
        return 300.0; // Tablet: orta resim
      case ResponsiveBreakpoint.mobile:
        return 250.0; // Mobil: küçük resim
      case ResponsiveBreakpoint.smallMobile:
        return 200.0; // Küçük mobil: çok küçük resim
    }
  }

  static double _getSpacingWidth(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 24.0; // Masaüstü: büyük boşluk
      case ResponsiveBreakpoint.tablet:
        return 20.0; // Tablet: orta boşluk
      case ResponsiveBreakpoint.mobile:
        return 16.0; // Mobil: küçük boşluk
      case ResponsiveBreakpoint.smallMobile:
        return 12.0; // Küçük mobil: çok küçük boşluk
    }
  }

  static double _getSpacingHeight(ResponsiveBreakpoint breakpoint) {
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 32.0; // Masaüstü: büyük boşluk
      case ResponsiveBreakpoint.tablet:
        return 28.0; // Tablet: orta boşluk
      case ResponsiveBreakpoint.mobile:
        return 24.0; // Mobil: küçük boşluk
      case ResponsiveBreakpoint.smallMobile:
        return 20.0; // Küçük mobil: çok küçük boşluk
    }
  }
} 