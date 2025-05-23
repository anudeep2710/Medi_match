import 'package:flutter/material.dart';

/// Responsive helper utilities for adaptive UI design
class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize;
    } else if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.4;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 56.0;
    } else {
      return 64.0;
    }
  }

  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2.0;
    } else if (isTablet(context)) {
      return 4.0;
    } else {
      return 6.0;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  /// Get responsive container width
  static double getResponsiveWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return maxWidth != null ? 
        (screenWidth * 0.8).clamp(0, maxWidth) : 
        screenWidth * 0.8;
    } else {
      return maxWidth != null ? 
        (screenWidth * 0.6).clamp(0, maxWidth) : 
        screenWidth * 0.6;
    }
  }

  /// Get responsive grid columns
  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get responsive cross axis count for grid
  static int getResponsiveCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    if (isMobile(context)) {
      return mobile ?? 1;
    } else if (isTablet(context)) {
      return tablet ?? 2;
    } else {
      return desktop ?? 3;
    }
  }

  /// Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 16 / 9; // Standard mobile ratio
    } else if (isTablet(context)) {
      return 4 / 3; // Tablet ratio
    } else {
      return 16 / 10; // Desktop ratio
    }
  }

  /// Get responsive image height
  static double getResponsiveImageHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (isMobile(context)) {
      return screenHeight * 0.3;
    } else if (isTablet(context)) {
      return screenHeight * 0.4;
    } else {
      return screenHeight * 0.5;
    }
  }

  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return 500;
    } else {
      return 600;
    }
  }

  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else if (isTablet(context)) {
      return kToolbarHeight * 1.2;
    } else {
      return kToolbarHeight * 1.4;
    }
  }

  /// Get responsive safe area padding
  static EdgeInsets getResponsiveSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final basePadding = mediaQuery.padding;
    
    if (isMobile(context)) {
      return basePadding;
    } else {
      return EdgeInsets.only(
        top: basePadding.top,
        bottom: basePadding.bottom,
        left: basePadding.left + 16,
        right: basePadding.right + 16,
      );
    }
  }

  /// Get responsive layout based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get responsive layout constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    if (isMobile(context)) {
      return BoxConstraints(
        maxWidth: screenSize.width,
        maxHeight: screenSize.height,
      );
    } else if (isTablet(context)) {
      return BoxConstraints(
        maxWidth: 800,
        maxHeight: screenSize.height,
      );
    } else {
      return BoxConstraints(
        maxWidth: 1200,
        maxHeight: screenSize.height,
      );
    }
  }
}
