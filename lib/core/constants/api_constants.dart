class ApiConstants {
  ApiConstants._();

  static const defaultPort = 1234;
  static const defaultHost = '192.168.1.100';

  static String baseUrl(String host, int port) => 'http://$host:$port';
  static String modelsEndpoint(String host, int port) =>
      '${baseUrl(host, port)}/v1/models';
  static String chatCompletionsEndpoint(String host, int port) =>
      '${baseUrl(host, port)}/v1/chat/completions';

  static const connectionTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 120);
  static const streamTimeout = Duration(seconds: 300);
}
