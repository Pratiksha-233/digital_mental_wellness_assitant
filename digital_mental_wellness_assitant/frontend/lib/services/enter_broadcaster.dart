import 'dart:async';

/// Simple singleton broadcaster for global Enter key events.
class EnterBroadcaster {
  EnterBroadcaster._();

  static final EnterBroadcaster instance = EnterBroadcaster._();

  final StreamController<void> _ctrl = StreamController<void>.broadcast();

  Stream<void> get stream => _ctrl.stream;

  void emitEnter() => _ctrl.add(null);

  void dispose() {
    _ctrl.close();
  }
}
