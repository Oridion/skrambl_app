import 'package:flutter/foundation.dart';

class SelectedWalletProvider extends ChangeNotifier {
  String? _primary;
  String? _current;
  int? _currentBurnerIndex;

  void setPrimary(String pubkey) {
    final changed = _primary != pubkey || _current == null;
    _primary = pubkey;
    _current ??= pubkey;
    _currentBurnerIndex = null;
    if (changed) notifyListeners();
  }

  void selectPrimary() {
    if (_current != _primary || _currentBurnerIndex != null) {
      _current = _primary;
      _currentBurnerIndex = null;
      notifyListeners();
    }
  }

  void selectBurner(String pubkey, int index) {
    if (_current != pubkey || _currentBurnerIndex != index) {
      _current = pubkey;
      _currentBurnerIndex = index;
      notifyListeners();
    }
  }

  String? get pubkey => _current;
  bool get isBurner => _currentBurnerIndex != null;
  int? get burnerIndex => _currentBurnerIndex;
}
