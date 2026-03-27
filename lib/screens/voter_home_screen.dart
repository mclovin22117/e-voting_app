import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/candidate.dart';
import '../models/network_status.dart';
import '../models/transaction_state.dart';
import '../services/blockchain_service.dart';
import '../widgets/transaction_status_card.dart';

class VoterHomeScreen extends StatefulWidget {
  const VoterHomeScreen({
    super.key,
    required this.blockchainService,
    required this.authController,
  });

  static const routeName = '/voter';

  final BlockchainService blockchainService;
  final AuthController authController;

  @override
  State<VoterHomeScreen> createState() => _VoterHomeScreenState();
}

class _VoterHomeScreenState extends State<VoterHomeScreen> {
  List<Candidate> _candidates = const [];
  bool _isLoading = true;
  bool _isSubmittingVote = false;
  String? _error;
  NetworkStatus? _networkStatus;
  TransactionState _transactionState = const TransactionState.idle();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.blockchainService.getCandidates(),
        widget.blockchainService.getNetworkStatus(),
      ]);

      final candidates = results[0] as List<Candidate>;
      final networkStatus = results[1] as NetworkStatus;

      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _networkStatus = networkStatus;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _vote(int candidateId) async {
    setState(() {
      _isSubmittingVote = true;
      _transactionState = const TransactionState.pending();
    });

    try {
      final txHash = await widget.blockchainService.castVote(candidateId);
      if (!mounted) return;
      setState(() {
        _transactionState = TransactionState.success(txHash);
      });
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _transactionState = TransactionState.error(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingVote = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_networkStatus != null && !_networkStatus!.isMatch)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'Network mismatch: expected chain ${_networkStatus!.expectedChainId}, '
                  'connected chain ${_networkStatus!.currentChainId}.',
                ),
              ),
            TransactionStatusCard(state: _transactionState),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load candidates:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_candidates.isEmpty) {
      return const Center(child: Text('No candidates available yet.'));
    }

    return ListView.builder(
      itemCount: _candidates.length,
      itemBuilder: (context, index) {
        final candidate = _candidates[index];
        return Card(
          child: ListTile(
            title: Text(candidate.name),
            subtitle: Text('Votes: ${candidate.voteCount}'),
            trailing: ElevatedButton.icon(
              onPressed: _isSubmittingVote ? null : () => _vote(candidate.id),
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Vote'),
            ),
          ),
        );
      },
    );
  }
}
