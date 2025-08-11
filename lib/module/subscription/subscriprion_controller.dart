import 'package:base_code/package/config_packages.dart';

class SubscriptionController extends GetxController {
  List<String> planList = [
    "Free plan",
    "Monthly plan",
    "Annual plan",
  ];

  RxInt selectedPlan = 0.obs;
  PageController controller = PageController();
  AutoScrollController autoScrollController = AutoScrollController();

  List<String> freeFeatureEList = [
    "Create & Manage Teams (Build your team and manage up to 11 players)",
    "Game & Event Scheduling (Plan and organize matches or events with ease)",
    "Live Game Updates (Set games to In Progress, update scores and status in real-time)",
    "Private Chat (Communicate one-on-one or with the whole team)",
    "Challenges & Rewards (Create and delete challenges for players, View who participated and who completed them)"
  ];

  List<String> proFeatureMonthlyList = [
    "Get your first month FREE cancel anytime",
    "Subscription Duration: 1 Month",
    "Everything in the Free Plan, plus:",
    "Unlimited Roster Size (Add as many players as you need — no limits)",
    "Email RSVP (Automatically send email notifications when you schedule a game or event)",
    "Group & Private Chat (Communicate one-on-one or with the whole team)",
    "Advanced Scheduling with Family Calendar (Families can view all their kids' events in one unified calendar, making it easy to stay organized)",
    "Priority support",
  ];

  List<String> proFeatureAnnualList = [
    "Get your first 3 months FREE, cancel anytime",
    "Subscription Duration: 1 Year",
    "Everything in the Free Plan, plus:",
    "Unlimited Roster Size (Add as many players as you need — no limits)",
    "Email RSVP (Automatically send email notifications when you schedule a game or event)",
    "Group & Private Chat (Communicate one-on-one or with the whole team)",
    "Advanced Scheduling with Family Calendar (Families can view all their kids' events in one unified calendar, making it easy to stay organized)",
    "Priority support",
    "Save more with annual billing",
  ];
}
