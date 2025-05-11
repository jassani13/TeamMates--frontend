import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/module/bottom/roster/addPlayer/add_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_function.dart';

class AddPlayerScreen extends StatelessWidget {
  AddPlayerScreen({super.key});

  final addPlayerController = Get.put<AddPlayerController>(AddPlayerController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final arg = Get.arguments;

  @override
  Widget build(BuildContext context) {
    print(arg);
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            CommonIconButton(
                image: AppImage.plus,
                onTap: () {
                  hideKeyboard();
                  if (formKey.currentState!.validate()) {
                    addPlayerController.addPlayer();
                  }
                }),
            Gap(20),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColor.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -2),
                color: AppColor.lightPrimaryColor,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: Platform.isAndroid ? 20 : 24),
          child: CommonAppButton(
            text: "Submit",
            onTap: () async {
              if (formKey.currentState!.validate()) {
                hideKeyboard();
                await addPlayerController.addMembersToTeam();
                // Get.toNamed(AppRouter.teamCode);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add players",
                    style: TextStyle().normal28w500s.textColor(
                          AppColor.black12Color,
                        ),
                  ),
                  Text(
                    "Invite players to join your team and get\nstarted.!",
                    style: TextStyle().normal16w500.textColor(
                          AppColor.grey4EColor,
                        ),
                  ),
                  Gap(24),
                  Obx(() {
                    return ListView.builder(
                      itemCount: addPlayerController.playerList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final playerDetail = addPlayerController.playerList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Spacer(),
                                if (addPlayerController.playerList.length > 1)
                                  GestureDetector(
                                    onTap: () {
                                      addPlayerController.playerList.remove(playerDetail);
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(padding: const EdgeInsets.all(6.0), child: SvgPicture.asset(AppImage.delete)),
                                    ),
                                  )
                              ],
                            ),
                            Gap(10),
                            CommonTextField(
                              autofillHints: const [
                                AutofillHints.namePrefix,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                                CapitalizedTextFormatter(),
                              ],
                              validator: (val) {
                                if ((val ?? "").isEmpty) {
                                  return "Please enter your first name";
                                } else {
                                  return null;
                                }
                              },
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(playerDetail.lNameFocusNode);
                              },
                              focusNode: playerDetail.fNameFocusNode,

                              hintText: "First Name",
                              keyboardType: TextInputType.name,
                              controller: playerDetail.fNameController,
                            ),
                            Gap(20),
                            CommonTextField(

                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(playerDetail.emailFocusNode);
                              },
                              focusNode: playerDetail.lNameFocusNode,

                              autofillHints: const [
                                AutofillHints.nameSuffix,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                                CapitalizedTextFormatter(),
                              ],
                              controller: playerDetail.lNameController,
                              hintText: "Last Name",
                              keyboardType: TextInputType.name,
                              validator: (val) {
                                if ((val ?? "").isEmpty) {
                                  return "Please enter your last name";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const Gap(20),
                            CommonTextField(
                              focusNode: playerDetail.emailFocusNode,
                              autofillHints: const [
                                AutofillHints.email,
                              ],
                              controller: playerDetail.emailController,
                              hintText: "Email",
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if ((val ?? "").isEmpty) {
                                  return "Please enter your email address";
                                } else if (!(val ?? "").isEmail) {
                                  return "Please enter a valid email address";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const Gap(24),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
