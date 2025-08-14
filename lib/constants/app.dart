import 'package:solana/solana.dart';

class AppConstants {
  // App version
  static const String appVersion = '1.0.0';

  // API base URL
  static const String apiBaseUrl = 'https://api.oridion.xyz/';

  // Raw API endpoint string
  static const String rawAPIURL = 'https://bernette-tb3sav-fast-mainnet.helius-rpc.com';

  static final rpcClient = RpcClient("https://bernette-tb3sav-fast-mainnet.helius-rpc.com");
}
