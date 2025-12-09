import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:flutter/foundation.dart' as Foundation;

late Dio dio;

BaseOptions baseOptions = BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60));

const bool useLocalServer = false;

//const String productionBaseUrl = /*'http://13.220.132.157'*/ 'http://api.teammatesapp.org';
const String productionBaseUrl = 'http://54.196.239.6';
//const String localBaseUrl = 'http://127.0.0.1:8000';
 String localBaseUrl =Platform.isIOS? 'http://127.0.0.1:8000': 'http://10.0.2.2:8000';

 String baseUrl = useLocalServer ? localBaseUrl : productionBaseUrl;

 String publicImageUrl =
    useLocalServer ? "$localBaseUrl/" : "$productionBaseUrl/";

// https://team.notegiftcard.com/migrate-fresh DB clear
//03007182536 --- wifi
Future<void> dioSetUp({int? language}) async {

  dio = Dio(baseOptions);

  dio.interceptors.add(InterceptorsWrapper(onRequest:
      (RequestOptions option, RequestInterceptorHandler handler) async {
    var customHeaders = {
      'Accept': 'application/json',
      'X-Requested-With': "XMLHttpRequest",
      //"key": "qIKiO7iXPr0XGexMkgm31R7k21Db7jkGKyA1kbxUt2s",
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
