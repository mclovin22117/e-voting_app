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

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _vidController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final vid = _vidController.text.trim();

    if (name.isEmpty || mobile.isEmpty || vid.isEmpty) {
      setState(() {
        _note = 'Enter name, mobile number, and voter ID.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _note = 'Sending OTP...';
    });

    try {
      await widget.authController.backendApiService.initOtp(
        name: name,
        mobile: mobile,
        vid: vid,
      );

      if (!mounted) return;
      setState(() {
        _step = 2;
        _note = 'OTP sent to your mobile.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = 2;
        _note = 'OTP endpoint unavailable. For demo, use 123456.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final vid = _vidController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _note = 'Enter OTP.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _note = 'Verifying OTP...';
    });

    try {
      await widget.authController.backendApiService.verifyOtp(
        vid: vid,
        otp: otp,
      );
      if (!mounted) return;
      setState(() {
        _step = 3;
        _note = 'Verified. Now connect and link your wallet.';
      });
    } catch (e) {
      if (otp == '123456') {
        if (!mounted) return;
        setState(() {
          _step = 3;
          _note = 'Verified via demo fallback. Now connect and link your wallet.';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _note = 'OTP verification failed. Use 123456 for demo.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
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
        _step = 4;
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
                'Step 1: Identity Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _sendOtp,
                child: const Text('Send OTP'),
              ),
            ],
            if (_step == 2) ...[
              const Text(
                'Step 2: Verify OTP',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _busy ? null : _verifyOtp,
                child: const Text('Verify OTP'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        setState(() {
                          _step = 1;
                        });
                      },
                child: const Text('Back'),
              ),
            ],
            if (_step == 3) ...[
              const Text(
                'Step 3: Link MetaMask Wallet',
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
            if (_step == 4) ...[
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
