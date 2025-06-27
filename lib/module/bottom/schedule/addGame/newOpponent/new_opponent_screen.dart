import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NewOpponentScreen extends StatelessWidget {
  NewOpponentScreen({super.key});

  final newOpponentController = Get.put<NewOpponentController>(NewOpponentController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: CommonTitleText(text: "Opponent"),
          centerTitle: false,
          actions: [
            CommonIconButton(
              image: AppImage.check,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  newOpponentController.addOpponentApi();
                }
              },
            ),
            Gap(20),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Gap(16),
                  CommonTextField(
                    hintText: "Manchester United",
                    textCapitalization: TextCapitalization.sentences,
                    autofillHints: const [
                      AutofillHints.namePrefix,
                    ],
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[A-Za-z ]*$')),
                    ],
                    controller: newOpponentController.oNameController,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your opponent name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "John Doe",
                    autofillHints: const [
                      AutofillHints.namePrefix,
                    ],
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[A-Za-z ]*$')),
                    ],
                    controller: newOpponentController.cNameController,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      // if ((val ?? "").isEmpty) {
                      //   return "Please enter your contact name";
                      // } else {
                      //   return null;
                      // }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "+1 987 654 3210",
                    autofillHints: const [
                      AutofillHints.telephoneNumber,
                    ],
                    controller: newOpponentController.phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      // if ((val ?? "").isEmpty) {
                      //   return "Please enter phone number";
                      // } else if (!(val ?? "").isPhoneNumber) {
                      //   return "Please enter valid phone number";
                      // } else {
                      //   return null;
                      // }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "johndoe@gmail.com",
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    controller: newOpponentController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      // if ((val ?? "").isEmpty) {
                      //   return "Please enter email address";
                      // } else if (!(val ?? "").isEmail) {
                      //   return "Please enter valid email address";
                      // } else {
                      //   return null;
                      // }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Confirmed any details or remarks",
                    maxLine: 3,
                    textCapitalization: TextCapitalization.sentences,
                    controller: newOpponentController.notesController,
                    textInputAction: TextInputAction.done,
                  ),
                  Gap(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
