import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_borsh/borsh.dart';
import 'package:solana_borsh/codecs.dart';
import 'package:solana_borsh/models.dart';
import 'package:solana_borsh/types.dart';

class ActivityEntry extends BorshObject {
  ActivityEntry({required this.action, required this.to, required this.time});

  final int action; // u8
  final List<int> to; // [u8;10] for the 10-char string
  final int time; // i64

  static BorshStructCodec get borshCodec => BorshStructCodec({
    'action': borsh.u8,
    'to': borsh.array(borsh.u8, 10), // [u8;10]
    'time': borsh.i64,
  });

  @override
  BorshSchema get borshSchema => borshCodec.schema;

  @override
  factory ActivityEntry.fromJson(Map<String, dynamic> json) =>
      ActivityEntry(action: json['action'], to: List<int>.from(json['to']), time: json['time']);

  @override
  Map<String, dynamic> toJson() => {'action': action, 'to': to, 'time': time};

  static ActivityEntry fromBuffer(List<int> data) {
    if (data.length != 19) {
      skrLogger.w('ActivityEntry.decode: expected 19 bytes, got ${data.length}');
    }
    final decoded = borshCodec.decode(data);
    return ActivityEntry.fromJson(decoded);
  }
}
