
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import '../../../domain/entities/email_auth_method.dart';
import '../../../domain/entities/email_auth_state.dart';
import '../../../domain/entities/email_config.dart';
import '../../../data/email/email_discovery_service.dart';
import '../../providers/inbox_providers.dart';
import '../../../theme/fidelux_spacing.dart';
import '../../../theme/fidelux_radius.dart';

enum _SetupStep { enterEmail, authenticate, testing, done }

class EmailConfigScreen extends ConsumerStatefulWidget {
  const EmailConfigScreen({super.key});

  @override
  ConsumerState<EmailConfigScreen> createState() => _EmailConfigScreenState();
}

class _EmailConfigScreenState extends ConsumerState<EmailConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _sharerEmailController;
  late TextEditingController _passwordController;

  _SetupStep _step = _SetupStep.enterEmail;
  bool _isLoading = false;
  String? _errorMessage;
  EmailDiscoveryResult? _discoveryResult;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _sharerEmailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingConfig());
  }

  Future<void> _checkExistingConfig() async {
    final authState = await ref.read(emailAuthStateProvider.future);
    if (authState.status == EmailAuthStatus.connected && mounted) {
      setState(() => _step = _SetupStep.done);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sharerEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _discover() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final discovery = ref.read(emailDiscoveryServiceProvider);
      final result = await discovery.discover(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _discoveryResult = result;
          _step = _SetupStep.authenticate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _authenticateOAuth2() async {
    if (_discoveryResult == null) return;

    debugPrint('[UI] _authenticateOAuth2 called, method=${_discoveryResult!.authMethod.name}');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(emailAuthServiceProvider);
      if (_discoveryResult!.authMethod == EmailAuthMethod.oauth2Gmail) {
        debugPrint('[UI] Calling authenticateGmail()');
        await authService.authenticateGmail();
      } else {
        debugPrint('[UI] Calling authenticateMicrosoft()');
        await authService.authenticateMicrosoft();
      }

      debugPrint('[UI] OAuth2 succeeded, proceeding to _testAndSave()');
      await _testAndSave();
    } catch (e, stack) {
      debugPrint('[UI] OAuth2 FAILED: $e\n$stack');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _authenticatePassword() async {
    if (_discoveryResult == null) return;
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(emailAuthServiceProvider);
      await authService.storePassword(_passwordController.text);

      await _testAndSave();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _testAndSave() async {
    debugPrint('[UI] _testAndSave called');
    if (mounted) setState(() => _step = _SetupStep.testing);

    final config = EmailConfig(
      email: _emailController.text.trim(),
      sharerEmail: _sharerEmailController.text.trim(),
      imapHost: _discoveryResult!.imapHost,
      imapPort: _discoveryResult!.imapPort,
      imapUseSsl: _discoveryResult!.imapUseSsl,
      smtpHost: _discoveryResult!.smtpHost,
      smtpPort: _discoveryResult!.smtpPort,
      smtpUseSsl: _discoveryResult!.smtpUseSsl,
      authMethod: _discoveryResult!.authMethod,
    );

    debugPrint('[UI] Config: imap=${config.imapHost}:${config.imapPort}, auth=${config.authMethod.name}');

    final repo = ref.read(emailRepositoryProvider);
    await repo.configure(config);
    debugPrint('[UI] Config saved, testing connection...');

    final success = await repo.testConnection();
    debugPrint('[UI] Connection test result: $success');

    if (mounted) {
      if (success) {
        ref.invalidate(emailAuthStateProvider);
        ref.invalidate(emailConfigProvider);
        setState(() {
          _step = _SetupStep.done;
          _isLoading = false;
        });
      } else {
        debugPrint('[UI] Connection test FAILED, rolling back config');
        await repo.clearConfig();
        setState(() {
          _step = _SetupStep.authenticate;
          _errorMessage = 'Connection test failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _disconnect() async {
    await ref.read(emailRepositoryProvider).clearConfig();
    ref.invalidate(emailAuthStateProvider);
    ref.invalidate(emailConfigProvider);
    if (mounted) {
      setState(() {
        _step = _SetupStep.enterEmail;
        _discoveryResult = null;
        _emailController.clear();
        _sharerEmailController.clear();
        _passwordController.clear();
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emailConfigTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FideLuxSpacing.s4),
        child: _buildCurrentStep(context, l10n),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, L l10n) {
    switch (_step) {
      case _SetupStep.enterEmail:
        return _buildEnterEmailStep(context, l10n);
      case _SetupStep.authenticate:
        return _buildAuthenticateStep(context, l10n);
      case _SetupStep.testing:
        return _buildTestingStep(context, l10n);
      case _SetupStep.done:
        return _buildDoneStep(context, l10n);
    }
  }

  Widget _buildEnterEmailStep(BuildContext context, L l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.email,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: FideLuxSpacing.s4),
          Text(
            l10n.emailConfigDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: FideLuxSpacing.s6),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.emailConfigEnterEmail,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: FideLuxSpacing.s4),
          TextFormField(
            controller: _sharerEmailController,
            decoration: InputDecoration(
              labelText: l10n.emailConfigSharerEmail,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: FideLuxSpacing.s6),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: FideLuxSpacing.s3),
          ],
          FilledButton.icon(
            onPressed: _isLoading ? null : _discover,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(
              _isLoading ? l10n.emailConfigDiscovering : l10n.emailConfigDiscover,
            ),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: FideLuxSpacing.s3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FideLuxRadius.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticateStep(BuildContext context, L l10n) {
    final result = _discoveryResult!;
    final isOAuth = result.authMethod != EmailAuthMethod.password;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Provider chip
        Center(
          child: Chip(
            avatar: Icon(
              isOAuth ? Icons.verified_user : Icons.dns,
              size: 18,
            ),
            label: Text(l10n.emailProviderDetected(result.providerName)),
          ),
        ),
        const SizedBox(height: FideLuxSpacing.s6),

        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: FideLuxSpacing.s3),
        ],

        if (result.authMethod == EmailAuthMethod.oauth2Gmail) ...[
          FilledButton.icon(
            onPressed: _isLoading ? null : _authenticateOAuth2,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(l10n.emailConfigSignInGoogle),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: FideLuxSpacing.s3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FideLuxRadius.md),
              ),
            ),
          ),
        ] else if (result.authMethod == EmailAuthMethod.oauth2Microsoft) ...[
          FilledButton.icon(
            onPressed: _isLoading ? null : _authenticateOAuth2,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(l10n.emailConfigSignInMicrosoft),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: FideLuxSpacing.s3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FideLuxRadius.md),
              ),
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.emailConfigEnterPassword,
              hintText: l10n.emailConfigPasswordHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          const SizedBox(height: FideLuxSpacing.s4),
          FilledButton.icon(
            onPressed: _isLoading ? null : _authenticatePassword,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(l10n.emailConfigConnect),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: FideLuxSpacing.s3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FideLuxRadius.md),
              ),
            ),
          ),
        ],

        const SizedBox(height: FideLuxSpacing.s4),
        // Back button
        TextButton(
          onPressed: () => setState(() {
            _step = _SetupStep.enterEmail;
            _errorMessage = null;
          }),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildTestingStep(BuildContext context, L l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: FideLuxSpacing.s12),
          const CircularProgressIndicator(),
          const SizedBox(height: FideLuxSpacing.s4),
          Text(
            l10n.emailConfigTesting,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDoneStep(BuildContext context, L l10n) {
    final authAsync = ref.watch(emailAuthStateProvider);

    return authAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (authState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(FideLuxSpacing.s4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: const Icon(Icons.email, size: 28),
                    ),
                    const SizedBox(width: FideLuxSpacing.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (authState.providerName != null)
                            Text(
                              authState.providerName!,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          Text(
                            l10n.emailConnected(authState.email ?? ''),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FideLuxSpacing.s6),
            OutlinedButton(
              onPressed: _disconnect,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: FideLuxSpacing.s3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FideLuxRadius.md),
                ),
              ),
              child: Text(l10n.emailConfigDisconnect),
            ),
          ],
        );
      },
    );
  }
}
