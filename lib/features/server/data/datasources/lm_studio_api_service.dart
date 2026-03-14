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

  /// Lightweight reachability check.
  ///
  /// Note: A non-200 response (e.g. 400 "no model loaded") still means the server
  /// is reachable, so this returns `true` for any HTTP response.
  Future<bool> ping(ServerProfileModel server) async {
    try {
      await _dio.get(ApiConstants.modelsEndpoint(server.host, server.port));
      return true;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.badResponse) {
        return true;
      }
      return false;
    }
  }

  /// Fetches the list of available models from the server
  Future<List<Map<String, dynamic>>> getModels(
      ServerProfileModel server) async {
    return testConnection(server);
  }

  /// Sends a chat completion request with streaming enabled
  Stream<Map<String, dynamic>> streamChatCompletion({
    required ServerProfileModel server,
    required String modelId,
    required List<MessageModel> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = -1,
    double topP = 1.0,
    List<Map<String, dynamic>>? tools,
    CancelToken? cancelToken,
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
      if (tools != null && tools.isNotEmpty) 'tools': tools,
      if (tools != null && tools.isNotEmpty) 'tool_choice': 'auto',
    };

    try {
      final response = await _dio.post(
        ApiConstants.chatCompletionsEndpoint(server.host, server.port),
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: ApiConstants.streamTimeout,
        ),
        cancelToken: cancelToken,
      );

      final stream = response.data.stream as Stream<List<int>>;

      // SSE lines can be split across TCP frames/chunks; keep a carry buffer.
      var carry = '';
      await for (final chunk in stream) {
        carry += utf8.decode(chunk, allowMalformed: true);

        final parts = carry.split('\n');
        carry = parts.removeLast(); // keep last partial line (if any)

        for (final rawLine in parts) {
          final line = rawLine.trim();
          if (!line.startsWith('data:')) continue;

          final dataStr = line.substring('data:'.length).trim();
          if (dataStr.isEmpty) continue;
          if (dataStr == '[DONE]') continue;

          try {
            final data = jsonDecode(dataStr);
            final choices = data['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;

            final first = choices.first;
            if (first is! Map<String, dynamic>) continue;

            final delta = first['delta'];
            if (delta is Map<String, dynamic>) {
              yield delta;
            }
          } catch (_) {
            // Ignore malformed frames; the next line is likely to be valid JSON.
            continue;
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
