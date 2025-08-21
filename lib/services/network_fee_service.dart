// services/network_fee_service.dart
import 'package:skrambl_app/utils/solana.dart';

class NetworkFeeService {
  Future<int> fetchFee() async => await getNetworkFee();
}
