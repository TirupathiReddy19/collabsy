class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';

  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const otp = '/auth/otp';
  static const mfaChallenge = '/auth/mfa-challenge';
  static const checkEmail = '/auth/check-email';
  static const help = '/auth/help';
  static const completeProfile = '/auth/complete-profile';
  static const termsGate = '/auth/terms';
  static const suspended = '/auth/suspended';

  static const creatorDetails = '/creator/onboarding/details';
  static const creatorInstagramConnect = '/creator/onboarding/instagram';
  static const creatorVerificationPending = '/creator/onboarding/review';

  static const brandDetails = '/brand/onboarding/details';
  static const brandVerificationPending = '/brand/onboarding/review';

  static const creatorHome = '/creator/home';
  static const creatorCampaigns = '/creator/campaigns';
  static const creatorMessages = '/creator/messages';
  static const creatorProfile = '/creator/profile';
  static const creatorCampaignDetail = '/creator/campaigns/:campaignId';
  static String creatorCampaignDetailPath(String campaignId) =>
      '/creator/campaigns/$campaignId';

  static const brandHome = '/brand/home';
  static const brandCampaigns = '/brand/campaigns';
  static const brandDiscover = '/brand/discover';
  static const brandMessages = '/brand/messages';
  static const brandAccount = '/brand/account';
  static const createCampaign = '/brand/campaigns/create';
  static const brandCampaignDetail = '/brand/campaigns/:campaignId';
  static String brandCampaignDetailPath(String campaignId) =>
      '/brand/campaigns/$campaignId';
  static const creatorPublicProfile = '/brand/discover/:creatorId';
  static String creatorPublicProfilePath(String creatorId) =>
      '/brand/discover/$creatorId';
  static const brandPublicProfile = '/creator/brand/:brandId';
  static String brandPublicProfilePath(String brandId) =>
      '/creator/brand/$brandId';

  static const chatDetail = '/chat/:chatId';
  static String chatDetailPath(String chatId) => '/chat/$chatId';
  static const announcements = '/announcements';

  static const notifications = '/notifications';
  static const settings = '/settings';
  static const connectedAccounts = '/settings/connected-accounts';
  static const blockedAccounts = '/settings/blocked-accounts';
  static const support = '/support';
  static const supportHistory = '/support/history';
  static const supportChat = '/support/chat/:ticketId';
  static String supportChatPath(String ticketId) => '/support/chat/$ticketId';
}
