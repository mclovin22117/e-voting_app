class NetworkStatus {
  const NetworkStatus({
    required this.expectedChainId,
    required this.currentChainId,
  });

  final int expectedChainId;
  final int currentChainId;

  bool get isMatch => expectedChainId == currentChainId;
}
