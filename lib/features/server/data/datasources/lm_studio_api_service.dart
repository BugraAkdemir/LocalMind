import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../chat/data/models/message_model.dart';
import '../models/server_profile_model.dart';

final lmStudioApiProvider = Provider<LMStudioApiService>((ref) {
  return LMStudioApiService();
});

class LMStudioApiService {
  final Dio _dio;

  LMStudioApiService()
      : _dio = Dio(BaseOptions(
          connectTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ));

  /// Tests the connection to the LM Studio server and returns the available models
  Future<List<Map<String, dynamic>>> testConnection(
      ServerProfileModel server) async {
    try {
      final response = await _dio.get(
        ApiConstants.modelsEndpoint(server.host, server.port),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final modelsList = data['data'] as List<dynamic>?;
        if (modelsList != null) {
          return List<Map<String, dynamic>>.from(modelsList);
        }
      }
      throw Exception('Invalid response format from server');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches the list of available models from the server
  Future<List<Map<String, dynamic>>> getModels(
      ServerProfileModel server) async {
    return testConnection(server);
  }

  /// Sends a chat completion request with streaming enabled
  Stream<String> streamChatCompletion({
    required ServerProfileModel server,
    required String modelId,
    required List<MessageModel> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = -1,
    double topP = 1.0,
  }) async* {
    final List<Map<String, dynamic>> apiMessages = [];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      apiMessages.add({'role': 'system', 'content': systemPrompt});
    }

    apiMessages.addAll(messages.map((m) => m.toApiMessage()));

    final requestBody = {
      'model': modelId,
      'messages': apiMessages,
      'temperature': temperature,
      'top_p': topP,
      'max_tokens': maxTokens,
      'stream': true,
    };

    try {
      final response = await _dio.post(
        ApiConstants.chatCompletionsEndpoint(server.host, server.port),
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: ApiConstants.streamTimeout,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;

      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final dataStr = line.substring(6);
            if (dataStr.trim().isEmpty) continue;
            
            try {
              final data = jsonDecode(dataStr);
              final choices = data['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices.first['delta'] as Map<String, dynamic>?;
                if (delta != null && delta.containsKey('content')) {
                  final content = delta['content'] as String?;
                  if (content != null) {
                    yield content;
                  }
                }
              }
            } catch (e) {
              // Ignore parse errors for partial chunks
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timed out. Please check if LM Studio is running.');
        case DioExceptionType.connectionError:
          return Exception('Cannot connect to the server. Check your IP and Port.');
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 400) {
            return Exception('Connection OK, but NO MODEL IS LOADED. Please load a model in LM Studio first.');
          }
          return Exception('Server returned an error: ${error.response?.statusCode}');
        default:
          return Exception('Network error occurred: ${error.message}');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}
