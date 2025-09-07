import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/models/land_book_model.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/dto.dart';

/// Emits callbacks while watching a LandBook PDA for a specific 16-byte ticket.
/// - onDelivering(): fired once when the ticket is first observed in the LandBook
/// - onFinalized(): fired once when the ticket is later removed (after having been seen)
class LandBookWatcher {
  final SolanaWsService ws;
  final Uint8List targetTicket; // exact 16 bytes from token_from(...)

  StreamSubscription? _sub;
  Timer? _poll;
  bool _finished = false;
  bool _sawTicket = false;

  LandBookWatcher({required this.ws, required this.targetTicket});

  Future<void> start({
    required void Function() onFinalized, // ticket removed (after seen)
    Duration pollEvery = const Duration(seconds: 12),
    String commitment = 'finalized',
  }) async {
    // 0) Initial snapshot to seed _sawTicket correctly
    try {
      final initial = await _snapshotHasTicket();
      if (initial) _sawTicket = true;
    } catch (_) {
      // ignore transient startup issues
    }

    // 1) WebSocket subscription (finalized)
    _sub = ws
        .accountSubscribe(AppConstants.landBookPDAString, commitment: commitment, encoding: 'base64')
        .listen((acct) async {
          if (_finished || acct == null) return;

          final has = _hasTicketFromWs(acct);
          if (has && !_sawTicket) {
            _sawTicket = true;
          } else if (!has && _sawTicket) {
            _finish();
            onFinalized();
          }
        }, cancelOnError: false);

    // 2) Poll fallback (defensive)
    _poll = Timer.periodic(pollEvery, (_) async {
      if (_finished) return;

      try {
        final has = await _snapshotHasTicket();
        if (has && !_sawTicket) {
          _sawTicket = true;
        } else if (!has && _sawTicket) {
          _finish();
          onFinalized();
        }
      } catch (_) {
        // ignore transient RPC/WS hiccups
      }
    });
  }

  // ---------- Helpers ----------

  Future<bool> _snapshotHasTicket() async {
    final rpc = AppConstants.rpcClient;
    final info = await rpc.getAccountInfo(AppConstants.landBookPDAString, encoding: Encoding.base64);
    if (info.value == null) {
      skrLogger.e("[LB Watcher] Error - Couldn't get land book");
      return false;
    }
    return _hasTicketFromRpc(info.value!);
  }

  bool _hasTicketFromWs(Map<String, dynamic> acct) {
    final data = acct['data'];
    String? b64;
    if (data is List && data.isNotEmpty && data.first is String) {
      b64 = data.first as String;
    } else if (data is String) {
      b64 = data;
    }
    if (b64 == null) return false;

    final raw = base64Decode(b64);
    final lb = LandBook.fromAccountData(raw);
    return lb.containsTicket(targetTicket);
  }

  bool _hasTicketFromRpc(Account acc) {
    final data = acc.data;

    // Case 1: Newer solana package: BinaryAccountData → raw bytes already provided
    if (data is BinaryAccountData) {
      final raw = Uint8List.fromList(data.data);
      final lb = LandBook.fromAccountData(raw);
      return lb.containsTicket(targetTicket);
    }

    skrLogger.e("[LB Watcher] Unknown format");
    return false;
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _sub?.cancel();
    _sub = null;
    _poll?.cancel();
    _poll = null;
  }

  void dispose() => _finish();
}
