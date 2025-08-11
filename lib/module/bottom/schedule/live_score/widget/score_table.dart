import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ScoreTableScreen extends StatefulWidget {
  const ScoreTableScreen({super.key, required this.teamAName, required this.teamBName, required this.onCheckClick});

  final String teamAName, teamBName;
  final Function(Map<String,dynamic>) onCheckClick;

  @override
  State<ScoreTableScreen> createState() => _ScoreTableScreenState();
}

class _ScoreTableScreenState extends State<ScoreTableScreen> {
  TextEditingController teamAScoreController = TextEditingController(text: "0");
  TextEditingController teamBScoreController = TextEditingController(text: "0");
  String selectedPeriod = "Final";

  List<String> scoreOptions = List.generate(300, (index) => (index + 1).toString());

  List<String> periodOptions = ["Final", "Pre", "1st", "2nd", "Half", "3rd", "4th", "Int", "ET", "PK", "OT", "SO"];
  String selectedValueType = "1";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: AppColor.gray200,),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    widget.teamAName,
                    textAlign: TextAlign.center,
                    style: TextStyle().normal18w500.textColor(AppColor.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Period",
                    textAlign: TextAlign.center,
                    style: TextStyle().normal18w500.textColor(AppColor.black),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.teamBName,
                    textAlign: TextAlign.center,
                    style: TextStyle().normal18w500.textColor(AppColor.black),
                  ),
                ),
              ],
            ),
            Gap(10),
            Container(
              color: AppColor.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        selectedValueType = "1";
                        setState(() {});
                      },
                      maxLines: 1,
                      style: TextStyle().normal20w600.textColor(selectedValueType == "1" ? AppColor.white : AppColor.black),
                      controller: teamAScoreController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: selectedValueType == "1" ? AppColor.black : AppColor.white,
                        filled: selectedValueType == "1" ? true : false,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        selectedValueType = "2";
                        setState(() {});
                      },
                      maxLines: 1,
                      readOnly: true,
                      style: TextStyle().normal20w600.textColor(selectedValueType == "2" ? AppColor.white : AppColor.black),
                      controller: TextEditingController(text: selectedPeriod),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: selectedValueType == "2" ? AppColor.black : AppColor.white,
                        filled: selectedValueType == "2" ? true : false,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        selectedValueType = "3";
                        setState(() {});
                      },
                      readOnly: true,
                      maxLines: 1,
                      style: TextStyle().normal20w600.textColor(selectedValueType == "3" ? AppColor.white : AppColor.black),
                      controller: teamBScoreController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: selectedValueType == "3" ? AppColor.black : AppColor.white,
                        filled: selectedValueType == "3" ? true : false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: selectedValueType == "1"
                      ? CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      teamAScoreController.text = scoreOptions[index];
                      setState(() {});
                    },
                    children: scoreOptions.map((e) => Center(child: Text(e))).toList(),
                  )
                      : selectedValueType == "2"
                      ? CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      selectedPeriod = periodOptions[index];
                      setState(() {});
                    },
                    children: periodOptions.map((e) => Center(child: Text(e))).toList(),
                  )
                      : CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      teamBScoreController.text = scoreOptions[index];
                      setState(() {});
                    },
                    children: scoreOptions.map((e) => Center(child: Text(e))).toList(),
                  ),
                ),
              ),
              Gap(20),
              GestureDetector(
                onTap: () {
                  widget.onCheckClick(
                      {
                        "teamA": widget.teamAName,
                        "teamB":  widget.teamBName,
                        "teamA_score": teamAScoreController.text,
                        "teamB_score": teamBScoreController.text,
                        "period": selectedPeriod,
                      }
                  );

                  setState(() {
                    teamAScoreController.text = "0";
                    teamBScoreController.text = "0";
                    selectedPeriod = "Final";
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColor.black, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: AppColor.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}