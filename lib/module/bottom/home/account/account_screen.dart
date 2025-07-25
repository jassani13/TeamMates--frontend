import 'package:base_code/data/pref/app_preferences.dart' as SignInWithApple;
import 'package:base_code/module/bottom/schedule/schedule_screen.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  final accountController = Get.put<AccountController>(AccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle().normal20w500,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(16),
              Container(
                padding: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColor.greyF6Color,
                    ),
                  ),
                ),
                child: Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: getImageView(
                            finalUrl: '${accountController.userModel.value.profile ?? ""}',
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Gap(12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${accountController.userModel.value.firstName ?? ""} ${accountController.userModel.value.lastName ?? ""}',
                              style: TextStyle().normal20w500.textColor(
                                    AppColor.black12Color,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(2),
                            Text(
                              accountController.userModel.value.email ?? "",
                              style: TextStyle().normal14w500.textColor(
                                    AppColor.grey4EColor,
                                  ),
                            ),
                            Visibility(
                              visible: AppPref().role == 'team',
                              child: Column(
                                children: [
                                  Gap(4),
                                  Row(
                                    children: [
                                      Text(
                                        "Player code : ${accountController.userModel.value.playerCode ?? ""}",
                                        style: TextStyle().normal14w500.textColor(
                                              AppColor.grey4EColor,
                                            ),
                                      ),
                                      Gap(10),
                                      GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: "${accountController.userModel.value.playerCode ?? ""}"));
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Gap(32),
              CommonTitleText(text: "Account"),
              Gap(20),
              // buildContainer(
              //   isNoti: true,
              // ),
              buildContainer(
                text: "Edit profile",
                isNoti: false,
                icon: AppImage.edit,
                onTap: () {
                  Get.toNamed(AppRouter.profile)?.then((val) {
                    if (val != null) {
                      accountController.userModel.value = val;
                      accountController.userModel.refresh();
                    }
                  });
                },
              ),
              Gap(12),
              CommonTitleText(text: "General"),
              Gap(16),
              Visibility(
                visible: AppPref().role == 'coach',
                child: buildContainer(
                    isNoti: false,
                    text: "Upgrade plan",
                    icon: AppImage.plan,
                    onTap: () {
                      Get.toNamed(AppRouter.subscription);
                    }),
              ),
              buildContainer(
                  isNoti: false,
                  text: "Support",
                  icon: AppImage.support,
                  onTap: () {
                    Get.toNamed(AppRouter.support);
                  }),
              buildContainer(
                  isNoti: false,
                  text: "Privacy & Policy",
                  icon: AppImage.privacy,
                  onTap: () {
                    Get.toNamed(AppRouter.terms, arguments: [1]);
                  }),
              buildContainer(
                  isNoti: false,
                  text: "Terms of service",
                  icon: AppImage.terms,
                  onTap: () {
                    Get.toNamed(AppRouter.terms, arguments: [2]);
                  }),
              // buildContainer(
              //     isNoti: false,
              //     text: "Refund Policy",
              //     icon: AppImage.refund,
              //     onTap: () {
              //       Get.toNamed(AppRouter.terms, arguments: [3]);
              //     }),
              // buildContainer(
              //     isNoti: false,
              //     text: "User Agreement",
              //     icon: AppImage.agreement,
              //     onTap: () {
              //       Get.toNamed(AppRouter.terms, arguments: [4]);
              //     }),

              // buildContainer(
              //     text: "Invite player",
              //     icon: AppImage.player,
              //     isInvite: true,
              //     onTap: () {
              //       // Get.toNamed(AppRouter.terms);
              //     }),
              buildContainer(
                text: "Delete Account",
                icon: AppImage.delete,
                onTap: () {
                  showAlertDialog(
                    btn2Text: "Yes",
                    title: "Are you sure you want to delete your account?",
                    subtitle: "This action is permanent and will remove all your data from our servers. "
                        "You will not be able to recover your account or any associated data after deletion.",
                    context: context,
                    btn2Tap: () async {
                      Get.back();
                      await accountController.deleteAccount();
                    },
                  );
                },
              ),
              buildContainer(
                  text: "Logout",
                  icon: AppImage.logOut,
                  onTap: () {
                    showAlertDialog(
                        context: context,
                        btn2Tap: () async {
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();
                          AppPref().clear();
                          AppPref().isFirstTime = true;
                          Get.offAllNamed(AppRouter.login);
                        });
                  }),

              Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainer({
    bool? isNoti,
    bool? isInvite = false,
    String? text,
    String? icon,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            8,
          ),
          color: AppColor.greyF6Color,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon ?? AppImage.noti,
              height: 24,
              width: 24,
            ),
            Gap(16),
            Text(
              text ?? "Notification Permissions",
              style: TextStyle().normal16w500.textColor(
                    (text ?? "").toLowerCase().contains("logout") ? AppColor.redColor : AppColor.black12Color,
                  ),
            ),
            Spacer(),
            if (isNoti == true) ...[
              Obx(
                () => CupertinoSwitch(
                  activeTrackColor: AppColor.grey4EColor.withValues(
                    alpha: 0.5,
                  ),
                  thumbColor: AppColor.black12Color,
                  value: accountController.isNoti.value,
                  onChanged: (val) {
                    accountController.isNoti.value = !accountController.isNoti.value;
                  },
                ),
              ),
            ] else if (isNoti == false) ...[
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.black12Color,
                size: 20,
              ),
            ] else if (isInvite == true) ...[
              SvgPicture.asset(
                AppImage.invite,
              ),
            ] else
              ...[]
          ],
        ),
      ),
    );
  }
}
