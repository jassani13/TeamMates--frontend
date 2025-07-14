import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:flutter/foundation.dart' as Foundation;


late Dio dio;

BaseOptions baseOptions = BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60));
const String publicImageUrl = "http://34.205.17.49/TeamMates/public/";
const String baseUrl = kDebugMode
    ? 'http://34.205.17.49/TeamMates'
    : 'http://34.205.17.49/TeamMates';
// https://team.notegiftcard.com/migrate-fresh DB clear

Future<void> dioSetUp({int? language}) async {
  dio = Dio(baseOptions);

  dio.interceptors.add(InterceptorsWrapper(onRequest:
      (RequestOptions option, RequestInterceptorHandler handler) async {
    var customHeaders = {
      'Accept': 'application/json',
      'X-Requested-With': "XMLHttpRequest",
      "key": "qIKiO7iXPr0XGexMkgm31R7k21Db7jkGKyA1kbxUt2s",
    };
    option.headers.addAll(customHeaders);
    handler.next(option);
  }));

  if (!Foundation.kReleaseMode) {
    var logger = PrettyDioLogger(
      maxWidth: 232,
      requestHeader: true,
      requestBody: true,
    );
    dio.interceptors.add(logger);
  }
  dio.options.baseUrl = baseUrl;
}
