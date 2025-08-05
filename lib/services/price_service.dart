import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:skrambl_app/utils/logger.dart';

Future<double> fetchSolPriceUsd() async {
  try {
    final response = await http.get(
      Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd',
      ),
    );
    final json = jsonDecode(response.body);
    return (json['solana']['usd'] as num).toDouble();
  } catch (e) {
    skrLogger.e('[SKRAMBL] Failed to fetch SOL price: $e');
    return 0;
  }
}
