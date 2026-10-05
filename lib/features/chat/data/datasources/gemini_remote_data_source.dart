import 'package:dio/dio.dart';
import '../../../../core/config/ai_config.dart';

class GeminiRemoteDataSource {
  final Dio _dio;

  GeminiRemoteDataSource(this._dio);

  Future<String> generateResponse(String prompt) async {
    if (AiConfig.apiKey.isEmpty) {
      throw Exception('Gemini API key is missing.');
    }

    try {
      final response = await _dio.post(
        '${AiConfig.baseUrl}/models/'
        '${AiConfig.model}:generateContent',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': AiConfig.apiKey,
          },
        ),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        },
      );

      final candidates = response.data['candidates'] as List?;

      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini returned no response.');
      }

      final parts =
          candidates.first['content']?['parts'] as List?;

      final text = parts
          ?.where((part) => part['text'] != null)
          .map((part) => part['text'].toString())
          .join('\n');

      if (text == null || text.isEmpty) {
        throw Exception('No text found in Gemini response.');
      }

      return text;
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'];
      throw Exception(
        message ?? e.message ?? 'Failed to connect to Gemini.',
      );
    }
  }
}