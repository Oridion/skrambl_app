import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class SolPriceService {
  SolPriceService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // simple in-memory cache
  static double? _cachedUsd;
  static DateTime? _cachedAt;

  /// Fetch SOL price in USD.
  /// Returns `null` on failure (so your UI can hide USD).
  Future<double?> fetch({Duration cacheTtl = const Duration(seconds: 45)}) async {
    // serve from cache if fresh
    if (_cachedUsd != null && _cachedAt != null && DateTime.now().difference(_cachedAt!) < cacheTtl) {
      return _cachedUsd;
    }

    const uri = 'https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd';

    // retry up to 3x on transient errors
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final resp = await _client
            .get(
              Uri.parse(uri),
              headers: {'Accept': 'application/json', 'User-Agent': 'skrambl-app/1.0 (+https://example.com)'},
            )
            .timeout(const Duration(seconds: 5));

        if (resp.statusCode != 200) {
          // Retry only on 429/5xx
          if (resp.statusCode == 429 || (resp.statusCode >= 500 && resp.statusCode < 600)) {
            await _backoff(attempt);
            continue;
          }
          // Non-retryable
          throw Exception('HTTP ${resp.statusCode}');
        }

        if (resp.body.isEmpty) throw Exception('Empty body');

        final data = jsonDecode(resp.body);
        final num? v = (data is Map) ? (data['solana'] is Map ? data['solana']['usd'] as num? : null) : null;

        if (v == null) throw Exception('Missing solana.usd');

        final price = v.toDouble();
        if (price <= 0 || !price.isFinite) throw Exception('Bad value: $price');

        // cache & return
        _cachedUsd = price;
        _cachedAt = DateTime.now();
        return price;
      } catch (e) {
        // retry loop continues for allowed cases; otherwise falls through
        await _backoff(attempt);
      }
    }

    // on failure: return cached (stale) value if present, else null
    return _cachedUsd;
  }

  Future<void> _backoff(int attempt) async {
    // capped exponential backoff with jitter
    final baseMs = math.min(1500 * (1 << (attempt - 1)), 6000);
    final jitter = math.Random().nextInt(400); // 0–399ms
    await Future.delayed(Duration(milliseconds: baseMs + jitter));
  }
}

// Future<double> fetchSolPriceUsd() async {
//   skrLogger.i("[PRICE] Fetching");
//   try {
//     final response = await http.get(
//       Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd'),
//     );
//     final json = jsonDecode(response.body);
//     return (json['solana']['usd'] as num).toDouble();
//   } catch (e) {
//     skrLogger.e('Failed to fetch SOL price: $e');
//     return 0;
//   }
// }

// Future<String> getSOLUSDPriceDisplay(double sol) async {
//   // Handle null/negative gracefully
//   if (sol <= 0) return '\$0.00';

//   try {
//     final solUsdPrice = await fetchSolPriceUsd(); // Expected: double USD price per SOL
//     if (solUsdPrice <= 0) return '\$0.00';

//     final v = sol * solUsdPrice;

//     // Choose precision:
//     // - 0 decimals if >= $100
//     // - 2 decimals if >= $1
//     // - 4 decimals for small values (< $1)
//     String formatted;
//     if (v >= 100) {
//       formatted = v.toStringAsFixed(0);
//     } else if (v >= 1) {
//       formatted = v.toStringAsFixed(2);
//     } else {
//       formatted = v.toStringAsFixed(4);
//     }

//     return '\$$formatted';
//   } catch (e) {
//     // Optional: log error
//     skrLogger.e('Failed to fetch SOL price: $e');
//     return '\$0.00';
//   }
// }
