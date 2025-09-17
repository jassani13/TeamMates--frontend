import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ParticipatedPlayer extends StatelessWidget {
  ParticipatedPlayer({super.key});

  final List<PlayerTeams> list = Get.arguments;
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
                    final player = controller.filteredList?[index];
                    final hasNote = (player?.activityUserNote ?? "").isNotEmpty;
                    
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: getImageView(
                                  finalUrl: player?.profile ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${player?.firstName ?? ""} ${player?.lastName ?? ""}",
                                      style: TextStyle()
                                          .normal20w500
                                          .textColor(AppColor.black12Color),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          player?.activityUserStatus ?? "-",
                                          style: TextStyle()
                                              .normal14w500
                                              .textColor(AppColor.black12Color),
                                        ),
                                        // NEW: Show note indicator if note exists
                                        if (hasNote) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColor.greyF6Color,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.note_alt_outlined, 
                                                  size: 12, 
                                                  color: AppColor.grey6EColor
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  "Note",
                                                  style: TextStyle()
                                                      .normal12w400
                                                      .textColor(AppColor.grey6EColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if ((player?.jerseyNumber ?? "").isNotEmpty ||
                                        (player?.position ?? "").isNotEmpty)
                                      RichText(
                                        text: TextSpan(children: [
                                          if ((player?.jerseyNumber ?? "").isNotEmpty)
                                            TextSpan(
                                              text: "#${player?.jerseyNumber ?? ""}",
                                              style: TextStyle()
                                                  .normal14w500
                                                  .textColor(AppColor.grey4EColor),
                                            ),
                                          if ((player?.position ?? "").isNotEmpty)
                                            TextSpan(
                                              text: " - ${player?.position ?? ""}",
                                              style: TextStyle()
                                                  .normal14w500
                                                  .textColor(AppColor.grey4EColor),
                                            ),
                                        ]),
                                      ),
                                  ],
                                ),
                              ),
                              // NEW: Show note icon if note exists
                              if (hasNote)
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColor.grey6EColor,
                                  size: 20,
                                ),
                            ],
                          ),
                          // NEW: Expandable note section (only for coaches and only if note exists)
                          if (hasNote && AppPref().role == "coach") ...[
                            SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.greyEAColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.note_alt_outlined, 
                                        size: 16, 
                                        color: AppColor.grey6EColor
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Player's Note:",
                                        style: TextStyle()
                                            .normal12w500
                                            .textColor(AppColor.grey6EColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    player?.activityUserNote ?? "",
                                    style: TextStyle()
                                        .normal14w400
                                        .textColor(AppColor.black12Color),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

// EXISTING CONTROLLER CLASS - Keep exactly as it was
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