import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ScheduleScreen extends StatelessWidget {
  ScheduleScreen({super.key});

  final scheduleController = Get.put<ScheduleController>(ScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImage.bottomBg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          RefreshIndicator(
            key: scheduleController.refreshKey,
            onRefresh: () async {
              await scheduleController.getScheduleListApiCall(
                  filter: scheduleController.selectedMethod1List[scheduleController.selectedSearchMethod1.value]);
            },
            child: Column(
              children: [
                Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                Row(
                  children: [
                    Gap(16),
                    CommonTitleText(text: "Schedule"),
                    Spacer(),
                    CommonIconButton(
                      image: AppImage.calendar,
                      onTap: () {
                        Get.toNamed(AppRouter.calendar);
                      },
                    ),
                    Gap(16),
                    CommonIconButton(
                      image: AppImage.filter,
                      onTap: () async {
                        DateTimeRange? pickedRange = await showDateRangePicker(
                          context: Get.context!,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          initialDateRange: DateTimeRange(
                            start: DateTime.now(),
                            end: DateTime.now().add(Duration(days: 7)),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.white,
                                  onPrimary: Colors.black,
                                  surface: Colors.black,
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: Colors.black,
                                textTheme: TextTheme(),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedRange != null) {
                          DateTime startDate = pickedRange.start;
                          DateTime endDate = pickedRange.end;
                          scheduleController.selectedSearchMethod1.value = (-1);
                          await scheduleController.getScheduleListApiCall(
                            filter: null,
                            startDate: DateFormat('yyyy-MM-dd').format(startDate),
                            endDate: DateFormat('yyyy-MM-dd').format(endDate),
                          );
                        }
                      },
                    ),
                    Gap(16),
                    if (AppPref().role == 'coach') ...[
                      CommonIconButton(
                        image: AppImage.plus,
                        onTap: () {
                          showCommonBottomSheet(
                            context: context,
                            title: "Please select",
                            options: [
                              "Add New Game",
                              "Add New Event",
                            ],
                            onTapActions: [
                              () async {
                                Get.back();
                                final val = await Get.toNamed(AppRouter.addGame, arguments: {
                                  "activity": "game",
                                });
                                if (val != null) {
                                  scheduleController.selectedSearchMethod1.value = 0;
                                  await scheduleController.getScheduleListApiCall(filter: 'today');
                                }
                              },
                              () async {
                                Get.back();
                                final val = await Get.toNamed(AppRouter.addGame, arguments: {
                                  "activity": "event",
                                });
                                if (val != null) {
                                  scheduleController.selectedSearchMethod1.value = 0;
                                  await scheduleController.getScheduleListApiCall(filter: 'today');
                                }
                              },
                            ],
                          );
                        },
                      ),
                      Gap(16),
                    ],
                    if (AppPref().role == 'family') ...[
                      CommonIconButton(
                        image: AppImage.logOut,
                        onTap: () {
                          showAlertDialog(
                              context: context,
                              btn2Tap: () {
                                AppPref().clear();
                                AppPref().isFirstTime = true;
                                Get.toNamed(AppRouter.login);
                              });
                        },
                      ),
                      Gap(16),
                    ]
                  ],
                ),
                Gap(24),
                Container(
                  height: 63,
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    16,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.greyF6Color,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: HorizontalSelectionList(
                    items: scheduleController.selectedMethod1List,
                    selectedIndex: scheduleController.selectedSearchMethod1,
                    controller: scheduleController.controller1,
                    onItemSelected: (index) async {
                      scheduleController.selectedSearchMethod1.value = index;
                      await scheduleController.getScheduleListApiCall(
                          filter: scheduleController.selectedMethod1List[scheduleController.selectedSearchMethod1.value]);
                    },
                  ),
                ),
                Gap(24),
                Expanded(
                  child: Obx(
                    () => scheduleController.isLoading.value
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColor.black12Color,
                            ),
                          )
                        : scheduleController.sortedScheduleList.isEmpty
                            ? SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.3),
                                      child: Center(child: buildNoData(text: "No Data Found")),
                                    ),
                                  ],
                                ),
                              )
                            : Obx(() {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: scheduleController.sortedScheduleList.length,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      var item = scheduleController.sortedScheduleList[i].date;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                            width: double.infinity,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.black12Color),
                                            child: Text(
                                              item.isNotEmpty
                                                  ? DateFormat('EEEE, MMMM d, y').format(DateTime.parse(item))
                                                  : '',
                                              style: TextStyle().normal16w500.textColor(AppColor.white),
                                            ),
                                          ),
                                          buildListView(i)
                                        ],
                                      );
                                    });
                              }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListView buildListView(int i) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      physics: ScrollPhysics(),
      itemCount: scheduleController.sortedScheduleList[i].data.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        ScheduleData scheduleData = scheduleController.sortedScheduleList[i].data[index];
        return GestureDetector(
          onTap: () {
            Get.toNamed(AppRouter.gameProgress, arguments: {
              'user_id': scheduleData.userBy,
              'activity_id': scheduleData.activityId,
            });
          },
          child: CommonScheduleCard(
            scheduleData: scheduleData,
            isBtn: AppPref().role == 'team',
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 16);
      },
    );
  }
}

void showAlertDialog({
  required BuildContext context,
  String? title,
  subtitle,
  btn1Text,
  btn2Text,
  Function()? btn1Tap,
  Function()? btn2Tap,
  bool? isbtn2Show = true,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: Column(
          children: [
            Text(
              title ?? "Are you sure want to logout?",
              style: const TextStyle().normal16w600.textColor(
                    AppColor.black12Color,
                  ),
              textAlign: TextAlign.center,
            ),
            Visibility(
              visible: subtitle != null,
              child: Text(
                subtitle ?? "",
                style: const TextStyle().normal16w400.textColor(
                      AppColor.black12Color,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: CommonAppButton(
                  onTap: btn1Tap ?? () => Get.back(),
                  borderRadius: 4,
                  color: AppColor.white,
                  text: btn1Text ?? "Cancel",
                  textColor: AppColor.black12Color,
                  width: 100,
                  buttonType: ButtonType.enable,
                ),
              ),
              if (isbtn2Show == true) ...[
                const Gap(15),
                Center(
                  child: CommonAppButton(
                    onTap: btn2Tap,
                    borderRadius: 4,
                    color: AppColor.black12Color,
                    text: btn2Text ?? "Yes",
                    width: 100,
                    buttonType: ButtonType.enable,
                  ),
                ),
              ]
            ],
          )
        ],
      );
    },
  );
}
