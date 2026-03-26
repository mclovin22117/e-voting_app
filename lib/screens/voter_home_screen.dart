import 'package:flutter/material.dart';

import '../models/candidate.dart';
import '../services/blockchain_service.dart';

class VoterHomeScreen extends StatefulWidget {
  const VoterHomeScreen({
    super.key,
    required this.blockchainService,
  });

  static const routeName = '/voter';

  final BlockchainService blockchainService;

  @override
  State<VoterHomeScreen> createState() => _VoterHomeScreenState();
}

class _VoterHomeScreenState extends State<VoterHomeScreen> {
  List<Candidate> _candidates = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidates = await widget.blockchainService.getCandidates();
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadCandidates,
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
            trailing: const Icon(Icons.how_to_vote),
          ),
        );
      },
    );
  }
}
