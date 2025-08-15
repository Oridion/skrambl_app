import 'package:solana/solana.dart';

class SolanaClientService {
  static final SolanaClientService _instance = SolanaClientService._internal();

  factory SolanaClientService() => _instance;

  late final RpcClient rpcClient;

  SolanaClientService._internal() {
    const rpcUrl = 'https://bernette-tb3sav-fast-mainnet.helius-rpc.com'; // or devnet
    rpcClient = RpcClient(rpcUrl);
  }
}
