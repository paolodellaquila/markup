import 'package:flutter_app/utils/repository/firebase_remote_config_repository.dart';

class RemoteConfigManager {
  /// Remote Config Key
  static const MIN_APP_VERSION_KEY = "minAppVersion";
  static const MIN_BUILD_NUMBER_KEY = "minBuildNumber";
  static const APPSTORE_URL = "appStoreUrl";
  static const PLAYSTORE_URL = "playStoreUrl";
  static const CHATBOT_URL = "chatbotUrl";
  static const INTERNATIONAL_PRICING_RATE_URL = "internationalPricingRate";

  static RemoteConfigManager? _instance;

  RemoteConfigManager._();

  static RemoteConfigManager get instance {
    _instance ??= RemoteConfigManager._();
    return _instance!;
  }

  final FirebaseRemoteConfigRepository _remoteConfigRepository = FirebaseRemoteConfigRepository();

  String get appRemoteVersion {
    final response = _remoteConfigRepository.getString(MIN_APP_VERSION_KEY);
    return response;
  }

  int get appRemoteBuildNumber {
    final response = _remoteConfigRepository.getInt(MIN_BUILD_NUMBER_KEY);
    return response;
  }

  String get appStoreUrl {
    final response = _remoteConfigRepository.getString(APPSTORE_URL);
    return response;
  }

  String get playStoreUrl {
    final response = _remoteConfigRepository.getString(PLAYSTORE_URL);
    return response;
  }

  String get chatbotUrl {
    final response = _remoteConfigRepository.getString(CHATBOT_URL);
    return response;
  }

  double get internationalPricingRate {
    final response = _remoteConfigRepository.getDouble(INTERNATIONAL_PRICING_RATE_URL);
    return response;
  }

  /// Methods
  Future<bool> init() async => _remoteConfigRepository.initialize(defaultParameters: {
        MIN_APP_VERSION_KEY: '0.0.1',
        MIN_BUILD_NUMBER_KEY: 1,
        APPSTORE_URL: 'https://apps.apple.com/app/markup-italia/id6538726254',
        PLAYSTORE_URL: 'https://play.google.com/store/search?q=Markup%20Italia&c=apps&hl=it',
        CHATBOT_URL: 'https://www.chatbase.co/chatbot-iframe/7zG7v5Fke8hpwjD5_8sBD',
        INTERNATIONAL_PRICING_RATE_URL: 1.1525,
      });
}
