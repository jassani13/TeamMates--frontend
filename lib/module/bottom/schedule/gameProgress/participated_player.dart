import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ParticipatedPlayer extends StatelessWidget {
  ParticipatedPlayer({super.key});

  List<PlayerTeams> list = Get.arguments;
  final controller = Get.put<Controller>(Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(text: "Player list"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Gap(16),
          Container(
            height: 63,
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.greyF6Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: HorizontalSelectionList(
              items: controller.selectedMethod1List,
              selectedIndex: controller.selectedSearchMethod1,
              controller: controller.controller1,
              onItemSelected: (index) async {
                controller.selectedSearchMethod1.value = index;
                controller.filteredList?.value = list.where((player) {
                  String status = player.activityUserStatus ?? "-";
                  return status ==
                      controller.selectedMethod1List[
                      controller.selectedSearchMethod1.value];
                }).toList();
              },
            ),
          ),
          Expanded(
              child: Obx(() {
                return  (controller.filteredList??[]).isEmpty?
                    Center(child: buildNoData(text: "No player found"))
                    :ListView.builder(
                  itemCount: controller.filteredList?.length,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(bottom: 14, top: 14),
                      decoration: BoxDecoration(
                        border: index == 0
                            ? null
                            : Border(
                          top: BorderSide(
                            color: AppColor.greyF6Color,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: getImageView(
                              finalUrl: controller.filteredList?[index]
                                  .profile ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Gap(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${controller.filteredList?[index].firstName ??
                                    ""} ${controller.filteredList?[index]
                                    .lastName ?? ""}",
                                style: TextStyle()
                                    .normal20w500
                                    .textColor(AppColor.black12Color),
                              ),
                              Text(
                                controller.filteredList?[index]
                                    .activityUserStatus ??
                                    "-",
                                style: TextStyle()
                                    .normal14w500
                                    .textColor(AppColor.black12Color),
                              ),
                              if ((controller.filteredList?[index]
                                  .jerseyNumber ?? "")
                                  .isNotEmpty ||
                                  (controller.filteredList?[index].position ??
                                      "")
                                      .isNotEmpty)
                                RichText(
                                  text: TextSpan(children: [
                                    if ((controller
                                        .filteredList?[index].jerseyNumber ??
                                        "")
                                        .isNotEmpty)
                                      TextSpan(
                                        text:
                                        "#${controller.filteredList?[index]
                                            .jerseyNumber ?? ""}",
                                        style: TextStyle()
                                            .normal14w500
                                            .textColor(AppColor.grey4EColor),
                                      ),
                                    if ((controller.filteredList?[index]
                                        .position ??
                                        "")
                                        .isNotEmpty)
                                      TextSpan(
                                        text:
                                        " - ${controller.filteredList?[index]
                                            .position ?? ""}",
                                        style: TextStyle()
                                            .normal14w500
                                            .textColor(AppColor.grey4EColor),
                                      ),
                                  ]),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              })),
        ],
      ),
    );
  }
}

class Controller extends GetxController {
  AutoScrollController controller1 = AutoScrollController();
  RxInt selectedSearchMethod1 = (0).obs;
  RxList<ShortedData> sortedScheduleList = <ShortedData>[].obs;
  List selectedMethod1List = [
    "Going",
    "Maybe",
    "No",
  ];
  RxList<PlayerTeams>? filteredList = <PlayerTeams>[].obs;
  List<PlayerTeams> list = Get.arguments;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    filteredList?.value = list.where((player) {
      String status = player.activityUserStatus ?? "-";
      return status ==
          selectedMethod1List[
          selectedSearchMethod1.value];
    }).toList();
  }
}
