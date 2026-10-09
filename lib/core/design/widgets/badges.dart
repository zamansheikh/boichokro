import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../features/discover/domain/entities/book.dart';
import '../../../features/library/domain/entities/request.dart';
import '../../utils/constants.dart';
import '../tokens.dart';

/// Tone and icon used everywhere a [BookMode] is shown.
extension BookModeStyle on BookMode {
  AppTone get tone =>
      this == BookMode.donate ? AppTone.donate : AppTone.exchange;

  IconData get icon =>
      this == BookMode.donate ? LucideIcons.gift : LucideIcons.repeat;

  /// Short label written from the reader's point of view.
  String get offerLabel => this == BookMode.donate ? 'Free' : 'Swap';
}

/// Tone and icon used everywhere a [BookStatus] is shown.
extension BookStatusStyle on BookStatus {
  AppTone get tone {
    switch (this) {
      case BookStatus.available:
        return AppTone.success;
      case BookStatus.requested:
        return AppTone.warning;
      case BookStatus.pending:
        return AppTone.exchange;
      case BookStatus.completed:
        return AppTone.neutral;
    }
  }

  IconData get icon {
    switch (this) {
      case BookStatus.available:
        return LucideIcons.circleCheck;
      case BookStatus.requested:
        return LucideIcons.mail;
      case BookStatus.pending:
        return LucideIcons.hourglass;
      case BookStatus.completed:
        return LucideIcons.checkCheck;
    }
  }
}

/// Tone and icon used everywhere a [RequestStatus] is shown.
extension RequestStatusStyle on RequestStatus {
  AppTone get tone {
    switch (this) {
      case RequestStatus.pending:
        return AppTone.warning;
      case RequestStatus.accepted:
        return AppTone.primary;
      case RequestStatus.completed:
        return AppTone.success;
      case RequestStatus.declined:
        return AppTone.danger;
      case RequestStatus.cancelled:
        return AppTone.neutral;
    }
  }

  IconData get icon {
    switch (this) {
      case RequestStatus.pending:
        return LucideIcons.clock;
      case RequestStatus.accepted:
        return LucideIcons.handshake;
      case RequestStatus.completed:
        return LucideIcons.checkCheck;
      case RequestStatus.declined:
        return LucideIcons.x;
      case RequestStatus.cancelled:
        return LucideIcons.ban;
    }
  }
}

/// Small rounded label with an optional icon. The base for every badge.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.tone = AppTone.neutral,
    this.dense = false,
  });

  factory StatusPill.mode(BookMode mode, {Key? key, bool dense = false}) {
    return StatusPill(
      key: key,
      label: mode.displayName,
      icon: mode.icon,
      tone: mode.tone,
      dense: dense,
    );
  }

  factory StatusPill.book(BookStatus status, {Key? key, bool dense = false}) {
    return StatusPill(
      key: key,
      label: status.displayName,
      icon: status.icon,
      tone: status.tone,
      dense: dense,
    );
  }

  factory StatusPill.request(
    RequestStatus status, {
    Key? key,
    bool dense = false,
  }) {
    return StatusPill(
      key: key,
      label: status.displayName,
      icon: status.icon,
      tone: status.tone,
      dense: dense,
    );
  }

  final String label;
  final IconData? icon;
  final AppTone tone;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.tone(tone);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: colors.foreground),
            SizedBox(width: dense ? 4 : 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (dense ? context.text.labelSmall : context.text.labelMedium)
                      ?.copyWith(color: colors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline icon + text fact (distance, genre, date) without a filled background.
class MetaItem extends StatelessWidget {
  const MetaItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Five-step condition meter: more filled segments means better condition.
///
/// [condition] is the stored index, 0 (Like New) to 4 (Worn).
class ConditionMeter extends StatelessWidget {
  const ConditionMeter({
    super.key,
    required this.condition,
    this.showLabel = true,
  });

  final int condition;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final steps = AppConstants.bookConditions.length;
    final index = condition.clamp(0, steps - 1);
    final filled = steps - index;
    final color = index <= 1
        ? context.palette.success
        : index <= 3
        ? context.palette.warning
        : context.colors.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < steps; i++)
          Container(
            width: 10,
            height: 4,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: i < filled ? color : context.colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppConstants.bookConditions[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Star + average, optionally followed by the number of completed swaps.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.swaps});

  final double rating;
  final int? swaps;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final hasRating = rating > 0;
    final hasSwaps = swaps != null && swaps! > 0;

    if (!hasRating && !hasSwaps) {
      return Text('New member', style: style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasRating) ...[
          Icon(Icons.star_rounded, size: 15, color: context.palette.star),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: style?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (hasRating && hasSwaps) Text('  ·  ', style: style),
        if (hasSwaps)
          Text('$swaps ${swaps == 1 ? 'swap' : 'swaps'}', style: style),
      ],
    );
  }
}
