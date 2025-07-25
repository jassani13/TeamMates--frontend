import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/components/horizontal_list.dart';
import 'package:base_code/model/roster.dart';
import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/module/bottom/roster/playerOverview/EditPlayer/edit_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_function.dart';

class EditPlayerScreen extends StatefulWidget {
  const EditPlayerScreen({super.key});

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final editPlayerController = Get.put<EditPlayerController>(EditPlayerController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int index = Get.arguments[0];
  final allPlayerController = Get.find<AllPlayerController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editPlayerController.allergyController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].allergy ?? "";

    editPlayerController.fNameController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].firstName ?? "";
    editPlayerController.cfNameController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].firstName ?? "";
    editPlayerController.lNameController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].lastName ?? "";
    editPlayerController.clNameController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].lastName ?? "";
    editPlayerController.birthdayController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].dob ?? "";
    editPlayerController.jNumberController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].jerseyNumber ?? "";
    editPlayerController.positionController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].position ?? "";
    editPlayerController.numberController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].phoneNumber ?? "";
    editPlayerController.addressController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].address ?? "";
    editPlayerController.cityController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].city ?? "";
    editPlayerController.stateController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].state ?? "";
    editPlayerController.zipController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].zipcode ?? "";
    editPlayerController.emailController.value.text = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].email ?? "";
    if (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].gender.toString().toLowerCase() == "female") {
      editPlayerController.selectedSearchMethod2.value = 1;
    } else {
      editPlayerController.selectedSearchMethod2.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            CommonIconButton(
              image: AppImage.check,
              onTap: () async {
                await editPlayerController.playerUpdateApi(
                    id: allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].userId ?? 0, index: index);
              },
            ),
            Gap(20),
          ],
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
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
                                return editPlayerController.image.value.path.isEmpty
                                    ? ((allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].profile ?? "").isNotEmpty)
                                        ? getImageView(
                                            finalUrl: ('${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].profile }'?? ""),
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            color: AppColor.grey6EColor,
                                            size: 125,
                                          )
                                    : Image.file(
                                        File(editPlayerController.image.value.path),
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      );
                              }),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            editPlayerController.showOptions(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(color: AppColor.black12Color, borderRadius: BorderRadius.circular(50)),
                            // margin: EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.edit,
                                color: AppColor.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Gap(24),
                  CommonTitleText(
                    text: "Player info",
                  ),
                  Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: "First name",
                          autofillHints: const [
                            AutofillHints.namePrefix,
                          ],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))],
                          controller: editPlayerController.fNameController.value,
                          keyboardType: TextInputType.name,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your first name";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Gap(16),
                      Expanded(
                        child: CommonTextField(
                          autofillHints: const [
                            AutofillHints.nameSuffix,
                          ],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))],
                          controller: editPlayerController.lNameController.value,
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
                      ),
                    ],
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Birthday",
                    readOnly: true,
                    controller: editPlayerController.birthdayController.value,
                    onTap: () {
                      editPlayerController.showYearPicker(context, 0, editPlayerController.birthdayController.value);
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your birth day date";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  SizedBox(
                    height: 45,
                    child: HorizontalSelectionList(
                      items: editPlayerController.selectedMethod2List,
                      selectedIndex: editPlayerController.selectedSearchMethod2,
                      controller: editPlayerController.controller2,
                      onItemSelected: (index) {
                        editPlayerController.selectedSearchMethod2.value = index;
                      },
                    ),
                  ),
                  Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: "Jersey number",
                          controller: editPlayerController.jNumberController.value,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your Jersey number";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Gap(16),
                      Expanded(
                        child: CommonTextField(
                          autofillHints: const [
                            AutofillHints.nameSuffix,
                          ],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[A-Za-z]{0,2}$')),
                          ],
                          controller: editPlayerController.positionController.value,
                          hintText: "Position",
                          keyboardType: TextInputType.name,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your position";
                            } else if (!RegExp(r'^[A-Za-z]{1,2}$').hasMatch(val!)) {
                              return "Enter one or two letters (e.g., L, LW, GK)";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(16),
                  Obx(() {
                    return CommonTextField(
                      controller: editPlayerController.allergyController.value,
                      hintText: "Allergy",
                      validator: (val) {
                        if ((val ?? "").isEmpty) {
                          return "Please enter Allergy";
                        } else {
                          return null;
                        }
                      },
                    );
                  }),
                  // Gap(16),
                  // Row(
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Manager access",
                  //           style: TextStyle().normal16w500.textColor(
                  //                 AppColor.black12Color,
                  //               ),
                  //         ),
                  //         Text(
                  //           "grant member manager rights",
                  //           style: TextStyle().normal14w500.textColor(
                  //                 AppColor.grey6EColor,
                  //               ),
                  //         ),
                  //       ],
                  //     ),
                  //     Spacer(),
                  //     Obx(
                  //       () => CupertinoSwitch(
                  //         value: editPlayerController.isAccess.value,
                  //         onChanged: (val) {
                  //           editPlayerController.isAccess.value = val ?? false;
                  //         },
                  //         activeTrackColor: AppColor.grey4EColor.withValues(
                  //           alpha: 0.5,
                  //         ),
                  //         thumbColor: AppColor.black12Color,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Gap(20),
                  // Row(
                  //   children: [
                  //     Text(
                  //       "Non - player",
                  //       style: TextStyle().normal16w500.textColor(
                  //             AppColor.black12Color,
                  //           ),
                  //     ),
                  //     Spacer(),
                  //     Obx(
                  //       () => CupertinoSwitch(
                  //         value: editPlayerController.isNonPlayer.value,
                  //         onChanged: (val) {
                  //           editPlayerController.isNonPlayer.value =
                  //               val ?? false;
                  //         },
                  //         activeTrackColor: AppColor.grey4EColor.withValues(
                  //           alpha: 0.5,
                  //         ),
                  //         thumbColor: AppColor.black12Color,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Gap(20),
                  CommonTitleText(
                    text: "Contact information",
                  ),
                  Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: "First name",
                          autofillHints: const [
                            AutofillHints.namePrefix,
                          ],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))],
                          controller: editPlayerController.cfNameController.value,
                          keyboardType: TextInputType.name,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your first name";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Gap(16),
                      Expanded(
                        child: CommonTextField(
                          autofillHints: const [
                            AutofillHints.nameSuffix,
                          ],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))],
                          controller: editPlayerController.clNameController.value,
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
                      ),
                    ],
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Email",
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    controller: editPlayerController.emailController.value,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your email address";
                      } else if (!(val ?? "").isEmail) {
                        return "Please enter your valid email address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Phone number",
                    autofillHints: const [
                      AutofillHints.telephoneNumber,
                    ],
                    controller: editPlayerController.numberController.value,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your phone number";
                      } else if (!(val ?? "").isPhoneNumber) {
                        return "Please enter your valid phone number";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    autofillHints: const [
                      AutofillHints.addressCityAndState,
                    ],
                    controller: editPlayerController.addressController.value,
                    hintText: "Address",
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    autofillHints: const [
                      AutofillHints.addressCity,
                    ],
                    controller: editPlayerController.cityController.value,
                    hintText: "City",
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your city";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          autofillHints: const [
                            AutofillHints.addressState,
                          ],
                          controller: editPlayerController.stateController.value,
                          hintText: "State",
                          keyboardType: TextInputType.name,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your state";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Gap(16),
                      Expanded(
                        child: CommonTextField(
                          controller: editPlayerController.zipController.value,
                          hintText: "Zip code",
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please enter your zip code";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
