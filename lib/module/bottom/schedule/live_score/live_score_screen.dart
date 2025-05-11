import 'package:base_code/module/bottom/schedule/live_score/live_score_controller.dart';
import 'package:base_code/module/bottom/schedule/live_score/widget/score_table.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  final controller = Get.put<LiveScoreController>(LiveScoreController());

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        title: Obx(
          () => controller.latestScore.isEmpty?SizedBox(): Container(
            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
            decoration: BoxDecoration(
              color: AppColor.black12Color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: controller.latestScore.isNotEmpty
                ? Text(
                    textAlign: TextAlign.center,
                    "${controller.latestScore['teamA']} ${controller.latestScore['teamA_score']} - ${controller.latestScore['teamB_score']} ${controller.latestScore['teamB']}\n${controller.latestScore['period']}",
                    style: TextStyle().normal18w600.textColor(AppColor.white),
                  )
                : SizedBox(),
          ),
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            Gap(20),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemBuilder: (context, index) {
                  Map data = {};
                  if ((controller.scoreHistoryList[index].score ?? "").isNotEmpty) {
                    data = jsonDecode(controller.scoreHistoryList[index].score ?? "");
                  }
                  return Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColor.greyF6Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${data["teamA"]} : ${data["teamA_score"]}\n${data["teamB"]} : ${data["teamB_score"]}\nPeriod : ${data["period"]}",
                          style: TextStyle().normal16w500.textColor(AppColor.black),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: controller.scoreHistoryList.length,
              ),
            ),
            Visibility(
              visible: AppPref().role=='coach',
              child: Column(
                children: [
                  Gap(20),

                  ScoreTableScreen(
                    onCheckClick: (val) {
                      controller.createScore(score: val);
                      // scoreHistoryList.add(val);
                    },
                    teamAName: controller.activityDetails.value.team?.name ?? "",
                    teamBName: controller.activityDetails.value.opponent?.opponentName ?? "",
                  ),
                  Gap(20),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
