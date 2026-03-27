import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../config/app_config.dart';
import '../models/network_status.dart';
import '../models/transaction_state.dart';
import '../models/voting_period.dart';
import '../services/blockchain_service.dart';
import '../widgets/transaction_status_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.config,
    required this.blockchainService,
  });

  static const routeName = '/admin';

  final AppConfig config;
  final BlockchainService blockchainService;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _candidateController = TextEditingController();
  final _voterController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  bool _loading = true;
  String? _error;
  NetworkStatus? _networkStatus;
  EthereumAddress? _owner;
  bool _paused = false;
  VotingPeriod? _votingPeriod;
  TransactionState _txState = const TransactionState.idle();

  @override
  void initState() {
    super.initState();
    _loadAdminState();
  }

  @override
  void dispose() {
    _candidateController.dispose();
    _voterController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  bool get _networkMismatch =>
      _networkStatus != null && !_networkStatus!.isMatch;

  Future<void> _loadAdminState() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.blockchainService.getNetworkStatus(),
        widget.blockchainService.getOwnerAddress(),
        widget.blockchainService.isPaused(),
        widget.blockchainService.getVotingPeriod(),
      ]);

      if (!mounted) return;

      setState(() {
        _networkStatus = results[0] as NetworkStatus;
        _owner = results[1] as EthereumAddress;
        _paused = results[2] as bool;
        _votingPeriod = results[3] as VotingPeriod?;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _runAction(Future<String> Function() action) async {
    setState(() {
      _txState = const TransactionState.pending();
      _error = null;
    });

    try {
      final hash = await action();
      if (!mounted) return;

      setState(() {
        _txState = TransactionState.success(hash);
      });

      await _loadAdminState();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _txState = TransactionState.error(e.toString());
      });
    }
  }

  Future<void> _addCandidate() async {
    final candidateName = _candidateController.text.trim();
    if (candidateName.isEmpty) {
      setState(() {
        _error = 'Candidate name is required.';
      });
      return;
    }
    await _runAction(() => widget.blockchainService.addCandidate(candidateName));
    _candidateController.clear();
  }

  Future<void> _registerVoter() async {
    final voterAddress = _voterController.text.trim();
    if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(voterAddress)) {
      setState(() {
        _error = 'Enter a valid Ethereum address.';
      });
      return;
    }
    await _runAction(() => widget.blockchainService.registerVoter(voterAddress));
    _voterController.clear();
  }

  Future<void> _setVotingPeriod() async {
    final start = int.tryParse(_startController.text.trim());
    final end = int.tryParse(_endController.text.trim());

    if (start == null || end == null) {
      setState(() {
        _error = 'Start and end must be unix timestamps in seconds.';
      });
      return;
    }

    if (start >= end) {
      setState(() {
        _error = 'Start must be less than end.';
      });
      return;
    }

    await _runAction(
      () => widget.blockchainService.setVotingPeriod(
        startUnix: start,
        endUnix: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadAdminState,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        if (_networkMismatch)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Network mismatch: expected ${_networkStatus!.expectedChainId}, '
              'connected ${_networkStatus!.currentChainId}.',
            ),
          ),
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!),
          ),
        TransactionStatusCard(state: _txState),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contract Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Network: ${widget.config.network.name}'),
                Text('Chain ID: ${widget.config.chainId}'),
                Text('Owner: ${_owner?.hexEip55 ?? 'Unknown'}'),
                Text('Paused: ${_paused ? 'Yes' : 'No'}'),
                Text(
                  _votingPeriod == null
                      ? 'Voting Period: Not set'
                      : 'Voting Period: ${_votingPeriod!.startDateTime} -> ${_votingPeriod!.endDateTime}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Add Candidate',
          child: Column(
            children: [
              TextField(
                controller: _candidateController,
                decoration: const InputDecoration(
                  labelText: 'Candidate name',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _networkMismatch ? null : _addCandidate,
                  child: const Text('Add Candidate'),
                ),
              ),
            ],
          ),
        ),
        _buildActionCard(
          title: 'Register Voter',
          child: Column(
            children: [
              TextField(
                controller: _voterController,
                decoration: const InputDecoration(
                  labelText: 'Voter address',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _networkMismatch ? null : _registerVoter,
                  child: const Text('Register Voter'),
                ),
              ),
            ],
          ),
        ),
        _buildActionCard(
          title: 'Voting Period',
          child: Column(
            children: [
              TextField(
                controller: _startController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Start (unix seconds)',
                ),
              ),
              TextField(
                controller: _endController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'End (unix seconds)',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _networkMismatch ? null : _setVotingPeriod,
                  child: const Text('Set Voting Period'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _networkMismatch
                      ? null
                      : () => _runAction(widget.blockchainService.cancelVotingPeriod),
                  child: const Text('Cancel Voting Period'),
                ),
              ),
            ],
          ),
        ),
        _buildActionCard(
          title: 'Emergency Controls',
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _networkMismatch
                  ? null
                  : () => _runAction(
                        _paused
                            ? widget.blockchainService.unpauseContract
                            : widget.blockchainService.pauseContract,
                      ),
              child: Text(_paused ? 'Unpause Contract' : 'Pause Contract'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
