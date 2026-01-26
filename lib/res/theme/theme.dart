import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

abstract class AppTheme {
  const AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    focusColor: AppColor.grey100,
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColor.gray(),
        cursorColor: AppColor.black..withValues(alpha: (0.4)),
        selectionHandleColor: AppColor.black),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColor.white,
    brightness: Brightness.light,
    primaryColor: AppColor.black,
    fontFamily: StringConst.primaryFontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColor.primaryBlackColor,
      onPrimary: AppColor.bodyLightColor,
      secondary: AppColor.white,
      onSecondary: AppColor.grey66Color,
      error: AppColor.grey500,
      onError: AppColor.grey400,
      surfaceContainerLowest : AppColor.appBarBlackColor,
      onSurfaceVariant: AppColor.black,
      surface: AppColor.white,
      onSurface: AppColor.greyF0Color,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
      backgroundColor: AppColor.white,
      selectedItemColor: AppColor.primaryBlackColor,
      unselectedItemColor: AppColor.greyB9Color,
    ),

    // tabBarTheme: TabBarTheme(
    //     tabAlignment: TabAlignment.start,
    //     indicatorSize: TabBarIndicatorSize.tab,
    //     labelColor: AppColor.white,
    //     unselectedLabelColor: AppColor.greyColor,
    //     labelStyle: const TextStyle().normal14w400,
    //     unselectedLabelStyle: const TextStyle().normal14w400,
    //     indicator: const UnderlineTabIndicator(
    //       // color for indicator (underline)
    //       borderSide: BorderSide(
    //         color: Colors.white,
    //         width: 4,
    //       ),
    //     ),
    //     dividerColor: Colors.transparent),

    tabBarTheme: TabBarThemeData(
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColor.white,
        unselectedLabelColor: AppColor.greyColor,
        labelStyle: const TextStyle().normal14w400,
        unselectedLabelStyle: const TextStyle().normal14w400,
        indicator: const UnderlineTabIndicator(
          // color for indicator (underline)
          borderSide: BorderSide(
            color: Colors.white,
            width: 4,
          ),
        ),
        dividerColor: Colors.transparent),

    appBarTheme: AppBarTheme(
      foregroundColor: AppColor.black,
      centerTitle: true,
      titleSpacing: 0,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: StringConst.primaryFontFamily,
          color: AppColor.black),
      backgroundColor: AppColor.white,
      iconTheme: const IconThemeData(color: AppColor.black),
      actionsIconTheme: const IconThemeData(color: AppColor.black),
      surfaceTintColor: AppColor.gray200,
      //systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      modalElevation: 8,
      backgroundColor: AppColor.white,
      modalBackgroundColor: AppColor.white,
    ),
    dividerColor: AppColor.grey200,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColor.black;
        } else if (states.contains(WidgetState.pressed)) {
          return AppColor.black;
        } else if (states.contains(WidgetState.focused)) {
          return AppColor.black;
        } else if (states.contains(WidgetState.hovered)) {
          return AppColor.black;
        } else {
          return AppColor.white;
        }
      }),
    ),
    indicatorColor: AppColor.grey100,
    hintColor: AppColor.grey500,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.black, foregroundColor: AppColor.white),
  );

  static final ThemeData darkTheme = ThemeData(
    focusColor: AppColor.grey600,
    primaryColor: AppColor.white,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColor.white..withValues(alpha: (0.4)),
      cursorColor: AppColor.white..withValues(alpha: (0.4)),
      selectionHandleColor: AppColor.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColor.black,
    brightness: Brightness.dark,
    fontFamily: StringConst.primaryFontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColor.appBarBlackColor,
      onPrimary: AppColor.primaryBlackColor,
      secondary: AppColor.lightBlackColor,
      onSecondary: AppColor.greyB9Color,
      error: AppColor.grey400,
      onError: AppColor.grey500,
      surfaceContainerLowest: AppColor.lightBlackColor,
      onSurfaceVariant: Colors.transparent,
      surface: AppColor.greyB9Color,
      onSurface: AppColor.appBarBlackColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
      backgroundColor: AppColor.appBarBlackColor,
      selectedItemColor: AppColor.white,
      unselectedItemColor: AppColor.grey66Color,
    ),

    // tabBarTheme: TabBarTheme(
    //     tabAlignment: TabAlignment.start,
    //     indicatorSize: TabBarIndicatorSize.tab,
    //     labelColor: AppColor.white,
    //     unselectedLabelColor: AppColor.greyColor,
    //     labelStyle: const TextStyle().normal14w400,
    //     unselectedLabelStyle: const TextStyle().normal14w400,
    //     indicator: const UnderlineTabIndicator(
    //       // color for indicator (underline)
    //       borderSide: BorderSide(color: Colors.white, width: 4),
    //     ),
    //     dividerColor: Colors.transparent),

    tabBarTheme: TabBarThemeData(
        indicatorColor: AppColor.black,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColor.white,
        unselectedLabelColor: AppColor.greyColor,
        labelStyle: const TextStyle().normal14w400,
        unselectedLabelStyle: const TextStyle().normal14w400,
        indicator: const UnderlineTabIndicator(
          // color for indicator (underline)
          borderSide: BorderSide(color: Colors.white, width: 4),
        ),
        dividerColor: Colors.transparent),

    appBarTheme: AppBarTheme(
      foregroundColor: AppColor.white,
      centerTitle: true,
      titleSpacing: 0,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: StringConst.primaryFontFamily),
      backgroundColor: AppColor.black,
      iconTheme: const IconThemeData(color: AppColor.white),
      actionsIconTheme: const IconThemeData(color: AppColor.white),
      surfaceTintColor: AppColor.greyB9Color,
      //systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      modalElevation: 8,
      backgroundColor: AppColor.black,
      modalBackgroundColor: AppColor.white,
    ),
    dividerColor: AppColor.grey200,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColor.white;
        } else if (states.contains(WidgetState.pressed)) {
          return AppColor.white;
        } else if (states.contains(WidgetState.focused)) {
          return AppColor.white;
        } else if (states.contains(WidgetState.hovered)) {
          return AppColor.white;
        } else {
          return AppColor.white;
        }
      }),
    ),
    hintColor: AppColor.grey300,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.white, foregroundColor: AppColor.black),
  );
}
