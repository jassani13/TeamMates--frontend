import 'package:base_code/module/bottom/home/account/profile/profile_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final profileController = Get.put<ProfileController>(ProfileController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle().normal20w500,
          ),
          actions: [
            Obx(() {
              return CommonIconButton(
                image: profileController.isEdit.value
                    ? AppImage.check
                    : AppImage.edit,
                onTap: () async {
                  if (!profileController.isEdit.value) {
                    profileController.isEdit.value =
                        !profileController.isEdit.value;
                  } else {
                    // if (formKey.currentState?.validate() ?? false) {
                    profileController.updateProfile();
                    // }
                  }
                },
              );
            }),
            Gap(20),
          ],
          centerTitle: false,
        ),
        body: Obx(() {
          return profileController.isLoad.value
              ? SizedBox()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: formKey,
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Gap(16),
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Obx(() {
                                          return profileController.profileImage
                                                  .value.path.isEmpty
                                              ? ((profileController.userModel
                                                              .value.profile ??
                                                          "")
                                                      .isNotEmpty)
                                                  ? getImageView(
                                                      finalUrl: publicImageUrl +
                                                          (profileController
                                                                  .userModel
                                                                  .value
                                                                  .profile ??
                                                              ""),
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      height: 120,
                                                    )
                                                  : Icon(
                                                      Icons.account_circle,
                                                      color:
                                                          AppColor.grey6EColor,
                                                      size: 125,
                                                    )
                                              : Image.file(
                                                  File(profileController
                                                      .profileImage.value.path),
                                                  fit: BoxFit.cover,
                                                  width: 120,
                                                  height: 120,
                                                );
                                        }),
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return (!profileController.isEdit.value)
                                        ? SizedBox()
                                        : GestureDetector(
                                            onTap: () {
                                              profileController
                                                  .showOptions(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColor.black12Color,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              // margin: EdgeInsets.all(10),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: AppColor.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          );
                                  })
                                ],
                              ),
                            ),
                            Gap(10),
                            Center(
                              child: Text(
                                '${profileController.userModel.value.firstName ?? ""} ${profileController.userModel.value.lastName ?? ""}',
                                style: TextStyle().normal18w500.textColor(
                                      AppColor.black12Color,
                                    ),
                              ),
                            ),
                            if (profileController.userModel.value.role ==
                                'team') ...[
                              if (profileController.userModel.value.position !=
                                  null)
                                Center(
                                  child: Text(
                                    profileController
                                            .userModel.value.position ??
                                        "",
                                    style: TextStyle().normal14w500.textColor(
                                          AppColor.grey4EColor,
                                        ),
                                  ),
                                ),
                              Center(
                                child: Text(
                                  "Player code ${profileController.userModel.value.playerCode ?? ""}",
                                  style: TextStyle(height: 1)
                                      .normal14w500
                                      .textColor(
                                        AppColor.grey4EColor,
                                      ),
                                ),
                              ),
                            ],
                            Gap(12),
                            CommonTitleText(text: "Personal info"),
                            Gap(12),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    return CommonTextField(
                                      autofillHints: const [
                                        AutofillHints.namePrefix,
                                      ],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[A-Za-z]')),
                                        CapitalizedTextFormatter(),
                                      ],
                                      readOnly: !profileController.isEdit.value,
                                      controller:
                                          profileController.fNameController,
                                      hintText: "First Name",
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Please enter your first name";
                                        } else {
                                          return null;
                                        }
                                      },
                                    );
                                  }),
                                ),
                                Gap(16),
                                Expanded(
                                  child: Obx(() {
                                    return CommonTextField(
                                      autofillHints: const [
                                        AutofillHints.nameSuffix,
                                      ],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[A-Za-z]')),
                                        CapitalizedTextFormatter(),
                                      ],
                                      readOnly: !profileController.isEdit.value,
                                      controller:
                                          profileController.lNameController,
                                      hintText: "Last Name",
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Please enter your last name";
                                        } else {
                                          return null;
                                        }
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                            Gap(16),
                            CommonTextField(
                              readOnly: true,
                              controller: profileController.dobController,
                              hintText: "Birth date",
                              validator: (val) {
                                if ((val ?? "").isEmpty) {
                                  return "Please enter your birth date";
                                } else {
                                  return null;
                                }
                              },
                              onTap: () {
                                if (profileController.isEdit.value) {
                                  profileController.showDatePicker(context, 0,
                                      profileController.dobController,
                                      initial: profileController.dobController
                                              .value.text.isNotEmpty
                                          ? DateTime.parse(profileController
                                              .dobController.value.text)
                                          : null);
                                }
                              },
                            ),
                            Gap(16),
                            SizedBox(
                              height: 45,
                              child: HorizontalSelectionList(
                                items: profileController.selectedMethod2List,
                                selectedIndex:
                                    profileController.selectedSearchMethod2,
                                controller: profileController.controller2,
                                onItemSelected: (index) {
                                  if (profileController.isEdit.value) {
                                    profileController
                                        .selectedSearchMethod2.value = index;
                                  }
                                },
                              ),
                            ),
                            Gap(16),
                            Visibility(
                              visible: profileController.userModel.value.role ==
                                  'team',
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      return CommonTextField(
                                        readOnly:
                                            !profileController.isEdit.value,
                                        controller: profileController
                                            .jerseyNumberController,
                                        hintText: "Jersey Number",
                                        validator: (val) {
                                          if ((val ?? "").isEmpty) {
                                            return "Please enter your jersey number";
                                          } else {
                                            return null;
                                          }
                                        },
                                      );
                                    }),
                                  ),
                                  Gap(16),
                                  Expanded(
                                    child: Obx(() {
                                      return CommonTextField(
                                        autofillHints: const [
                                          AutofillHints.nameSuffix,
                                        ],
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[A-Za-z]{0,2}$')),
                                        ],
                                        keyboardType: TextInputType.name,
                                        readOnly:
                                            !profileController.isEdit.value,
                                        controller: profileController
                                            .positionController,
                                        hintText: "Position",
                                        validator: (val) {
                                          if ((val ?? "").isEmpty) {
                                            return "Please enter your position";
                                          } else if (!RegExp(r'^[A-Za-z]{1,2}$')
                                              .hasMatch(val!)) {
                                            return "Enter one or two letters (e.g., L, LW, GK)";
                                          }
                                          return null;
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Gap(20),
                            CommonTitleText(
                              text: "Contact information",
                            ),
                            Gap(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show multiple emails if available, otherwise show single email
                                if (profileController
                                            .userModel.value.userEmails !=
                                        null &&
                                    profileController.userModel.value
                                        .userEmails!.isNotEmpty) ...[
                                  // Multiple emails section
                                  for (int i = 0;
                                      i <
                                          profileController.userModel.value
                                              .userEmails!.length;
                                      i++) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CommonTextField(
                                            readOnly: true,
                                            controller: TextEditingController(
                                                text: profileController
                                                    .userModel
                                                    .value
                                                    .userEmails![i]),
                                            hintText: i == 0
                                                ? "Primary Email"
                                                : "Additional Email",
                                            validator: (val) {
                                              if ((val ?? "").isEmpty) {
                                                return "Please enter your email";
                                              } else if (!((val ?? "")
                                                  .isEmail)) {
                                                return "Please enter your valid email";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Gap(8),
                                        if (i == 0)
                                          Icon(
                                            Icons.star,
                                            color: AppColor.primaryColor,
                                            size: 20,
                                          )
                                        else
                                          Icon(
                                            Icons.email_outlined,
                                            color: AppColor.grey4EColor,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    if (i <
                                        profileController.userModel.value
                                                .userEmails!.length -
                                            1)
                                      Gap(12),
                                  ],
                                ] else ...[
                                  // Single email (fallback)
                                  CommonTextField(
                                    readOnly: true,
                                    controller:
                                        profileController.emailController,
                                    hintText: "E-mail",
                                    validator: (val) {
                                      if ((val ?? "").isEmpty) {
                                        return "Please enter your email";
                                      } else if (!((val ?? "").isEmail)) {
                                        return "Please enter your valid email";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ],
                            ),
                            Gap(16),
                            Obx(() {
                              return CommonTextField(
                                keyboardType: TextInputType.phone,
                                readOnly: !profileController.isEdit.value,
                                controller:
                                    profileController.phoneNumberController,
                                hintText: "Phone number",
                                validator: (val) {
                                  if ((val ?? "").isEmpty) {
                                    return "Please enter your phone number";
                                  } else {
                                    return null;
                                  }
                                },
                              );
                            }),
                            Gap(16),
                            Obx(() {
                              return CommonTextField(
                                readOnly: !profileController.isEdit.value,
                                controller: profileController.addressController,
                                hintText: "Address",
                                validator: (val) {
                                  if ((val ?? "").isEmpty) {
                                    return "Please enter your address";
                                  } else {
                                    return null;
                                  }
                                },
                              );
                            }),
                            Gap(16),
                            Obx(() {
                              return CommonTextField(
                                readOnly: !profileController.isEdit.value,
                                controller: profileController.cityController,
                                hintText: "City",
                                validator: (val) {
                                  if ((val ?? "").isEmpty) {
                                    return "Please enter your city";
                                  } else {
                                    return null;
                                  }
                                },
                              );
                            }),
                            Gap(16),
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    return CommonTextField(
                                      readOnly: !profileController.isEdit.value,
                                      controller:
                                          profileController.stateController,
                                      hintText: "State",
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Please enter your state";
                                        } else {
                                          return null;
                                        }
                                      },
                                    );
                                  }),
                                ),
                                Gap(16),
                                Expanded(
                                  child: Obx(() {
                                    return CommonTextField(
                                      readOnly: !profileController.isEdit.value,
                                      controller:
                                          profileController.zipCodeController,
                                      hintText: "Zipcode",
                                      keyboardType: TextInputType.phone,
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Please enter your zipcode";
                                        } else {
                                          return null;
                                        }
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                            Gap(12),
                            CommonTitleText(text: "Emergency contact info"),
                            Gap(12),
                            Obx(() {
                              return CommonTextField(
                                readOnly: !profileController.isEdit.value,
                                controller: profileController.eNumController,
                                keyboardType: TextInputType.phone,
                                hintText: "Phone number",
                                validator: (val) {
                                  if ((val ?? "").isEmpty) {
                                    return "Please enter your phone number";
                                  } else {
                                    return null;
                                  }
                                },
                              );
                            }),
                            Gap(40),
                            CommonTitleText(
                              text: "Document",
                            ),
                            Gap(10),
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      profileController.showOptions(context,
                                          isFromDocUpload: true);
                                    },
                                    child: Obx(() {
                                      return profileController
                                              .documentImage.value.path.isEmpty
                                          ? ((profileController.userModel.value
                                                          .doc ??
                                                      "")
                                                  .isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: getImageView(
                                                    finalUrl: (profileController
                                                            .userModel
                                                            .value
                                                            .doc ??
                                                        ""),
                                                    fit: BoxFit.contain,
                                                    width: double.infinity,
                                                    height: 300,
                                                  ),
                                                )
                                              : Container(
                                                  height: 100,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: AppColor.greyEAColor,
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          color: AppColor.black,
                                                        ),
                                                        Gap(4),
                                                        Text(
                                                          "Add Document",
                                                          style: TextStyle()
                                                              .normal16w400
                                                              .textColor(
                                                                  AppColor
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                File(profileController
                                                    .documentImage.value.path),
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                height: 300,
                                              ),
                                            );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            Gap(40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        }),
      ),
    );
  }
}
