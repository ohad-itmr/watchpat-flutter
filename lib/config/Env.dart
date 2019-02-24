enum EnvType { DEVELOPMENT, STAGING, PRODUCTION, TESTING }

class Env {

  static String appName = "MyPAT";
  static String baseUrl = 'https://api.dev.website.org';
  static EnvType environmentType=EnvType.DEVELOPMENT;

}
