class LaunchPodRequest {
  final int id;
  final int lamports;
  final int delay;
  final String userWallet;
  final String destination;
  final String passcode;
  final String returnType;

  LaunchPodRequest({
    required this.id,
    required this.lamports,
    required this.delay,
    required this.userWallet,
    required this.destination,
    required this.passcode,
    required this.returnType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lamports': lamports,
    'delay': delay,
    'user_wallet': userWallet,
    'destination': destination,
    'passcode': passcode,
    'return_type': returnType,
  };
}
