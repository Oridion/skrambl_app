import 'package:solana/solana.dart';

class SolanaClientService {
  static final SolanaClientService _instance = SolanaClientService._internal();

  factory SolanaClientService() => _instance;

  late final RpcClient rpcClient;

  SolanaClientService._internal() {
    const rpcUrl =
        'https://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4'; // or devnet
    rpcClient = RpcClient(rpcUrl);
  }
}
