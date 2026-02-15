import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/widgets/empty_state_view.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';

import 'package:fidelux/data/local_db/app_database.dart';
import '../../providers/accounting_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.emptyAccountsTitle,
              body: l10n.emptyAccountsBody,
              ctaLabel: l10n.emptyAccountsCta,
              onCtaPressed: () => _showAccountDialog(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(FideLuxSpacing.s4),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: FideLuxColors.primaryContainer,
                  child: Icon(
                    Icons.account_balance,
                    color: FideLuxColors.onPrimaryContainer,
                  ),
                ),
                title: Text(account.name),
                subtitle: Text(account.type),
                trailing: Text(
                  '${account.currency} ${(account.currentBalance / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                onTap: () => _showAccountDialog(context, account: account),
                onLongPress: () => _showDeleteDialog(context, ref, account),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAccountDialog(BuildContext context, {Account? account}) {
    showDialog(
      context: context,
      builder: (context) => AccountDialog(account: account),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina account'), // TODO: l10n
        content: Text('Sei sicuro di voler eliminare "${account.name}"?'), // TODO: l10n
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(deleteAccountProvider).call(account.id);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Elimina'), // TODO: l10n
          ),
        ],
      ),
    );
  }
}

class AccountDialog extends ConsumerStatefulWidget {
  final Account? account;
  const AccountDialog({super.key, this.account});

  @override
  ConsumerState<AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<AccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedType;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    // Initial balance is stored in cents. Convert to unit for display.
    final initialBalance = widget.account?.initialBalance ?? 0;
    _balanceController = TextEditingController(text: (initialBalance / 100).toStringAsFixed(2));
    _selectedType = widget.account?.type ?? 'checking';
    _currency = widget.account?.currency ?? 'EUR';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;
    final isEditing = widget.account != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifica Account' : l10n.accountsAdd), // TODO: l10n
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.accountsName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: FideLuxSpacing.s4),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: l10n.accountsType,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'checking', child: Text(l10n.accountTypeChecking)),
                  DropdownMenuItem(value: 'savings', child: Text(l10n.accountTypeSavings)),
                  DropdownMenuItem(value: 'credit_card', child: Text(l10n.accountTypeCreditCard)),
                  DropdownMenuItem(value: 'cash', child: Text(l10n.accountTypeCash)),
                  DropdownMenuItem(value: 'other', child: Text(l10n.accountTypeOther)),
                ],
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: FideLuxSpacing.s4),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: l10n.accountsInitialBalance,
                  border: const OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null) return 'Invalid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Salva' : l10n.accountsCreate), // TODO: l10n
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final balanceStr = _balanceController.text.replaceAll(',', '.');
      final balanceDouble = double.parse(balanceStr);
      final balanceCents = (balanceDouble * 100).round();

      try {
        if (widget.account != null) {
          await ref.read(updateAccountProvider).call(
            accountId: widget.account!.id,
            name: name,
            type: _selectedType,
            currency: _currency,
            initialBalance: balanceCents,
          );
        } else {
          await ref.read(createAccountProvider).call(
            name: name,
            type: _selectedType,
            currency: _currency,
            initialBalance: balanceCents,
          );
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
