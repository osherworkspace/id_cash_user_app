import 'dart:convert';
import 'package:http/http.dart' as http;

/// All live requests go only to ID-CASH's server. Never embed Twilio secrets.
class IdcashApi {
  IdcashApi({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}$path');

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 20));
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const IdcashApiException('Server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IdcashApiException(decoded['error']?.toString() ?? 'Request failed.');
    }
    return decoded;
  }

  Future<void> requestOtp(String phone) async {
    await _post('/api/auth/otp/request', {'phoneNumber': phone});
  }

  Future<void> verifyOtp(String phone, String code) async {
    await _post('/api/auth/otp/verify', {'phoneNumber': phone, 'code': code});
  }

  Future<Map<String, dynamic>> register(String phone, String passcode) =>
      _post('/api/auth/register', {'phoneNumber': phone, 'loginPasscode': passcode});

  Future<Map<String, dynamic>> login(String identifier, String passcode) =>
      _post('/api/auth/login', {'identifier': identifier, 'passcode': passcode});

  void close() => _client.close();
}

class IdcashApiException implements Exception {
  const IdcashApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
