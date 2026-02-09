
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/email_config.dart';
import '../../domain/repositories/email_repository.dart';
import '../../presentation/providers/inbox_providers.dart';

// Localization needed. I'll use placeholders or keys assuming they exist as planned.
// l10n.emailConfigTitle etc.

class EmailConfigScreen extends ConsumerStatefulWidget {
  const EmailConfigScreen({super.key});

  @override
  ConsumerState<EmailConfigScreen> createState() => _EmailConfigScreenState();
}

class _EmailConfigScreenState extends ConsumerState<EmailConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _imapHostController;
  late TextEditingController _imapPortController;
  late TextEditingController _smtpHostController;
  late TextEditingController _smtpPortController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _sharerEmailController;

  bool _isLoading = false;
  String? _testResult;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _imapHostController = TextEditingController();
    _imapPortController = TextEditingController(text: '993');
    _smtpHostController = TextEditingController();
    _smtpPortController = TextEditingController(text: '465');
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _sharerEmailController = TextEditingController();
    
    // Load existing config
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConfig());
  }

  Future<void> _loadConfig() async {
    final config = await ref.read(emailConfigProvider.future);
    if (config != null) {
      setState(() {
        _imapHostController.text = config.imapHost;
        _imapPortController.text = config.imapPort.toString();
        _smtpHostController.text = config.smtpHost;
        _smtpPortController.text = config.smtpPort.toString();
        _emailController.text = config.email;
        _passwordController.text = config.password;
        _sharerEmailController.text = config.sharerEmail;
      });
    }
  }

  @override
  void dispose() {
    _imapHostController.dispose();
    _imapPortController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sharerEmailController.dispose();
    super.dispose();
  }

  void _applyPreset(String preset) {
    if (preset == 'Gmail') {
      _imapHostController.text = 'imap.gmail.com';
      _imapPortController.text = '993';
      _smtpHostController.text = 'smtp.gmail.com';
      _smtpPortController.text = '465';
    } else if (preset == 'Outlook') {
      _imapHostController.text = 'outlook.office365.com';
      _imapPortController.text = '993';
      _smtpHostController.text = 'smtp.office365.com';
      _smtpPortController.text = '587';
    }
    setState(() {});
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _testResult = null;
      _isSuccess = false;
    });

    final config = EmailConfig(
      imapHost: _imapHostController.text,
      imapPort: int.parse(_imapPortController.text),
      smtpHost: _smtpHostController.text,
      smtpPort: int.parse(_smtpPortController.text),
      email: _emailController.text,
      password: _passwordController.text,
      sharerEmail: _sharerEmailController.text,
    );

    final repo = ref.read(emailRepositoryProvider);
    final success = await repo.testConnection(config);

    setState(() {
      _isLoading = false;
      _isSuccess = success;
      _testResult = success ? "Connection successful!" : "Connection failed.";
    });
  }

  Future<void> _save() async {
    if (!_isSuccess) return; // Force test first? Or simpler: allow save if tested OK.
    
    final config = EmailConfig(
      imapHost: _imapHostController.text,
      imapPort: int.parse(_imapPortController.text),
      smtpHost: _smtpHostController.text,
      smtpPort: int.parse(_smtpPortController.text),
      email: _emailController.text,
      password: _passwordController.text,
      sharerEmail: _sharerEmailController.text,
    );
    
    await ref.read(emailRepositoryProvider).configure(config);
    ref.refresh(emailConfigProvider); // Refresh provider
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration saved.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Presets
              Row(
                children: [
                  ActionChip(label: const Text('Gmail'), onPressed: () => _applyPreset('Gmail')),
                  const SizedBox(width: 8),
                  ActionChip(label: const Text('Outlook'), onPressed: () => _applyPreset('Outlook')),
                ],
              ),
              const SizedBox(height: 16),
              if (_imapHostController.text == 'imap.gmail.com')
                const Card(
                  color: Colors.amberAccent,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('For Gmail, assume you have 2FA enabled and use an App Password.'),
                  ),
                ),
                
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _imapHostController,
                decoration: const InputDecoration(labelText: 'IMAP Host', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imapPortController,
                decoration: const InputDecoration(labelText: 'IMAP Port', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _smtpHostController,
                decoration: const InputDecoration(labelText: 'SMTP Host', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _smtpPortController,
                decoration: const InputDecoration(labelText: 'SMTP Port', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _sharerEmailController,
                decoration: const InputDecoration(labelText: "Sharer's Email Address (Sender Filter)", border: OutlineInputBorder()),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              
              const SizedBox(height: 24),
              
              if (_testResult != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _testResult!,
                    style: TextStyle(color: _isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _testConnection,
                      child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Test Connection'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSuccess ? _save : null,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
