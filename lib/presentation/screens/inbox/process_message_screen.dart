
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../../domain/entities/transaction_category.dart';
import '../../../domain/entities/inbox_message.dart'; // Domain
import '../../providers/accounting_providers.dart';

// We need a provider to fetch a single message by ID.
// Or pass the object via extra (but ID is safer for deep linking).
// I'll add `messageByIdProvider` to accounting_providers or define locally.

final messageByIdProvider = FutureProvider.family<InboxMessage?, String>((ref, id) async {
  // Use Dao or repository to fetch.
  // Dao methods returns Drift object. Need mapping.
  // Assuming Dao has `getMessageById`.
  // I need to add `getMessageById` to `InboxDao`.
  // Or just iterate `pendingMessages` if list is small.
  // For MVP, filter from `watchPendingMessages` stream snapshot? No, that's async.
  // I'll add `getMessageById` to DAO.
  final dao = ref.watch(inboxDaoProvider);
  // Drift generated method `getSingleOrNull` on custom query.
  // I'll implement it shortly.
  // For now, placeholder or throw.
  // Actually, I can pass object in constructor if I don't care about deep link persistence for now.
  // But standard is fetch.
  // I'll assume `dao.getMessageById(id)` exists and returns Drift object.
  // Then map to Domain object.
  // But wait, `InboxDao` isn't fully updated yet.
  
  // Quick fix: Pass object via route "extra".
  return null; 
});


class ProcessMessageScreen extends ConsumerStatefulWidget {
  final InboxMessage message; 

  const ProcessMessageScreen({super.key, required this.message});

  @override
  ConsumerState<ProcessMessageScreen> createState() => _ProcessMessageScreenState();
}

class _ProcessMessageScreenState extends ConsumerState<ProcessMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  TransactionCategory _selectedCategory = TransactionCategory.other;
  String? _selectedAccountId;
  
  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.message.subject ?? '');
    _amountController = TextEditingController(text: '0.00'); // TODO: Extract from OCR later
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.processMessageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Message Preview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.message.senderEmail, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Text(widget.message.subject ?? 'No Subject', style: Theme.of(context).textTheme.titleMedium),
                      const Divider(),
                      if (widget.message.bodyText != null)
                        Text(
                          widget.message.bodyText!, 
                          maxLines: 3, 
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Form Fields
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: l10n.processMessageMerchant,
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.processMessageAmount,
                  border: const OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.processMessageCategory,
                  border: const OutlineInputBorder(),
                ),
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 16, color: cat.color),
                        const SizedBox(width: 8),
                        Text(cat.localizedName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              
              // Account Dropdown
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) return Text("No accounts available. Create one in Settings.", style: TextStyle(color: Colors.red));
                  
                  // Auto-select first if none selected
                  if (_selectedAccountId == null && accounts.isNotEmpty) {
                    _selectedAccountId = accounts.first.id;
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: l10n.processMessageAccount,
                      border: const OutlineInputBorder(),
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text('${acc.name} (${acc.currency} ${(acc.currentBalance/100).toStringAsFixed(2)})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedAccountId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading accounts: $e'),
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              ListTile(
                 title: Text(l10n.processMessageDate),
                 subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                 trailing: Icon(Icons.calendar_today),
                 onTap: _pickDate,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.processMessageNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.processMessageConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedAccountId != null) {
        // Confirmation Dialog
        final confirm = await showDialog<bool>(
          context: context, 
          builder: (ctx) => AlertDialog(
            title: Text(L.of(ctx)!.processMessageConfirm),
            content: Text(L.of(ctx)!.processMessageConfirmDialog),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")), // Localize
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Confirm")), // Localize
            ],
          )
        );
        
        if (confirm == true) {
           final amountDouble = double.parse(_amountController.text.replaceAll(',', '.'));
           final amountCents = (amountDouble * 100).round();
           // Expense is usually negative in DB?
           // Directive D05 Step 1 Rule: "negativo per spese".
           // UI shows positive amount for expense category.
           // Logic: if category.isExpense, negate amount.
           final finalAmount = _selectedCategory.isExpense ? -amountCents : amountCents;

           try {
             await ref.read(processInboxMessageProvider).call(
               message: widget.message,
               accountId: _selectedAccountId!,
               category: _selectedCategory,
               amount: finalAmount,
               merchant: _merchantController.text,
               date: _selectedDate,
               notes: _notesController.text,
             );
             
             if (mounted) {
               // Navigate to Ledger with animation?
               // For MVP, just go to root or ledger.
               // GoRouter: go('/ledger');
               context.go('/ledger'); // Assuming /ledger route exists
             }
           } catch (e) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
             }
           }
        }
    }
  }
}
