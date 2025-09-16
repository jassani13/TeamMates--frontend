import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

bool isInternetAvailable = true;

Future<T?> callApi<T>(Future<T> request, [bool doShowLoader = true]) async {
  if (!isInternetAvailable) {
    AppToast.showAppToast("Internet not available");
    throw "Internet not available";
  }
  try {
    if (doShowLoader) AppLoader().showLoader(isCancelable: false);
    var response = await request;
    if (doShowLoader) AppLoader().dismissLoader();
    return response;
  } on DioException catch (dioError) {
    if (doShowLoader) AppLoader().dismissLoader();
    debugPrint("callApi :: DioError -> $dioError");
    onResponseError(dioError);
  } catch (error) {
    if (doShowLoader) AppLoader().dismissLoader();
    debugPrint("callApi :: Error -> $error");
  }
  return null;
}

onResponseError(onError) {
  debugPrint(
      "onResponseError:onError ${onError.toString()} || ${onError.response.statusCode}");
  if (onError is DioException) {
    switch (onError.response?.statusCode) {
      case 400:
      case 401:
        AppToast.showAppToast(
            'Login expires. Please re-login with Phone number.');
        break;
      case 403:
      case 404:
        break;
      case 406:
        var json = onError.response?.data;
        if (json.runtimeType.toString() != "_Map<String, dynamic>") {
          var json = onError.response?.data;
          showErrorSheet(
              json.toString().replaceAll('[', '').replaceAll(']', ''));
          break;
        }
        if (json.runtimeType.toString() == "List<dynamic>") {
          var json = onError.response?.data;
          showErrorSheet(json[0].replaceAll('[', '').replaceAll(']', ''));
          break;
        }
        showErrorSheet(
            json["message"].toString().replaceAll('[', '').replaceAll(']', ''));
        break;
      case 408:
      case 409:
      case 422:
        AppLoader().dismissLoader();
        var json = onError.response?.data;
        if (json.runtimeType.toString() != "_Map<String, dynamic>") {
          var json = onError.response?.data;
          showErrorSheet(
              json.toString().replaceAll('[', '').replaceAll(']', ''));
          break;
        }
        showErrorSheet(json["ResponseMsg"]
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', ''));
        break;
      case 423:
      case 426:
        break;
      case 500:
        showErrorSheet('Internal Server Error');
        break;
      default:
        break;
    }
  }
}

Future<void> showErrorSheet(String errorText, {Function()? onTap}) async {
  FocusManager.instance.primaryFocus?.unfocus();

  showModalBottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    context: Get.context!,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      padding: const EdgeInsetsDirectional.only(
        start: 24,
        end: 24,
        top: 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Text(
            "Error",
            style:
                const TextStyle().normal24w600.textColor(AppColor.black12Color),
          )),
          const Gap(16),
          for (var data in errorText.split(',')) ...{
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4),
                    child: CircleAvatar(
                        backgroundColor: AppColor.black12Color, radius: 5),
                  ),
                  const Gap(8),
                  Expanded(
                      child: Text(
                    data.trim().capitalizeFirst!,
                    style: TextStyle()
                        .normal14w500
                        .textColor(AppColor.black12Color),
                  )),
                ],
              ),
            ),
          },
          const Gap(16),
          CommonAppButton(
            buttonType: ButtonType.enable,
            onTap: onTap ??
                () {
                  // if(!kIsWeb){
                  //   Get.back();
                  // } else{
                  Navigator.pop(context);
                  // }
                },
            text: "Ok",
          ),
          const Gap(16),
        ],
      ),
    ),
  );
}
