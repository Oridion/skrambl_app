import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/models/launch_pod_request.dart';
import 'package:skrambl_app/utils/logger.dart';

class LaunchPodResponse {
  final String base64Tx;
  final String message;
  final String destinationPlanet;

  LaunchPodResponse({required this.base64Tx, required this.message, required this.destinationPlanet});

  factory LaunchPodResponse.fromJson(Map<String, dynamic> json) {
    return LaunchPodResponse(
      base64Tx: json['base64_tx'],
      message: json['message'],
      destinationPlanet: json['destination_planet'],
    );
  }
}

Future<String> fetchUnsignedLaunchTx(LaunchPodRequest payload) async {
  const apiUrl = 'https://api.oridion.xyz/pod/launch/build';
  const apiKey = 'JFrtLEpxty8DHjNJPhMCn52wHzPs91Nt9kzhBF6n';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json', 'x-api-key': apiKey},
    body: jsonEncode(payload.toJson()),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    //skrLogger.i(json);
    return json['base64'] as String;
  } else {
    throw Exception('LaunchPod failed: ${response.statusCode}\n${response.body}');
  }
}
