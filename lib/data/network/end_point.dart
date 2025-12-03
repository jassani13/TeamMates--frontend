class ApiEndPoint {
  static const String register = "/api/signUp";
  static const String logIn = "/api/login";
  static const String checkUser = "/api/checkUserExistsOrNot";

  static const String updateProfile = "/api/updateProfile";
  static const String createTeam = "/api/createTeam";
  static const String addMemberToTeam = "/api/addMemberToTeam";
  static const String getRosterList = "/api/getRosterList";
  static const String deleteActivity = "/api/deleteActivity";
  static const String getRosterDetails = "/api/getRosterDetails";
  static const String getTeamPlayers = "/api/getTeamPlayers";
  static const String createActivity = "/api/createActivity";
  static const String updateActivity = "/api/updateActivity";
  static const String deleteAccount = "/api/deleteAccount";
  static const String createOpponent = "/api/createOpponent";
  static const String getOpponentList = "/api/getOpponentList";
  static const String getLocationList = "/api/getLocationList";
  static const String createLocation = "/api/createLocation";
  static const String getScheduleList = "/api/getScheduleList";
  static const String getActivityDetails = "/api/getActivityDetails";
  static const String createChallenge = "/api/createChallenge";
  static const String getChallengeList = "/api/getChallengeList";
  static const String getChallengeDetails = "/api/getChallengeDetails";
  static const String removeChallenge = "/api/removeChallenge";
  static const String removeMemberFromTeam = "/api/removeMemberFromTeam";
  static const String removeTeam = "/api/removeTeam";
  static const String getScoreList = "/api/getScoreList";
  static const String createScore = "/api/createScore";
  static const String setChallengeStatus = "/api/setChallengeStatus";
  static const String setActivityStatus = "/api/setActivityStatus";
  static const String sendRsvpNudge = "/api/sendRsvpNudge";
  static const String profileDetails = "/api/profileDetails";
  static const String homeDetails = "/api/homeDetails";
  static const String checkPlayerCode = "/api/checkPlayerCode";
  static const String getNotificationList = "/api/getNotificationList";
  static const String setChatMedia = "/api/setChatMedia";
  static const String getMyCoachDetails = "/api/getMyCoachDetails";
  static const String forgotPassword = "/api/forgotPassword";
  static const String updatePassword = "/api/updatePassword";
  static const String setWebCalLink = "/api/setWebCalLink";
  static const String getWebCalList = "/api/getWebCalList";
  static const String removeWebCalList = "/api/removeWebCalList";
  static const String setTransaction = "/api/setTransaction";
  static const String getTransactionList = "/api/getTransactionList";
  // tag management endpoints
  static const String getEventTags = "/api/getEventTags";
  static const String createEventTag = "/api/createEventTag";
  static const String updateEventTag = "/api/updateEventTag";
  static const String deleteEventTag = "/api/deleteEventTag";
  // chat module endpoints
  static const String createPersonalChat = "/api/chat/createPersonal";
  static const String createTeamChat = "/api/chat/createTeam";
  static const String createGroupChat = "/api/chat/createGroup";
  static const String getGroupMembers = "/api/chat/getGroupMembers";
  static const String updateGroup = "/api/chat/updateGroup";
  static const String removeGroupMember = "/api/chat/removeGroupMember";
  static const String addGroupMembers = "/api/chat/addGroupMembers";
  static const String readReceiptsPrivacy = "/api/user/read_receipts_privacy";

  // threaded replies endpoints
  static const String sendThreadReply = "/api/chat/sendThreadReply";
  static const String getThreadReplies = "/api/chat/getThreadReplies";
  static const String getThreadPreviews = "/api/chat/getThreadPreviews";
}
