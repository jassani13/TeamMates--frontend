import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CommonScheduleCard extends StatefulWidget {
  final ScheduleData? scheduleData;
  final bool? isBtn;
  final bool? isHome;

  CommonScheduleCard({
    super.key,
    this.scheduleData,
    this.isBtn,
    this.isHome,
  });

  @override
  State<CommonScheduleCard> createState() => _CommonScheduleCardState();
}

class _CommonScheduleCardState extends State<CommonScheduleCard> {
  AutoScrollController controller1 = AutoScrollController();
  RxInt selectedSearchMethod1 = (-1).obs;
  List selectedMethod1List = [
    "Going",
    "Maybe",
    "No",
  ];

  // NEW: Controllers for RSVP note
  final TextEditingController rsvpNoteController = TextEditingController();
  final RxBool showNoteInput = false.obs;
  final RxString currentNote = ''.obs;

  @override
  void initState() {
    super.initState();
    selectedSearchMethod1.value = selectedMethod1List.indexWhere(
        (e) => e == (widget.scheduleData?.activityUserStatus ?? ""));

    // Initialize note if exists
    currentNote.value = widget.scheduleData?.activityUserNote ?? '';
    rsvpNoteController.text = currentNote.value;
  }

  @override
  void dispose() {
    rsvpNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.greyF6Color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... existing content (keep all your current widgets) ...
              if (widget.scheduleData?.isTimeTbd == 1)
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Practice".toUpperCase(),
                            style: TextStyle().normal14w600.textColor(
                                  AppColor.greenColor,
                                ),
                          )
                        ],
                      ),
                    ),
                    Gap(4),
                  ],
                ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: capitalizeFirst(widget.scheduleData?.activityName),
                      style: TextStyle().normal16w500.textColor(
                            AppColor.black12Color,
                          ),
                    ),
                  ],
                ),
              ),
              if (widget.scheduleData?.startTime != null ||
                  widget.scheduleData?.endTime != null)
                Text(
                  DateUtilities.formatTime(widget.scheduleData?.startTime ?? "",
                      widget.scheduleData?.endTime ?? ""),
                  style: TextStyle().normal16w500.textColor(
                        AppColor.black12Color,
                      ),
                ),
              Visibility(
                visible: widget.scheduleData?.activityType == 'game',
                child: Text(
                  "${widget.scheduleData?.team?.name ?? ""} vs ${widget.scheduleData?.opponent?.opponentName ?? ""}",
                  style: TextStyle().normal14w500.textColor(
                        AppColor.black12Color,
                      ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.scheduleData?.location?.address ?? "",
                      style: TextStyle().normal15w500.textColor(
                            AppColor.black12Color,
                          ),
                    ),
                    if (AppPref().role != "family" &&
                        widget.scheduleData?.totalParticipate != 0)
                      TextSpan(
                        text:
                            " (${widget.scheduleData?.totalParticipate ?? ""} total participants)",
                        style: TextStyle().normal14w500.textColor(
                              AppColor.black12Color,
                            ),
                      )
                  ],
                ),
              ),

              // EXISTING RSVP BUTTONS - Enhanced with note functionality
              if (widget.isBtn == true) ...[
                SizedBox(height: 12),
                Center(
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: HorizontalSelectionList(
                        margin: MediaQuery.of(context).size.width / 9,
                        items: selectedMethod1List,
                        selectedIndex: selectedSearchMethod1,
                        controller: controller1,
                        onItemSelected: (index) async {
                          selectedSearchMethod1.value = index;
                          widget.scheduleData?.activityUserStatus =
                              selectedMethod1List[index];

                          // NEW: Show note input after selection
                          showNoteInput.value = true;

                          // Call existing API with note (backward compatible)
                          await _updateRsvpWithNote(selectedMethod1List[index]);
                        },
                      ),
                    ),
                  ),
                ),

                // NEW: RSVP Note Input (shows after selection)
                Obx(() => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: showNoteInput.value ? null : 0,
                      child: showNoteInput.value
                          ? Column(
                              children: [
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: AppColor.greyEAColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Add a note (optional)",
                                        style: TextStyle()
                                            .normal14w500
                                            .textColor(AppColor.grey6EColor),
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        controller: rsvpNoteController,
                                        maxLines: 2,
                                        maxLength: 100,
                                        decoration: InputDecoration(
                                          hintText:
                                              "e.g., Will be 15 minutes late, Only available for first half",
                                          hintStyle: TextStyle()
                                              .normal14w400
                                              .textColor(AppColor.grey6EColor),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: AppColor.greyEAColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: AppColor.greyEAColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: AppColor.black12Color),
                                          ),
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        style: TextStyle()
                                            .normal14w400
                                            .textColor(AppColor.black12Color),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              showNoteInput.value = false;
                                              rsvpNoteController.clear();
                                            },
                                            child: Text(
                                              "Skip",
                                              style: TextStyle()
                                                  .normal14w500
                                                  .textColor(
                                                      AppColor.grey6EColor),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              currentNote.value =
                                                  rsvpNoteController.text
                                                      .trim();
                                              widget.scheduleData
                                                      ?.activityUserNote =
                                                  currentNote.value;
                                              showNoteInput.value = false;

                                              // Update RSVP with note
                                              await _updateRsvpWithNote(widget
                                                      .scheduleData
                                                      ?.activityUserStatus ??
                                                  '');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColor.black12Color,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              "Save",
                                              style: TextStyle()
                                                  .normal14w500
                                                  .textColor(AppColor.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    )),

                // NEW: Show current note if exists
                Obx(() => currentNote.value.isNotEmpty
                    ? Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColor.greyEAColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note_alt_outlined,
                                size: 16, color: AppColor.grey6EColor),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                currentNote.value,
                                style: TextStyle()
                                    .normal12w400
                                    .textColor(AppColor.grey6EColor),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                rsvpNoteController.text = currentNote.value;
                                showNoteInput.value = true;
                              },
                              child: Icon(Icons.edit,
                                  size: 16, color: AppColor.grey6EColor),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink()),
              ],

              // ... rest of your existing widgets (WATCH button, etc.) ...
              Visibility(
                visible: widget.scheduleData?.activityType == 'game' &&
                    widget.scheduleData?.isLive == 1,
                child: GestureDetector(
                  onTap: () {
                    launchURL('https://watch.livebarn.com/en/signin');
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColor.greyEAColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap(6),
                        Text(
                          "WATCH",
                          style: TextStyle().normal12w500.textColor(
                                AppColor.redColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            (widget.scheduleData?.isLive == 1)
                ? 'Live - ${capitalizeFirst(widget.scheduleData?.activityType)}'
                : capitalizeFirst(widget.scheduleData?.activityType),
            style: TextStyle().normal16w500.textColor(
                  (widget.scheduleData?.isLive == 1 ||
                          widget.scheduleData?.activityType?.toLowerCase() ==
                              'game')
                      ? AppColor.redColor
                      : AppColor.black12Color,
                ),
          ),
        ),
      ],
    );
  }

  // NEW: Enhanced RSVP method with note support (backward compatible)
  Future<void> _updateRsvpWithNote(String status) async {
    try {
      // Use your existing method with the new optional parameter
      await Get.find<ScheduleController>().statusChangeApiCall(
        status: status,
        aId: widget.scheduleData?.activityId ?? 0,
        isHome: widget.isHome ?? false,
        rsvpNote: rsvpNoteController.text.trim().isNotEmpty
            ? rsvpNoteController.text.trim()
            : null, // Only send note if not empty
      );
    } catch (e) {
      AppToast.showAppToast("Failed to update RSVP. Please try again.");
    }
  }
}
