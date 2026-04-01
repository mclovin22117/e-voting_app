import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authController,
  });

  static const routeName = '/register';

  final AuthController authController;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1;
  bool _busy = false;
  String _note = '';

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vidController = TextEditingController();
  final _otpController = TextEditingController();

  static const _demoOtp = '123456';

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _vidController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _continueFromDummyOtpStep() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final vid = _vidController.text.trim();
    final otp = _otpController.text.trim();

    if (name.isEmpty || mobile.isEmpty || vid.isEmpty) {
      setState(() {
        _note = 'Enter name, mobile number, and voter ID.';
      });
      return;
    }

    if (otp != _demoOtp) {
      setState(() {
        _note = 'Invalid OTP. For demo, use 123456.';
      });
      return;
    }

    if (mobile.isEmpty || vid.isEmpty) {
      setState(() {
        _note = 'Mobile number and VID are required.';
      });
      return;
    }

    setState(() {
      _step = 2;
      _note = 'Step 1 complete (demo OTP verified). Proceed to MetaMask wallet connection.';
    });
  }

  Future<void> _connectWallet() async {
    setState(() {
      _busy = true;
      _note = 'Connecting wallet...';
    });

    try {
      final address = await widget.authController.connectWalletOnly();
      if (!mounted) return;

      if (address == null) {
        setState(() {
          _note = 'MetaMask connection unavailable. Configure wallet connection first.';
        });
        return;
      }

      setState(() {
        _note = 'Wallet connected: $address';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _note = 'Wallet connection failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _linkWallet() async {
    final address = widget.authController.connectedAccount;
    if (address == null) {
      setState(() {
        _note = 'Connect wallet first.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _note = 'Linking wallet to registration...';
    });

    try {
      await widget.authController.backendApiService.linkWallet(
        vid: _vidController.text.trim(),
        address: address,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _step = 3;
        _note = 'Registration successful. You can now login with your wallet.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _note = 'Wallet linking failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_step == 1) ...[
              const Text(
                'Step 1: VID + Mobile + OTP (Demo)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Demo mode: use OTP 123456.',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile No.'),
              ),
              TextField(
                controller: _vidController,
                decoration: const InputDecoration(labelText: 'Voter ID (VID)'),
              ),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'OTP (use 123456)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _continueFromDummyOtpStep,
                child: const Text('Continue to Step 2'),
              ),
            ],
            if (_step == 2) ...[
              const Text(
                'Step 2: Link MetaMask Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect and link the wallet you will use for voting.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _connectWallet,
                child: Text(
                  widget.authController.connectedAccount == null
                      ? 'Connect Wallet'
                      : 'Wallet Connected',
                ),
              ),
              if (widget.authController.connectedAccount != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.authController.connectedAccount!,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy || widget.authController.connectedAccount == null
                    ? null
                    : _linkWallet,
                child: const Text('Link Wallet'),
              ),
            ],
            if (_step == 3) ...[
              const Text(
                'Registration Complete',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registration successful. You may now login with your wallet to vote.',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go to Login'),
              ),
            ],
            if (_note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_note),
            ],
          ],
        ),
      ),
    );
  }
}
