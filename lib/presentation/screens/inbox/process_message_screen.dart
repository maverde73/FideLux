
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../../domain/entities/transaction_category.dart';
import '../../../domain/entities/inbox_message.dart';
import '../../../domain/repositories/ai_engine_repository.dart';
import '../../../data/ai/receipt_parser.dart';
import '../../../theme/fidelux_colors.dart';
import '../../../theme/fidelux_spacing.dart';
import '../../../theme/fidelux_radius.dart';
import '../../providers/accounting_providers.dart';
import '../../providers/ocr_providers.dart';

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

  // OCR state
  bool _ocrLoading = false;
  bool _ocrDone = false;
  String? _ocrError;
  ParsedReceipt? _parsedReceipt;
  CategorizeResult? _categorizeResult;
  String? _ocrRawText;

  bool get _hasImageAttachment {
    return widget.message.attachments.any(
      (a) => a.mimeType.startsWith('image/'),
    );
  }

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(text: widget.message.subject ?? '');
    _amountController = TextEditingController(text: '0.00');
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();

    // Start OCR if there's an image attachment, otherwise just categorize.
    if (_hasImageAttachment) {
      _runOcr();
    } else {
      _runCategorizeOnly();
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _runOcr() async {
    setState(() {
      _ocrLoading = true;
      _ocrError = null;
    });

    try {
      final ocr = ref.read(ocrRepositoryProvider);
      final engine = ref.read(aiEngineProvider);

      final imageAttachment = widget.message.attachments.firstWhere(
        (a) => a.mimeType.startsWith('image/'),
      );

      final ocrResult = await ocr.extractText(imageAttachment.data);
      if (!ocrResult.success) {
        setState(() {
          _ocrLoading = false;
          _ocrDone = true;
          _ocrError = ocrResult.errorMessage;
        });
        return;
      }

      _ocrRawText = ocrResult.fullText;
      final parsed = await engine.parseReceipt(ocrResult.fullText);
      _parsedReceipt = parsed;

      // Categorize using merchant/description from OCR.
      final catResult = await engine.categorize(
        parsed.merchant ?? '',
        parsed.merchant,
      );
      _categorizeResult = catResult;

      // Pre-fill form fields if confidence is sufficient.
      _prefillFromOcr(parsed, catResult);

      setState(() {
        _ocrLoading = false;
        _ocrDone = true;
      });
    } catch (e) {
      setState(() {
        _ocrLoading = false;
        _ocrDone = true;
        _ocrError = e.toString();
      });
    }
  }

  Future<void> _runCategorizeOnly() async {
    final engine = ref.read(aiEngineProvider);
    final text = widget.message.bodyText ?? widget.message.subject ?? '';
    if (text.isEmpty) return;

    final catResult = await engine.categorize(text, null);
    if (!mounted) return;
    setState(() {
      _categorizeResult = catResult;
      if (catResult.confidence > 0.5) {
        _selectedCategory = catResult.category;
      }
    });
  }

  void _prefillFromOcr(ParsedReceipt receipt, CategorizeResult catResult) {
    final conf = receipt.confidence;

    if (receipt.total != null && (conf['total'] ?? 0) > 0.5) {
      _amountController.text = receipt.total!.toStringAsFixed(2);
    }
    if (receipt.merchant != null && (conf['merchant'] ?? 0) > 0.5) {
      _merchantController.text = receipt.merchant!;
    }
    if (receipt.date != null && (conf['date'] ?? 0) > 0.5) {
      _selectedDate = receipt.date!;
    }
    if (catResult.confidence > 0.5) {
      _selectedCategory = catResult.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.processMessageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FideLuxSpacing.s4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview (if attachment exists)
              if (_hasImageAttachment) _buildImagePreview(),

              // OCR status indicator
              if (_ocrLoading) _buildOcrLoading(l10n),
              if (_ocrDone && _ocrError != null) _buildOcrError(l10n),
              if (_ocrDone && _ocrError == null && _hasImageAttachment)
                _buildOcrSuccess(l10n),

              // Gambling alert
              if (_categorizeResult?.alert == true) _buildGamblingAlert(l10n),

              // Message Preview Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(FideLuxSpacing.s3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.message.senderEmail,
                          style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: FideLuxSpacing.s1),
                      Text(widget.message.subject ?? 'No Subject',
                          style: Theme.of(context).textTheme.titleMedium),
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
              const SizedBox(height: FideLuxSpacing.s6),

              // Form Fields
              _buildFieldWithConfidence(
                child: TextFormField(
                  controller: _merchantController,
                  decoration: InputDecoration(
                    labelText: l10n.processMessageMerchant,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                confidenceKey: 'merchant',
                l10n: l10n,
              ),
              const SizedBox(height: FideLuxSpacing.s4),

              _buildFieldWithConfidence(
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.processMessageAmount,
                    border: const OutlineInputBorder(),
                    prefixText: '\u20AC ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val.replaceAll(',', '.')) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
                confidenceKey: 'total',
                l10n: l10n,
              ),
              const SizedBox(height: FideLuxSpacing.s4),

              // Category Dropdown
              DropdownButtonFormField<TransactionCategory>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.processMessageCategory,
                  border: const OutlineInputBorder(),
                  suffixIcon: _categorizeResult != null &&
                          _categorizeResult!.confidence > 0.5
                      ? Padding(
                          padding: const EdgeInsets.only(right: FideLuxSpacing.s2),
                          child: _buildConfidenceChip(
                              _categorizeResult!.confidence, l10n),
                        )
                      : null,
                ),
                items: TransactionCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 16, color: cat.color),
                        const SizedBox(width: FideLuxSpacing.s2),
                        Text(cat.localizedName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: FideLuxSpacing.s4),

              // Account Dropdown
              accountsAsync.when(
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return const Text(
                      'No accounts available. Create one in Settings.',
                      style: TextStyle(color: FideLuxColors.error),
                    );
                  }

                  if (_selectedAccountId == null && accounts.isNotEmpty) {
                    _selectedAccountId = accounts.first.id;
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
                      labelText: l10n.processMessageAccount,
                      border: const OutlineInputBorder(),
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text(
                            '${acc.name} (${acc.currency} ${(acc.currentBalance / 100).toStringAsFixed(2)})'),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedAccountId = val),
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading accounts: $e'),
              ),
              const SizedBox(height: FideLuxSpacing.s4),

              // Date Picker
              _buildFieldWithConfidence(
                child: ListTile(
                  title: Text(l10n.processMessageDate),
                  subtitle: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FideLuxRadius.sm),
                    side: const BorderSide(color: FideLuxColors.outline),
                  ),
                ),
                confidenceKey: 'date',
                l10n: l10n,
              ),
              const SizedBox(height: FideLuxSpacing.s4),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.processMessageNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              // Raw OCR text (expandable)
              if (_ocrRawText != null) ...[
                const SizedBox(height: FideLuxSpacing.s4),
                _buildRawOcrSection(l10n),
              ],

              const SizedBox(height: FideLuxSpacing.s8),
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

  // ── OCR UI helpers ──────────────────────────────────────────────────

  Widget _buildImagePreview() {
    final attachment = widget.message.attachments.firstWhere(
      (a) => a.mimeType.startsWith('image/'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: FideLuxSpacing.s4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FideLuxRadius.md),
        child: Image.memory(
          attachment.data,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildOcrLoading(L l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FideLuxSpacing.s4),
      child: Card(
        color: FideLuxColors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(FideLuxSpacing.s3),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: FideLuxSpacing.s3),
              Text(l10n.ocrProcessing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOcrError(L l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FideLuxSpacing.s4),
      child: Card(
        color: FideLuxColors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(FideLuxSpacing.s3),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: FideLuxColors.error),
              const SizedBox(width: FideLuxSpacing.s2),
              Expanded(child: Text(l10n.ocrFailed)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOcrSuccess(L l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FideLuxSpacing.s4),
      child: Card(
        color: FideLuxColors.successContainer,
        child: Padding(
          padding: const EdgeInsets.all(FideLuxSpacing.s3),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: FideLuxColors.success),
              const SizedBox(width: FideLuxSpacing.s2),
              Text(l10n.ocrComplete),
              const Spacer(),
              Text(
                l10n.ocrSuggested,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: FideLuxColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamblingAlert(L l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FideLuxSpacing.s4),
      child: Card(
        color: FideLuxColors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(FideLuxSpacing.s3),
          child: Row(
            children: [
              const Icon(Icons.casino, color: FideLuxColors.error),
              const SizedBox(width: FideLuxSpacing.s2),
              Expanded(
                child: Text(
                  l10n.gamblingAlert,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: FideLuxColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWithConfidence({
    required Widget child,
    required String confidenceKey,
    required L l10n,
  }) {
    final conf = _parsedReceipt?.confidence[confidenceKey];
    if (conf == null || conf <= 0.0 || !_ocrDone) {
      return child;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: FideLuxSpacing.s1),
        _buildConfidenceChip(conf, l10n),
      ],
    );
  }

  Widget _buildConfidenceChip(double confidence, L l10n) {
    final Color color;
    final String label;

    if (confidence >= 0.8) {
      color = FideLuxColors.success;
      label = l10n.ocrConfidenceHigh;
    } else if (confidence >= 0.5) {
      color = FideLuxColors.warning;
      label = l10n.ocrConfidenceMedium;
    } else {
      color = FideLuxColors.error;
      label = l10n.ocrConfidenceLow;
    }

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildRawOcrSection(L l10n) {
    return ExpansionTile(
      title: Text(l10n.ocrRawText),
      tilePadding: const EdgeInsets.symmetric(horizontal: FideLuxSpacing.s3),
      childrenPadding: const EdgeInsets.all(FideLuxSpacing.s3),
      initiallyExpanded: false,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FideLuxSpacing.s2),
          decoration: BoxDecoration(
            color: FideLuxColors.surfaceContainer,
            borderRadius: BorderRadius.circular(FideLuxRadius.sm),
          ),
          child: SelectableText(
            _ocrRawText!,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ── Existing interactions ─────────────────────────────────────────

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
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(L.of(ctx)!.processMessageConfirm),
          content: Text(L.of(ctx)!.processMessageConfirmDialog),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm')),
          ],
        ),
      );

      if (confirm == true) {
        final amountDouble =
            double.parse(_amountController.text.replaceAll(',', '.'));
        final amountCents = (amountDouble * 100).round();
        final finalAmount =
            _selectedCategory.isExpense ? -amountCents : amountCents;

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
            context.go('/ledger');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      }
    }
  }
}
