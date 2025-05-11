import 'package:base_code/package/config_packages.dart';

abstract class AppColor {
  const AppColor._();

  static bool isDarkTheme() {
    return Get.isDarkMode;
  }

  static changeThemeMode() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
      AppPref().isDark = false;
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      AppPref().isDark = true;
    }
  }

  static Color backGroundColor() {
    return isDarkTheme() ? DarkTheme.backGroundColor : LightTheme.backGroundColor;
  }

  static Color darkGray() {
    return isDarkTheme() ? DarkTheme.darkGray : LightTheme.darkGray;
  }

  static Color lightNatural() {
    return isDarkTheme() ? DarkTheme.lightNatural : LightTheme.lightNatural;
  }

  static Color gray() {
    return isDarkTheme() ? DarkTheme.gray : LightTheme.gray;
  }

  static Color cardColor() {
    return isDarkTheme() ? DarkTheme.cardColor : LightTheme.cardColor;
  }

  static Color cardTextColor() {
    return isDarkTheme() ? DarkTheme.cardTextColor : LightTheme.cardTextColor;
  }

  static Color orange() {
    return isDarkTheme() ? DarkTheme.orange : LightTheme.orange;
  }

  static Color purple() {
    return isDarkTheme() ? DarkTheme.purple : LightTheme.purple;
  }

  static const disableButtonColor = Color(0xFFADA9A6);

  ///app color
  static const black12Color = Color(0xFF121212);
  static const black45Color = Color(0xFF454545);

  static const primaryColor = Color(0xFFF0BB78);
  static const darkPrimaryColor = Color(0xFFE5802A);
  static const premiumColor = Color(0xFFFFB22C);
  static const grey4EColor = Color(0xFF4E4E4E);
  static const greyF6Color = Color(0xFFF6F6F6);
  static const greyEAColor = Color(0xFFEAEAEA);
  static const lightPrimaryColor = Color(0xFFFFFDF5);
  static const grey6EColor = Color(0xFF6E6E6E);
  static const lightBlueColor = Color(0xFFEFF6FD);
  static const brownColor = Color(0xFF3E190C);
  static const darkBrownColor = Color(0xFF3E190C);
  static const greenColor = Color(0xFF119963);
  static const successColor = Color(0xFF6BCB77);
  static const defaultColor = Color(0xFFFFA500);
  static const lemonColor = Color(0xFFFFFF00);
  static const cherryColor = Color(0xFFFF0000);
  static const limeColor = Color(0xFF00B800);
  static const grapeColor = Color(0xFFC435C0);

  static const primaryBlueColor = Color(0xFFE4F1F9);
  static const primaryColorLight = Color(0xFF196CFA);
  static const defaultIconColor = Color(0xFFA1A1AA);
  static const white = Color(0xFFFFFFFF);
  static const borderColor = Color(0xFFE4E4E7);
  static const bgBlueColor = Color(0xFFF6FBFF);

  static const redColor = Color(0xFFFF6B6B);
  static const blueColor = Color(0xFF89B6E0);
  static const yellowColor = Color(0xffFBDA1B);

  static const purpleColor = Color(0xff7A87FB);
  static const black = Color(0xFF020408);
  static const gray500 = Color(0xFF71717A);
  static const textFieldFillColor = Color(0xFFF8FAFC);
  static const gray200 = Color(0xFFE4F1F9);
  static const unTabColor = Color(0xFF52525B);
  static const tableDataRow = Color(0xFFF9FAFB);
  static const gray300 = Color(0xFFD4D4D8);

  static const purpleGradient1 = Color(0xff776DF2);
  static const subBlack = Color(0xff615B5C);

  static const gray100 = Color(0xFFF4F4F5);
  static const logbook = Color(0xFFEAE8E8);
  static const gray400 = Color(0xFF94A3B8);
  static const gray600 = Color(0xFF475569);
  static const gray800 = Color(0xFF1E293B);
  static const bodyBackGroundColor = Color(0xFFF6FBFF);

  static const primaryBlackColor = Color(0xFF131921);
  static const grey90Color = Color(0xFF121B24);
  static const lightGreyColor = Color(0xFF232F3E);
  static const darkGreyColor = Color(0xFF666666);
  static const grey50Color = Color(0xFFF0F0F0);
  static const grey60Color = Color(0xFF808080);
  static const red10Color = Color(0xFFFC4234);
  static const greyColor = Color(0xFF808080);
  static const grey80Color = Color(0xFF232F3E);
  static const grey70Color = Color(0xFF707070);
  static const primaryWhiteColor = Color(0xFFFFFFFF);
  static const appBarBlackColor = Color(0xFF2F353F);
  static const bodyLightColor = Color(0xFFF6F9FB);
  static const lightBlackColor = Color(0xFF1C2026);
  static const lightRedColor = Color(0xFFFBE8EA);
  static const upComingColor = Color(0xFF0DAC13);
  static const finishedColor = Color(0xFFFFBB0E);
  static const tabBarGreyColor = Color(0xFF7F7F7F);
  static const darkRedColor = Color(0xFFC30920);

  static const grey66Color = Color(0xFF666666);
  static const greyF0Color = Color(0xFFF0F0F0);
  static const greyB9Color = Color(0xFFB9B9B9);
  static const grey8DColor = Color(0xFF8D8D8D);
  static const lightGreyColor1 = Color(0xFFECF0F1);

  static const success100 = Color(0xffEAF8F0);
  static const success200 = Color(0xffD5F2E1);
  static const success300 = Color(0xffACE5C3);
  static const success400 = Color(0xff82D7A6);
  static const success500 = Color(0xff59CA88);
  static const success600 = Color(0xff2FBD6A);

  static const grey50 = Color(0xffF4F4F6);
  static const grey100 = Color(0xffE4E5E7);
  static const grey200 = Color(0xffD6D7DB);
  static const grey300 = Color(0xffC4C6CC);
  static const grey400 = Color(0xffA0A3AD);
  static const grey500 = Color(0xff717585);
  static const grey600 = Color(0xff595E70);
  static const grey700 = Color(0xff41475C);
  static const grey800 = Color(0xff1E253D);
  static const grey900 = Color(0xff121933);

  static const zeoRunColor = Color(0xFFA0A5A9);
  static const fourRunColor = Color(0xFFD19C56);
  static const sixRunColor = Color(0xFFD897F4);
  static const wicketColor = Color(0xFFC30920);
  static const otherRunColor = Color(0xFF385880);
}

class LightTheme {
  static const backGroundColor = Color(0xFF323234);
  static const darkGray = Color(0xFF979392);
  static const lightNatural = Color(0xFFF6F1ED);
  static const orange = Color(0xFFF37240);
  static const purple = Color(0xFF7B4B89);
  static const gray = Color(0xFF979392);
  static const cardColor = Color(0xFFF37240);
  static const cardTextColor = Color(0xFF323234);
}

class DarkTheme {
  static const backGroundColor = Color(0xFF323234);
  static const darkGray = Color(0xFF979392);
  static const lightNatural = Color(0xFFF6F1ED);
  static const orange = Color(0xFFF37240);
  static const purple = Color(0xFF7B4B89);
  static const gray = Color(0xFF979392);
  static const cardColor = Color(0xFFF37240);
  static const cardTextColor = Color(0xFF323234);
}
