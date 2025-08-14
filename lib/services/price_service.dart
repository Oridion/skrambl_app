import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:skrambl_app/utils/logger.dart';

Future<double> fetchSolPriceUsd() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd'),
    );
    final json = jsonDecode(response.body);
    return (json['solana']['usd'] as num).toDouble();
  } catch (e) {
    skrLogger.e('Failed to fetch SOL price: $e');
    return 0;
  }
}

Future<String> getSOLUSDPriceDisplay(double sol) async {
  // Handle null/negative gracefully
  if (sol <= 0) return '\$0.00';

  try {
    final solUsdPrice = await fetchSolPriceUsd(); // Expected: double USD price per SOL
    if (solUsdPrice <= 0) return '\$0.00';

    final v = sol * solUsdPrice;

    // Choose precision:
    // - 0 decimals if >= $100
    // - 2 decimals if >= $1
    // - 4 decimals for small values (< $1)
    String formatted;
    if (v >= 100) {
      formatted = v.toStringAsFixed(0);
    } else if (v >= 1) {
      formatted = v.toStringAsFixed(2);
    } else {
      formatted = v.toStringAsFixed(4);
    }

    return '\$$formatted';
  } catch (e) {
    // Optional: log error
    skrLogger.e('Failed to fetch SOL price: $e');
    return '\$0.00';
  }
}
