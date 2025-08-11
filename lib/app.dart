import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SampleApp extends StatefulWidget {
  const SampleApp({super.key});

  @override
  State<SampleApp> createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> with WidgetsBindingObserver {
  final List<StreamSubscription> _streams = [];
  bool isInternetAvailable = false;

  var locales = [
    const Locale('en', ''),
    const Locale('ar', ''),
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
            title: 'TeamMates',
            debugShowCheckedModeBanner: false,
            themeMode: AppPref().isDark == true ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRouter.splash,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            getPages: AppRouter.getPages,
            locale: Locale(AppPref().languageCode, ''),
            supportedLocales: locales,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1),
                ),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: (MediaQuery.of(context).platformBrightness == Brightness.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.light),
                  child: child ?? Container(),
                ),
              );
            },
            localizationsDelegates: const [],
          ),
        );
      },
    );
  }
}
