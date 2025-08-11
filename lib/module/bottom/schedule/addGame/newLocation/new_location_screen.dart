import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NewLocationScreen extends StatelessWidget {
  NewLocationScreen({super.key});

  final newLocationController = Get.put<NewLocationController>(NewLocationController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: CommonTitleText(text: "Location"),
          centerTitle: false,
          actions: [
            CommonIconButton(
              image: AppImage.check,
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  await newLocationController.addLocationApiCall();
                }
              },
            ),
            Gap(20),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Gap(16),
                  CommonTextField(
                    hintText: "Enter a location name (Central Park, New York)",
                    keyboardType: TextInputType.text,
                    autofillHints: const [
                      AutofillHints.location,
                    ],
                    inputFormatters: [
                      CapitalizedTextFormatter()
                    ],
                    controller: newLocationController.locationController,
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter your location";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Street name, city, and ZIP code",
                    keyboardType: TextInputType.text,
                    autofillHints: const [
                      AutofillHints.addressCityAndState,
                    ],
                    inputFormatters: [
                      CapitalizedTextFormatter()
                    ],
                    controller: newLocationController.addressController,
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
                    hintText: "Google Maps link",
                    controller: newLocationController.linkController,
                    validator: (val) {
                    //   if ((val ?? "").isEmpty) {
                    //     return "Please enter your address link";
                    //   } else {
                    //     return null;
                    //   }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Any additional details (e.g., landmark, parking info)",
                    maxLine: 3,
                    controller: newLocationController.notesController,
                    keyboardType: TextInputType.text, 
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    // validator: (val) {
                    //   if ((val ?? "").isEmpty) {
                    //     return "Please enter note";
                    //   } else {
                    //     return null;
                    //   }
                    // },
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
