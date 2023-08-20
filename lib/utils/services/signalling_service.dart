class SignallingService {
  SignallingService._();
  static final instance = SignallingService._();

  static const Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ] //TODO Change later
        // 'url': 'turn:turn.i2-host.com:3478',
        // 'username': 'saritest',
        // 'credential': 'test546321'
      }
    ]
  };
}
