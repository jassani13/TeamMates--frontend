import 'package:base_code/module/auth/forgot_password/forgot_password_screen.dart';
import 'package:base_code/module/auth/otp/otp_screen.dart';
import 'package:base_code/module/bottom/chat/group_chat/group_chat_screen.dart';
import 'package:base_code/module/bottom/chat/personalChat/personal_chat_screen.dart';
import 'package:base_code/module/bottom/chat/search_chat/search_chat_screen.dart';
import 'package:base_code/module/bottom/schedule/calendar/calendar_screen.dart';
import 'package:base_code/module/bottom/schedule/schedule_screen.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import 'module/bottom/roster/addNonPlayer/add_non_player_screen.dart';

class AppRouter {
  static const addNonPlayer = '/add-staff';
  static const splash = '/splash';
  static const login = '/login';
  static const selectRole = '/selectRole';
  static const creatingTeam = '/creatingTeam';
  static const teamCode = '/teamCode';
  static const bottom = '/bottom';
  static const onBoarding = '/onBoarding';
  static const subscription = '/subscription';
  static const account = '/account';
  static const support = '/support';
  static const terms = '/terms';
  static const profile = '/profile';
  static const playOverview = '/playOverview';
  static const editPlayer = '/editPlayer';
  static const personalChat = '/personalChat';
  static const addTeam = '/addTeam';
  static const addPlayer = '/addPlayer';
  static const allPlayer = '/allPlayer';
  static const addGame = '/addGame';
  static const newOpponent = '/newOpponent';
  static const newLocation = '/newLocation';
  static const volunteerAssignments = '/volunteerAssignments';
  static const challengeMembers = '/challengeMembers';
  static const createChallenge = '/createChallenge';
  static const gameProgress = '/gameProgress';
  static const notification = '/notification';
  static const liveScore = '/liveScore';
  static const participatedPlayer = '/participatedPlayer';
  static const schedule = '/schedule';
  static const grpChat = '/grp_chat';
  static const otp = '/otp';
  static const forgotPassword = '/forgot_password';
  static const calendar = '/calendar';
  static const searchChatScreen = '/searchChatScreen';

  static List<GetPage> getPages = [
    GetPage(name: addNonPlayer, page: () => AddNonPlayerScreen()),
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: selectRole, page: () => SelectRoleScreen()),
    GetPage(name: creatingTeam, page: () => CreatingTeamScreen()),
    GetPage(name: teamCode, page: () => TeamCodeScreen()),
    GetPage(name: bottom, page: () => BottomScreen()),
    GetPage(name: onBoarding, page: () => OnBoardingScreen()),
    GetPage(name: subscription, page: () => SubscriptionScreen()),
    GetPage(name: account, page: () => AccountScreen()),
    GetPage(name: support, page: () => SupportScreen()),
    GetPage(name: terms, page: () => TermsScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: playOverview, page: () => PlayOverviewScreen()),
    GetPage(name: editPlayer, page: () => EditPlayerScreen()),
    GetPage(name: addTeam, page: () => AddTeamScreen()),
    GetPage(name: addPlayer, page: () => AddPlayerScreen()),
    GetPage(name: allPlayer, page: () => AllPlayerScreen()),
    GetPage(name: addGame, page: () => AddGameScreen()),
    GetPage(name: newOpponent, page: () => NewOpponentScreen()),
    GetPage(name: newLocation, page: () => NewLocationScreen()),
    GetPage(name: volunteerAssignments, page: () => VolunteerAssignmentsScreen()),
    GetPage(name: challengeMembers, page: () => ChallengeMembersScreen()),
    GetPage(name: createChallenge, page: () => CreateChallengeScreen()),
    GetPage(name: gameProgress, page: () => GameProgressScreen()),
    GetPage(name: notification, page: () => NotificationScreen()),
    GetPage(name: liveScore, page: () => LiveScoreScreen()),
    GetPage(name: participatedPlayer, page: () => ParticipatedPlayer()),
    GetPage(name: schedule, page: () => ScheduleScreen()),
    GetPage(name: personalChat, page: () => PersonalChatScreen()),
    GetPage(name: grpChat, page: () => GroupChatScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: calendar, page: () => CalendarScreen()),
    GetPage(name: searchChatScreen, page: () => SearchChatScreen()),
  ];
}
