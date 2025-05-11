import 'package:base_code/components/common_progress_bar.dart';
import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CommonStatCard extends StatelessWidget {
  Challenge challenge;
  bool isCoach;
  int index;
  double? pWidth;

  CommonStatCard(
      {super.key,
      required this.isCoach,
      required this.challenge,
      required this.index,
      this.pWidth});

  @override
  Widget build(BuildContext context) {
    return isCoach == true
        ? Container(
            margin: EdgeInsets.only(top: index == 0 ? 0 : 16),
            decoration: BoxDecoration(
              color: AppColor.greyF6Color,
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            padding: EdgeInsets.all(
              16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 12,
                      decoration: BoxDecoration(
                        color: (challenge.timeStatus ?? "").toLowerCase() ==
                                "expired"
                            ? AppColor.redColor
                            : AppColor.successColor,
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                    ),
                    Gap(8),
                    Text(
                      challenge.timeStatus ?? "",
                      style: TextStyle().normal16w500.textColor(
                            (challenge.timeStatus ?? "").toLowerCase() ==
                                    "expired"
                                ? AppColor.redColor
                                : AppColor.successColor,
                          ),
                    ),
                  ],
                ),
                Gap(16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.name ?? "",
                        style: TextStyle().normal14w500.textColor(
                              AppColor.black12Color,
                            ),
                      ),
                      Gap(16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Icon(
                              Icons.calendar_month,
                              color: AppColor.black12Color,
                            ),
                          ),
                          Gap(16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${DateUtilities.formatDate(challenge.startAt ?? "", dateFormat: "MMM dd, yyyy")} - ${DateUtilities.formatDate(challenge.endAt ?? "", dateFormat: "MMM dd, yyyy")}",
                                style: TextStyle().normal14w500.textColor(
                                      AppColor.black12Color,
                                    ),
                              ),
                              Text(
                                "${DateUtilities.formatDate(challenge.startAt ?? "", dateFormat: DateUtilities.hh_mm_a)} - ${DateUtilities.formatDate(challenge.endAt ?? "", dateFormat: DateUtilities.hh_mm_a)}",
                                style: TextStyle().normal16w500.textColor(
                                      AppColor.black12Color,
                                    ),
                              ),
                              Text(
                                "${challenge.attendancePercentage ?? ""}% attendance",
                                style: TextStyle().normal14w500.textColor(
                                      AppColor.grey4EColor,
                                    ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Gap(16),
                      Row(
                        children: [
                          Text(
                            "Participants completed",
                            style: TextStyle().normal16w500.textColor(
                                  AppColor.black12Color,
                                ),
                          ),
                          Spacer(),
                          Text(
                            challenge.participateCount ?? "",
                            style: TextStyle().normal16w500.textColor(
                                  AppColor.black12Color,
                                ),
                          ),
                        ],
                      ),
                      Gap(14),
                      CommonProgressBar(
                          value: ((challenge.participateCount ?? "0/3")
                                      .split('/')
                                      .map(double.parse)
                                      .reduce((a, b) => a / b) *
                                  100)
                              .toString(),
                          width:
                              pWidth ?? MediaQuery.of(context).size.width - 96),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: EdgeInsets.only(top: index == 0 ? 0 : 16),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                padding: EdgeInsets.all(
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name ?? "",
                            style: TextStyle().normal16w500.textColor(
                                  AppColor.black12Color,
                                ),
                          ),
                          Text(
                            challenge.description ?? "",
                            style: TextStyle().normal14w500.textColor(
                                  AppColor.grey4EColor,
                                ),
                          ),
                          Text(
                            challenge.participateStatus ?? "Incomplete",
                            style: TextStyle().normal14w500.textColor(
                              challenge.participateStatus?.toLowerCase() == "completed"
                                  ? AppColor.success500
                                  : challenge.participateStatus?.toLowerCase() == "participate"
                                  ? AppColor.primaryColor
                                  : AppColor.grey4EColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Gap(16),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: index == 0 ? 0 : 16),
                decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 0),
                          blurRadius: 0.3,
                          color: AppColor.black12Color.withValues(alpha: 0.48),
                          spreadRadius: -1)
                    ]),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Text(
                  DateUtilities.getTimeLeft(challenge.endAt ?? "-"),
                  style: TextStyle().normal16w500.textColor(
                        AppColor.redColor,
                      ),
                ),
              ),
            ],
          );
  }
}
