import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

class GroupChatController extends GetxController {
  Future<String> setMediaChatApiCall({
    required result,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'media': [
          await MultipartFile.fromFile(
            result?.path ?? "",
            filename: basename(result?.path ?? ""),
          ),
        ]
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.setChatMedia,
          data: formData,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        return res?.data["data"]["media_name"];
      }
      return "";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "";
    } finally {}
  }
}
