import 'local_config.dart';

enum Environment { development, production }

class AppConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        // 개발 환경: local_config.dart의 IP 사용
        // local_config.dart는 .gitignore에 포함되어 GitHub에 올라가지 않음
        return LocalConfig.localServerUrl;
      case Environment.production:
        return 'https://yeti125.duckdns.org';
    }
  }

  static String get healthCheckUrl => '$baseUrl/api/health';
  static String get liveStatusUrl => '$baseUrl/api/stream/is-live';
  static String get notificationRegisterUrl =>
      '$baseUrl/api/notifications/register';

  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
}
