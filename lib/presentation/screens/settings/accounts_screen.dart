
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../providers/accounting_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle), // "Accounts"
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No accounts yet"), // TODO: localized
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddAccountDialog(context, ref),
                    child: Text(l10n.accountsAdd),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.account_balance), // Dynamic icon based on type?
                ),
                title: Text(account.name),
                subtitle: Text(account.type), // Localized enum?
                trailing: Text(
                  '${account.currency} ${(account.currentBalance / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }
}

class AddAccountDialog extends ConsumerStatefulWidget {
  const AddAccountDialog({super.key});

  @override
  ConsumerState<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends ConsumerState<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');
  String _selectedType = 'checking'; // Default
  String _currency = 'EUR';

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;

    return AlertDialog(
      title: Text(l10n.accountsAdd),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
          child: const Text('Create'), // Localize
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
        await ref.read(createAccountProvider).call(
          name: name,
          type: _selectedType,
          currency: _currency,
          initialBalance: balanceCents,
        );
        if (mounted) {
          Navigator.of(context).pop();
          // Refresh list handled by stream provider usually
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
