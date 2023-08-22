class ServerConfig {
  static const Map<String, dynamic> servers = {
    'iceServers': [
      {
        'url': 'turn:turn.i2-host.com:3478',
        'username': 'saritest',
        'credential': 'test546321'
      }
    ]
  };

  static const Map<String, dynamic> constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };
}
