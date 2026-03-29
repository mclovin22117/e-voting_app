import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/candidate.dart';
import '../models/network_status.dart';
import '../models/transaction_state.dart';
import '../models/voting_period.dart';
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
  VotingPeriod? _votingPeriod;
  bool _isPaused = false;
  bool _isRegistered = false;
  bool _hasVoted = false;
  String? _lastVoteTxHash;
  String? _lastVoteCandidate;
  DateTime? _lastVoteAt;
  Timer? _liveRefreshTimer;
  TransactionState _transactionState = const TransactionState.idle();

  @override
  void initState() {
    super.initState();
    _loadData();
    _liveRefreshTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _refreshLiveData(),
    );
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final connectedAccount = widget.authController.connectedAccount;
      final results = await Future.wait([
        widget.blockchainService.getCandidates(),
        widget.blockchainService.getNetworkStatus(),
        widget.blockchainService.isPaused(),
        widget.blockchainService.getVotingPeriod(),
        if (connectedAccount != null)
          widget.blockchainService.isRegistered(connectedAccount)
        else
          Future.value(false),
        if (connectedAccount != null)
          widget.blockchainService.hasVoted(connectedAccount)
        else
          Future.value(false),
      ]);

      final candidates = results[0] as List<Candidate>;
      final networkStatus = results[1] as NetworkStatus;
      final isPaused = results[2] as bool;
      final votingPeriod = results[3] as VotingPeriod?;
      final isRegistered = results[4] as bool;
      final hasVoted = results[5] as bool;

      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _networkStatus = networkStatus;
        _isPaused = isPaused;
        _votingPeriod = votingPeriod;
        _isRegistered = isRegistered;
        _hasVoted = hasVoted;
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

  Future<void> _refreshLiveData() async {
    if (!mounted || _isSubmittingVote) {
      return;
    }

    try {
      final connectedAccount = widget.authController.connectedAccount;
      final results = await Future.wait([
        widget.blockchainService.getCandidates(),
        widget.blockchainService.isPaused(),
        widget.blockchainService.getVotingPeriod(),
        if (connectedAccount != null)
          widget.blockchainService.hasVoted(connectedAccount)
        else
          Future.value(false),
      ]);

      if (!mounted) return;
      setState(() {
        _candidates = results[0] as List<Candidate>;
        _isPaused = results[1] as bool;
        _votingPeriod = results[2] as VotingPeriod?;
        _hasVoted = results[3] as bool;
      });
    } catch (_) {
      // Ignore transient refresh errors and keep the last good snapshot.
    }
  }

  bool get _networkMismatch => _networkStatus != null && !_networkStatus!.isMatch;

  _VotingStatus get _votingStatus {
    final period = _votingPeriod;
    if (period == null) {
      return _VotingStatus.notSet;
    }

    final now = DateTime.now();
    if (now.isBefore(period.startDateTime)) {
      return _VotingStatus.upcoming;
    }
    if (now.isAfter(period.endDateTime)) {
      return _VotingStatus.ended;
    }
    return _VotingStatus.active;
  }

  String? get _voteBlockReason {
    if (_networkMismatch) {
      return 'Switch wallet network to chain ${_networkStatus!.expectedChainId}.';
    }
    if (widget.authController.connectedAccount == null) {
      return 'Connect a wallet before voting.';
    }
    if (!_isRegistered) {
      return 'This wallet is not a registered voter.';
    }
    if (_hasVoted) {
      return 'You have already voted in this election.';
    }
    if (_isPaused) {
      return 'Voting is currently paused by the admin.';
    }
    switch (_votingStatus) {
      case _VotingStatus.notSet:
        return 'Voting period is not configured yet.';
      case _VotingStatus.upcoming:
        return 'Voting has not started yet.';
      case _VotingStatus.ended:
        return 'Voting period has ended.';
      case _VotingStatus.active:
        return null;
    }
  }

  bool get _canVote => _voteBlockReason == null && !_isSubmittingVote;

  Future<void> _vote(int candidateId) async {
    if (!_canVote) {
      return;
    }

    final candidateName = _candidates.firstWhere((c) => c.id == candidateId).name;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Vote'),
            content: Text('Cast your vote for "$candidateName"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    setState(() {
      _isSubmittingVote = true;
      _transactionState = const TransactionState.pending();
    });

    try {
      final txHash = await widget.blockchainService.castVote(candidateId);
      if (!mounted) return;
      setState(() {
        _transactionState = TransactionState.success(txHash);
        _lastVoteTxHash = txHash;
        _lastVoteCandidate = candidateName;
        _lastVoteAt = DateTime.now();
        _hasVoted = true;
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
    if (!widget.authController.canAccessVoter()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Voter Dashboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Access denied. Connect an eligible voter wallet first.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Disconnect wallet',
            onPressed: () async {
              await widget.authController.disconnectWallet();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
          ),
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
            _buildStatusBanner(),
            TransactionStatusCard(state: _transactionState),
            if (_lastVoteTxHash != null) _buildReceiptShell(),
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
              onPressed: _canVote ? () => _vote(candidate.id) : null,
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Vote'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner() {
    final votingStatus = _votingStatus;

    Color color;
    String title;

    if (_isPaused) {
      color = Colors.red;
      title = 'Paused';
    } else {
      switch (votingStatus) {
        case _VotingStatus.notSet:
          color = Colors.grey;
          title = 'Voting Not Set';
          break;
        case _VotingStatus.upcoming:
          color = Colors.blue;
          title = 'Voting Upcoming';
          break;
        case _VotingStatus.active:
          color = Colors.green;
          title = 'Voting Active';
          break;
        case _VotingStatus.ended:
          color = Colors.brown;
          title = 'Voting Ended';
          break;
      }
    }

    final period = _votingPeriod;
    final periodText = period == null
        ? 'Admin has not configured a voting window yet.'
        : 'Window: ${period.startDateTime} to ${period.endDateTime}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(periodText),
          const SizedBox(height: 6),
          Text(_voteBlockReason ?? 'You are eligible to vote now.'),
        ],
      ),
    );
  }

  Widget _buildReceiptShell() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vote Receipt (Phase 3 Shell)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text('Candidate: ${_lastVoteCandidate ?? '-'}'),
          Text('Time: ${_lastVoteAt ?? '-'}'),
          Text('Tx Hash: ${_lastVoteTxHash ?? '-'}'),
          const Text('IPFS CID: Coming in Phase 5'),
        ],
      ),
    );
  }
}

enum _VotingStatus {
  notSet,
  upcoming,
  active,
  ended,
}
