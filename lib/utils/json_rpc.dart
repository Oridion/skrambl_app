// lib/solana/json_rpc_raw.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/constants/app.dart';

class JsonRpcRaw {
  static int _id = 1;

  /// Call any JSON-RPC method against the same endpoint the SDK uses.
  static Future<dynamic> call(String method, {List<dynamic> params = const []}) async {
    final headers = const {'content-type': 'application/json'};

    final payload = {'jsonrpc': '2.0', 'id': _id++, 'method': method, 'params': params};

    final res = await http.post(
      Uri.parse(AppConstants.rawAPIURL),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('RPC ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body['error'] != null) {
      throw Exception('RPC error: ${body['error']}');
    }

    return body['result'];
  }
}
