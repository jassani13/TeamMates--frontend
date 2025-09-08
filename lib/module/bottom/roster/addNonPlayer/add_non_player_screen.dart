import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_function.dart';
import 'package:flutter/services.dart';
import '../../../../package/config_packages.dart';
import 'add_non_player_controller.dart';

class AddNonPlayerScreen extends StatelessWidget {
  AddNonPlayerScreen({super.key});

  final addNonPlayerController =
  Get.put<AddNonPlayerController>(AddNonPlayerController());
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
                    addNonPlayerController.addNonPlayer();
                  }
                }),
            const Gap(20),
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
          padding: EdgeInsets.symmetric(
              horizontal: 24, vertical: Platform.isAndroid ? 20 : 24),
          child: CommonAppButton(
            text: "Submit",
            onTap: () async {
              if (formKey.currentState!.validate()) {
                hideKeyboard();
                await addNonPlayerController.addMembersToTeam();
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
                    "Add Team Staff",
                    style: TextStyle().normal28w500s.textColor(
                      AppColor.black12Color,
                    ),
                  ),
                  Text(
                    "Invite team staff to join your team and get\nstarted.!",
                    style: TextStyle().normal16w500.textColor(
                      AppColor.grey4EColor,
                    ),
                  ),
                  const Gap(24),
                  Obx(() {
                    return ListView.builder(
                      itemCount: addNonPlayerController.playerList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final playerDetail =
                        addNonPlayerController.playerList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                if (addNonPlayerController.playerList.length > 1)
                                  GestureDetector(
                                    onTap: () {
                                      addNonPlayerController.playerList
                                          .remove(playerDetail);
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColor.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: SvgPicture.asset(
                                              AppImage.delete)),
                                    ),
                                  )
                              ],
                            ),
                            const Gap(10),
                            CommonTextField(
                              autofillHints: const [
                                AutofillHints.namePrefix,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z]')),
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
                                FocusScope.of(context)
                                    .requestFocus(playerDetail.lNameFocusNode);
                              },
                              focusNode: playerDetail.fNameFocusNode,
                              hintText: "First Name",
                              keyboardType: TextInputType.name,
                              controller: playerDetail.fNameController,
                            ),
                            const Gap(20),
                            CommonTextField(
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(playerDetail.emailFocusNodes[0]);
                              },
                              focusNode: playerDetail.lNameFocusNode,
                              autofillHints: const [
                                AutofillHints.nameSuffix,
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z]')),
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
                            _buildStaffRoleDropdown(playerDetail),
                            const Gap(20),
                            Column(
                              children: [
                                for (int emailIndex = 0;
                                emailIndex <
                                    playerDetail.emailControllers.length;
                                emailIndex++)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CommonTextField(
                                              focusNode: playerDetail
                                                  .emailFocusNodes[emailIndex],
                                              autofillHints: const [
                                                AutofillHints.email
                                              ],
                                              controller: playerDetail
                                                  .emailControllers[emailIndex],
                                              hintText: emailIndex == 0
                                                  ? "Primary Email"
                                                  : "Additional Email",
                                              textInputAction:
                                              TextInputAction.done,
                                              keyboardType:
                                              TextInputType.emailAddress,
                                              validator: (val) {
                                                if (emailIndex == 0 &&
                                                    (val ?? "").isEmpty) {
                                                  return "Please enter primary email address";
                                                } else if ((val ?? "")
                                                    .isNotEmpty &&
                                                    !(val ?? "").isEmail) {
                                                  return "Please enter a valid email address";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          if (emailIndex > 0)
                                            IconButton(
                                              onPressed: () =>
                                                  addNonPlayerController
                                                      .removeEmailField(
                                                      index, emailIndex),
                                              icon: const Icon(Icons.remove_circle,
                                                  color: Colors.red),
                                            ),
                                        ],
                                      ),
                                      const Gap(16),
                                    ],
                                  ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => addNonPlayerController.addEmailField(index),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Another Email"),
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

  Widget _buildStaffRoleDropdown(PlayerDetailModel playerDetail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.greyF6Color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: playerDetail.staff_role,
        dropdownColor: AppColor.white, // Set dropdown background to white
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Select Staff Role",
          hintStyle: TextStyle(color: AppColor.grey4EColor),
        ),
        items: addNonPlayerController.staffRoles.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: AppColor.black,fontSize: 14,), // 👈 Here's the change
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          playerDetail.staff_role = newValue!;
          addNonPlayerController.playerList.refresh();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a role";
          }
          return null;
        },
      ),
    );
  }
}