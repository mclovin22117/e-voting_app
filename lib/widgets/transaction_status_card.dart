import 'package:flutter/material.dart';

import '../models/transaction_state.dart';

class TransactionStatusCard extends StatelessWidget {
  const TransactionStatusCard({
    super.key,
    required this.state,
  });

  final TransactionState state;

  @override
  Widget build(BuildContext context) {
    if (state.stage == TransactionStage.idle) {
      return const SizedBox.shrink();
    }

    Color background;
    String message;

    switch (state.stage) {
      case TransactionStage.pending:
        background = Colors.amber.shade50;
        message = 'Transaction pending. Please wait...';
        break;
      case TransactionStage.success:
        background = Colors.green.shade50;
        message = 'Transaction success: ${state.txHash}';
        break;
      case TransactionStage.error:
        background = Colors.red.shade50;
        message = 'Transaction failed: ${state.error}';
        break;
      case TransactionStage.idle:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(message),
    );
  }
}
