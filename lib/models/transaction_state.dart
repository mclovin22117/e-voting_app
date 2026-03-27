enum TransactionStage {
  idle,
  pending,
  success,
  error,
}

class TransactionState {
  const TransactionState({
    required this.stage,
    this.txHash,
    this.error,
  });

  const TransactionState.idle() : this(stage: TransactionStage.idle);

  const TransactionState.pending()
      : this(
          stage: TransactionStage.pending,
        );

  const TransactionState.success(String txHash)
      : this(
          stage: TransactionStage.success,
          txHash: txHash,
        );

  const TransactionState.error(String error)
      : this(
          stage: TransactionStage.error,
          error: error,
        );

  final TransactionStage stage;
  final String? txHash;
  final String? error;
}
