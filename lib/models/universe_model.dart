import 'package:solana_borsh/borsh.dart';
import 'package:solana_borsh/codecs.dart';
import 'package:solana_borsh/models.dart';
import 'package:solana_borsh/types.dart';

//https://pub.dev/documentation/solana_borsh/latest/index.html

class Universe extends BorshObject {
  Universe({
    required this.accountType,
    required this.locked,
    required this.bump,
    required this.created,
    required this.lastUpdated,
    required this.fee,
    required this.increment,
  });

  final int accountType;
  final int locked;
  final int bump;
  final int created;
  final int lastUpdated;
  final BigInt fee;
  final BigInt increment;

  /// ✅ Static version for deserialization
  static BorshSchema get staticSchema => {
    'accountType': borsh.u8,
    'locked': borsh.u8,
    'bump': borsh.u8,
    'created': borsh.i64,
    'lastUpdated': borsh.i64,
    'fee': borsh.u64,
    'increment': borsh.u64,
  };

  /// ✅ Instance override to satisfy BorshObject
  @override
  BorshSchema get borshSchema => Universe.staticSchema;

  static BorshStructCodec get borshCodec => BorshStructCodec({
    'accountType': borsh.u8,
    'locked': borsh.u8,
    'bump': borsh.u8,
    'created': borsh.i64,
    'lastUpdated': borsh.i64,
    'fee': borsh.u64,
    'increment': borsh.u64,
  });

  @override
  factory Universe.fromJson(final Map<String, dynamic> json) => Universe(
    accountType: json['accountType'],
    locked: json['locked'],
    bump: json['bump'],
    created: json['created'],
    lastUpdated: json['lastUpdated'],
    fee: json['fee'],
    increment: json['increment'],
  );

  @override
  Map<String, dynamic> toJson() => {
    'accountType': accountType,
    'locked': locked,
    'bump': bump,
    'created': created,
    'lastUpdated': lastUpdated,
    'fee': fee,
    'increment': increment,
  };
}
