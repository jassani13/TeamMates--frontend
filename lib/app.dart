import 'package:base_code/demo.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SampleApp extends StatefulWidget {
  const SampleApp({super.key});

  @override
  State<SampleApp> createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> with WidgetsBindingObserver {
  final List<StreamSubscription> _streams = [];
  bool isInternetAvailable = false;

  var locales = [
    const Locale('en'), // English, no country code
    const Locale('ar'), // Arabic, no country code
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    for (var element in _streams) {
      element.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ToastificationWrapper(
          child: GetMaterialApp(
            home: demo(),
            title: 'TeamMates',
            debugShowCheckedModeBanner: false,
            themeMode: AppPref().isDark == true ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRouter.splash,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            getPages: AppRouter.getPages,
            locale: _getLocale(), // Use helper function to get valid locale
            supportedLocales: locales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1),
                ),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: (MediaQuery.of(context).platformBrightness == Brightness.light
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark),
                  child: child ?? const SizedBox(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper function to get a valid locale
  Locale _getLocale() {
    final languageCode = AppPref().languageCode;

    // Return a valid locale - either with null country code or valid country code
    if (languageCode == 'en') {
      return const Locale('en', 'US'); // English with US country code
    } else if (languageCode == 'ar') {
      return const Locale('ar', 'SA'); // Arabic with Saudi Arabia country code
    } else {
      // Default fallback
      return const Locale('en', 'US');
    }
  }
}