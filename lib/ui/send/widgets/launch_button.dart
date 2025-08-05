// import 'package:flutter/material.dart';
// import 'package:skrambl_app/api/launch_pod_service.dart';
// import 'package:skrambl_app/models/launch_pod_request.dart';

// class LaunchPodButton extends StatefulWidget {
//   final LaunchPodRequest request;
//   final VoidCallback onSuccess;
//   final void Function(String error)? onError;

//   const LaunchPodButton({
//     super.key,
//     required this.request,
//     required this.onSuccess,
//     this.onError,
//   });

//   @override
//   State<LaunchPodButton> createState() => _LaunchPodButtonState();
// }

// class _LaunchPodButtonState extends State<LaunchPodButton> {
//   bool _loading = false;

//   Future<void> _handleLaunch() async {
//     setState(() => _loading = true);
//     try {
//       final response = await fetchUnsignedLaunchTx(widget.request);
//       // TODO: Integrate signing and submission using SeedVault or your preferred signing method
//       debugPrint('Unsigned tx: ${response.base64Tx}');
//       debugPrint('Destination planet: ${response.destinationPlanet}');

//       widget.onSuccess();
//     } catch (e) {
//       widget.onError?.call(e.toString());
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _loading ? null : _handleLaunch,
//         child: _loading
//             ? const CircularProgressIndicator(color: Colors.white)
//             : const Text('Slide to Send'),
//       ),
//     );
//   }
// }
