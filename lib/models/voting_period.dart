class VotingPeriod {
  const VotingPeriod({
    required this.startUnix,
    required this.endUnix,
  });

  final int startUnix;
  final int endUnix;

  DateTime get startDateTime =>
      DateTime.fromMillisecondsSinceEpoch(startUnix * 1000, isUtc: true).toLocal();

  DateTime get endDateTime =>
      DateTime.fromMillisecondsSinceEpoch(endUnix * 1000, isUtc: true).toLocal();
}
