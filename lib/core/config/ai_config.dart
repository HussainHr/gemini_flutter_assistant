class AiConfig {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String model = 'gemini-3.8-flash';

  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
}
