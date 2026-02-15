import 'package:flutter/material.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';
import 'package:fidelux/theme/fidelux_radius.dart';

/// Reusable empty-state widget with a 3-level hierarchy:
///
/// 1. **Icon + Title** — primary insight (what happened)
/// 2. **Body + optional micro-list** — secondary explanation (why & what next)
/// 3. **CTA button** — primary call-to-action
///
/// Transforms blank screens into contextual onboarding moments.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.bullets,
    this.ctaLabel,
    this.onCtaPressed,
  });

  /// Large icon displayed above the title.
  final IconData icon;

  /// Primary insight — e.g. "No transactions yet".
  final String title;

  /// Secondary explanation — e.g. "Process inbox messages or…".
  final String body;

  /// Optional micro-list of 2–3 benefit/next-step bullets.
  final List<String>? bullets;

  /// Label for the primary CTA button. Hidden if null.
  final String? ctaLabel;

  /// Callback for the primary CTA. If null, button is hidden.
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: FideLuxSpacing.s8,
          vertical: FideLuxSpacing.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Level 1: Icon ──
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: FideLuxColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(FideLuxRadius.xl),
              ),
              child: Icon(
                icon,
                size: 36,
                color: FideLuxColors.primary,
              ),
            ),
            const SizedBox(height: FideLuxSpacing.s4),

            // ── Level 1: Title ──
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FideLuxSpacing.s2),

            // ── Level 2: Body ──
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Level 2: Micro-list ──
            if (bullets != null && bullets!.isNotEmpty) ...[
              const SizedBox(height: FideLuxSpacing.s3),
              ...bullets!.map(
                (bullet) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: FideLuxSpacing.s1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: FideLuxColors.success,
                      ),
                      const SizedBox(width: FideLuxSpacing.s2),
                      Flexible(
                        child: Text(
                          bullet,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Level 3: CTA ──
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: FideLuxSpacing.s6),
              FilledButton(
                onPressed: onCtaPressed,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FideLuxSpacing.s6,
                    vertical: FideLuxSpacing.s3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FideLuxRadius.md),
                  ),
                ),
                child: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
