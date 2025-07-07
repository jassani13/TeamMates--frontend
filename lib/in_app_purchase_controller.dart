import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/store_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class InAppPurchaseController extends GetxController {
  static const monthly = "pro_plan_monthly";
  static const yearlyAndroid = "pro_plan_yearly";
  static const yearlyIOS = "12345";

  static const googleApiKey = "goog_UFeASeWksGxAfXHfOsjrUcwuBjL";
  static const appleApiKey = "appl_jkmsUVqUHhxFNVrpVZHmDoslGuo";
  RxString purchasedPlan = ''.obs;
  CustomerInfo? customerInfo;
  RxBool proUser = false.obs;
  List<StoreProduct> products = [];

  Future<void> _initLoad() async {
    await initPlatformState();
    await getProducts();
    await checkActiveSubscription();
  }

  getPurchasedPlan() {
    if (customerInfo != null) {
      var data = customerInfo?.entitlements.active['Pro']?.productIdentifier;
      if (data == monthly) {
        purchasedPlan.value = "Monthly plan";
      } else if (data == yearlyAndroid || data == yearlyIOS) {
        purchasedPlan.value = "Yearly plan";
      }
    }
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        StoreConfig(
          store: Store.appStore,
          apiKey: appleApiKey,
        );
      } else if (Platform.isAndroid) {
        StoreConfig(
          store: Store.playStore,
          apiKey: googleApiKey,
        );
      }
      await _configureSDK();
    } catch (e) {
      if (kDebugMode) {
        print("initPlatformState==========> $e");
      }
    }
  }

  Future<void> _configureSDK() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

      await Purchases.configure(configuration);
    } catch (e) {
      if (kDebugMode) {
        print("_configureSDK==========> $e");
      }
    }
  }

  Future<void> purchase({
    required String productId,
    required BuildContext context,
    bool isFromPurchase = false,
  }) async {
    try {
      if (isFromPurchase) {
        AppLoader().showLoader();
      }

      List<StoreProduct> products = await getProducts();
      if (products.isNotEmpty) {
        StoreProduct storeProduct = products.firstWhere((test) => test.identifier == productId);
        await Purchases.purchaseStoreProduct(storeProduct);
        await checkActiveSubscription(isFromPurchase: isFromPurchase);
        Get.back();
      }

      if (isFromPurchase) {
        AppLoader().dismissLoader();
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        AppToast.showAppToast(e.message ?? "");
      }
      if (isFromPurchase) {
        AppLoader().dismissLoader();
      }
    } finally {
      if (isFromPurchase) {
        AppLoader().dismissLoader();
      }
    }
  }

  Future<List<StoreProduct>> getProducts() async {
    try {
      List<StoreProduct> products = await Purchases.getProducts(
        [
          monthly,
          yearlyAndroid,
          yearlyIOS,
        ],
      );
      if (kDebugMode) {
        print(products);
      }
      return products;
    } catch (e) {
      if (kDebugMode) {
        print("purchase==========> $e");
      }
      return [];
    }
  }

  Future<void> checkActiveSubscription({isFromPurchase = false}) async {
    try {
      if (isFromPurchase) {
        AppLoader().showLoader();
      }

      customerInfo = await Purchases.getCustomerInfo();

      await _updateSubscriptionStatus(customerInfo, isFromPurchase: isFromPurchase);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      if (isFromPurchase) {
        AppLoader().dismissLoader();
      }
    }
  }

  Future<void> restore() async {
    try {
      AppLoader().showLoader();

      CustomerInfo customerInfo = await Purchases.restorePurchases();
      await _updateSubscriptionStatus(customerInfo, isFromRestore: true);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      AppLoader().dismissLoader();
    }
  }

  Future<void> _updateSubscriptionStatus(CustomerInfo? customerInfo, {bool isFromRestore = false, bool isFromPurchase = false}) async {
    if (customerInfo != null) {
      await setTransaction(customerInfo: customerInfo);

      bool isProActive = customerInfo.entitlements.all["Pro"]?.isActive ?? false;
      proUser.value = isProActive;
      AppPref().proUser = isProActive;
      getPurchasedPlan();
      if (isFromRestore) {
        AppToast.showAppToast("Subscription restore successfully");
      } else {
        if (isFromPurchase) {
          AppToast.showAppToast("Subscription purchased successfully");
        }
      }
      if (kDebugMode) {
        print("prouser=========> ${AppPref().proUser}");
      }
    }
  }

  Future<void> getTransaction() async {
    try {
      FormData formData = FormData.fromMap(
        {
          "user_id": AppPref().userId,
        },
      );
      var response = await callApi(
        dio.post(
          ApiEndPoint.getTransactionList,
          data: formData,
        ),
        false,
      );
      if (response?.statusCode == 200) {}
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> setTransaction({required CustomerInfo customerInfo}) async {
    try {
      if (AppPref().userId == null) {
        return;
      }
      var val = jsonEncode(customerInfo.toJson());
      FormData formData = FormData.fromMap(
        {
          "user_id": AppPref().userId,
          "history": val,
        },
      );
      var response = await callApi(
        dio.post(
          ApiEndPoint.setTransaction,
          data: formData,
        ),
        false,
      );
      if (response?.statusCode == 200) {
        if (kDebugMode) {
          print("CUSTOMER_INFO_SAVED =========");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    _initLoad();
    super.onInit();
  }
}
