import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CreateChallengeScreen extends StatelessWidget {
  CreateChallengeScreen({super.key});

  final createChallengeController = Get.put(CreateChallengeController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(16),
                _buildNotifyToggle(),
                const Gap(24),
                const CommonTitleText(text: "Challenge Info"),
                const Gap(16),
                _buildChallengeNameField(context),
                const Gap(16),
                _buildDescriptionField(context),
                const Gap(16),
                _buildTimeField(
                  hint: "Start Time",
                  controller: createChallengeController.startTimeController.value,
                ),
                const Gap(16),
                _buildTimeField(
                  hint: "End Time",
                  controller: createChallengeController.endTimeController.value,
                  isEndTime: true,
                ),
                const Gap(16),
                _buildNotesField(),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const CommonTitleText(text: "Create a Challenge"),
      centerTitle: false,
      actions: [
        CommonIconButton(
          image: AppImage.check,
          onTap: () {
            if (formKey.currentState!.validate()) {
              createChallengeController.addChallengeApi();
            }
          },
        ),
        const Gap(20),
      ],
    );
  }

  Widget _buildNotifyToggle() {
    return GestureDetector(
      onTap: () => createChallengeController.isNotify.toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.black12Color,
        ),
        child: Row(
          children: [
            Text("Notify Team", style: const TextStyle().normal16w500.textColor(AppColor.white)),
            const Spacer(),
            Obx(() => Checkbox(
                  value: createChallengeController.isNotify.value,
                  onChanged: (val) => createChallengeController.isNotify.value = val ?? false,
                  checkColor: AppColor.black12Color,
                  activeColor: AppColor.white,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: AppColor.white, width: 2),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeNameField(BuildContext context) {
    return CommonTextField(
      focusNode: createChallengeController.nameFocus,
      controller: createChallengeController.cNameController,
      hintText: "Challenge Name",
      inputFormatters: [CapitalizedTextFormatter()],
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(createChallengeController.descFocus),
      validator: (val) => (val ?? "").isEmpty ? "Please enter challenge name" : null,
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return CommonTextField(
      focusNode: createChallengeController.descFocus,
      controller: createChallengeController.cDescriptionController,
      hintText: "Challenge Description",
      maxLine: 4,
      inputFormatters: [CapitalizedTextFormatter()],
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(createChallengeController.notesFocus),
      validator: (val) => (val ?? "").isEmpty ? "Please enter challenge description" : null,
    );
  }

  Widget _buildTimeField({required String hint, required TextEditingController controller, bool isEndTime = false}) {
    return CommonTextField(
      hintText: hint,
      readOnly: true,
      controller: controller,
      suffixIcon: const Icon(Icons.keyboard_arrow_down_sharp, color: AppColor.black12Color),
      onTap: () {
        FocusScope.of(Get.context!).unfocus();
        showTimePicker(Get.context!, controller);
      },
      validator: (val) {
        if ((val ?? "").isEmpty) return "Please select $hint".toLowerCase();
        if (isEndTime) {
          final start = DateUtilities.parseDateTime(createChallengeController.startTimeController.value.text);
          final end = DateUtilities.parseDateTime(controller.text);
          if (start != null && end != null) {
            if (start.isAtSameMomentAs(end)) return "Start and end time must not be the same";
            if (end.isBefore(start)) return "End time must be after start time";
          }
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return CommonTextField(
      focusNode: createChallengeController.notesFocus,
      controller: createChallengeController.notesController,
      hintText: "Notes",
      maxLine: 4,
      inputFormatters: [CapitalizedTextFormatter()],
      textInputAction: TextInputAction.done,
    );
  }

  void showTimePicker(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 280,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Select Time", style: const TextStyle().normal14w500.textColor(AppColor.black12Color)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (controller.text.isEmpty) {
                          final now = DateTime.now();
                          controller.text = _formatDateTime(now);
                        }
                        Get.back();
                      },
                      child: Text("Done", style: const TextStyle().normal14w500.textColor(AppColor.black12Color)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 210,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData().copyWith(
                      textTheme: const CupertinoTextThemeData().copyWith(
                        dateTimePickerTextStyle: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateTime.now(),
                      use24hFormat: false,
                      minimumDate: DateTime.now().subtract(const Duration(seconds: 2)),
                      maximumDate: DateTime.now().add(const Duration(days: 366)),
                      onDateTimeChanged: (value) => controller.text = _formatDateTime(value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:00";
  }
}
