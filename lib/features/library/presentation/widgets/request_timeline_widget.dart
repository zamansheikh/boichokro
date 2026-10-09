import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../l10n/library/gen/library_l10n.dart';
import '../../domain/entities/request.dart';

/// The journey of a request, drawn as a vertical path:
/// Requested → Accepted → Hand-off arranged → Both confirmed → Reviewed.
///
/// Each step is done, current or upcoming. A declined or cancelled request
/// ends the path early. The header shows overall progress as a ring.
///
/// Set [collapsible] to show only the header until the reader taps it, which
/// keeps request cards short in lists.
class RequestTimelineWidget extends StatefulWidget {
  final BookRequest request;
  final bool isSeeker;
  final bool collapsible;

  const RequestTimelineWidget({
    super.key,
    required this.request,
    required this.isSeeker,
    this.collapsible = false,
  });

  @override
  State<RequestTimelineWidget> createState() => _RequestTimelineWidgetState();
}

enum _StepState { done, current, upcoming, stopped }

class _JourneyStep {
  const _JourneyStep({required this.title, required this.state, this.detail});

  final String title;
  final String? detail;
  final _StepState state;
}

class _RequestTimelineWidgetState extends State<RequestTimelineWidget> {
  /// Number of steps in a journey that runs to the end.
  static const int _fullLength = 5;

  late bool _expanded = !widget.collapsible;

  @override
  Widget build(BuildContext context) {
    final l = LibraryL10n.of(context);
    final steps = _buildSteps(l);
    final doneCount = steps.where((s) => s.state == _StepState.done).length;
    final stopped = steps.any((s) => s.state == _StepState.stopped);
    final progress = doneCount / _fullLength;
    final showSteps = _expanded || !widget.collapsible;

    final header = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ChokroMark(
            size: 44,
            progress: progress,
            icon: stopped
                ? LucideIcons.x
                : doneCount == _fullLength
                ? LucideIcons.check
                : LucideIcons.bookOpen,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(l.journeyEyebrow),
                const SizedBox(height: 2),
                Text(
                  _summary(l, steps, doneCount),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall,
                ),
              ],
            ),
          ),
          if (widget.collapsible) ...[
            const SizedBox(width: AppSpacing.sm),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: AppMotion.fast,
              child: Icon(
                LucideIcons.chevronDown,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );

    return Material(
      color: context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.collapsible)
            Semantics(
              button: true,
              expanded: _expanded,
              label: _expanded ? l.journeyHideSteps : l.journeyShowSteps,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: header,
              ),
            )
          else
            header,
          AnimatedSize(
            duration: AppMotion.medium,
            curve: AppMotion.curve,
            alignment: Alignment.topCenter,
            child: showSteps
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < steps.length; i++)
                          _StepRow(
                            step: steps[i],
                            isLast: i == steps.length - 1,
                            danger:
                                widget.request.status == RequestStatus.declined,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  String _summary(LibraryL10n l, List<_JourneyStep> steps, int doneCount) {
    final status = widget.request.status;
    if (status == RequestStatus.declined) return l.journeySummaryDeclined;
    if (status == RequestStatus.cancelled) return l.journeySummaryCancelled;
    if (doneCount >= steps.length) return l.journeySummaryComplete;

    final index = steps.indexWhere((s) => s.state != _StepState.done);
    final step = steps[index];
    // Name the step still ahead as "next" so it never reads as already done.
    return l.journeySummaryProgress(doneCount, steps.length, step.title);
  }

  List<_JourneyStep> _buildSteps(LibraryL10n l) {
    final request = widget.request;
    final isSeeker = widget.isSeeker;
    final status = request.status;
    final completed = status == RequestStatus.completed;
    final accepted = status == RequestStatus.accepted || completed;

    final steps = <_JourneyStep>[
      _JourneyStep(
        title: l.journeyStepRequested,
        detail: isSeeker
            ? l.journeyRequestedSeeker(context.relativeTime(request.createdAt))
            : l.journeyRequestedOwner(context.relativeTime(request.createdAt)),
        state: _StepState.done,
      ),
    ];

    if (status == RequestStatus.declined) {
      steps.add(
        _JourneyStep(
          title: l.journeyStepDeclined,
          detail: isSeeker ? l.journeyDeclinedSeeker : l.journeyDeclinedOwner,
          state: _StepState.stopped,
        ),
      );
      return steps;
    }

    if (status == RequestStatus.cancelled) {
      steps.add(
        _JourneyStep(
          title: l.journeyStepCancelled,
          detail: isSeeker ? l.journeyCancelledSeeker : l.journeyCancelledOwner,
          state: _StepState.stopped,
        ),
      );
      return steps;
    }

    // Accepted
    steps.add(
      _JourneyStep(
        title: l.journeyStepAccepted,
        detail: accepted
            ? (request.acceptedAt != null
                  ? context.relativeTime(request.acceptedAt!)
                  : null)
            : isSeeker
            ? l.journeyWaitingOwnerReply
            : l.journeyWaitingYourReply,
        state: accepted ? _StepState.done : _StepState.current,
      ),
    );

    // Hand-off arranged
    final arranged =
        completed ||
        request.exchangeMethod != null ||
        request.ownerConfirmed ||
        request.seekerConfirmed;
    steps.add(
      _JourneyStep(
        title: l.journeyStepHandOffArranged,
        detail: !accepted
            ? null
            : _arrangementDetail(l) ?? (arranged ? null : l.journeyArrangeHint),
        state: !accepted
            ? _StepState.upcoming
            : arranged
            ? _StepState.done
            : _StepState.current,
      ),
    );

    // Both confirmed
    steps.add(
      _JourneyStep(
        title: l.journeyStepBothConfirmed,
        detail: completed
            ? l.journeyChangedHands
            : accepted
            ? _confirmationDetail(l)
            : null,
        state: completed
            ? _StepState.done
            : accepted && arranged
            ? _StepState.current
            : _StepState.upcoming,
      ),
    );

    // Reviewed
    final mine = isSeeker ? request.seekerRating : request.ownerRating;
    final theirs = isSeeker ? request.ownerRating : request.seekerRating;
    String? reviewDetail;
    if (completed) {
      if (mine == null) {
        reviewDetail = l.journeyReviewPrompt;
      } else if (theirs == null) {
        reviewDetail = l.journeyYouRated(_rating(mine));
      } else {
        reviewDetail = l.journeyBothRated(_rating(mine), _rating(theirs));
      }
    }
    steps.add(
      _JourneyStep(
        title: l.journeyStepReviewed,
        detail: reviewDetail,
        state: mine != null
            ? _StepState.done
            : completed
            ? _StepState.current
            : _StepState.upcoming,
      ),
    );

    return steps;
  }

  /// A rating with one decimal, in the reader's digits.
  String _rating(double value) =>
      NumberFormat('0.0', context.core.localeName).format(value);

  String? _arrangementDetail(LibraryL10n l) {
    final request = widget.request;
    final method = request.exchangeMethod;
    if (method == null) return null;

    final parts = <String>[method.label(context)];
    if (method == ExchangeMethod.meetup) {
      if (request.meetingTime != null) {
        parts.add(context.date(request.meetingTime!, 'EEE d MMM, h:mm a'));
      }
      final place = request.meetingLocation?.trim() ?? '';
      if (place.isNotEmpty) parts.add(place);
    } else {
      final courier = request.courierMethod?.trim() ?? '';
      if (courier.isNotEmpty) parts.add(courier);
      final tracking = request.trackingId?.trim() ?? '';
      if (tracking.isNotEmpty) parts.add(l.trackingId(tracking));
    }
    return parts.join(' · ');
  }

  String _confirmationDetail(LibraryL10n l) {
    final request = widget.request;
    final isSeeker = widget.isSeeker;
    final mine = isSeeker ? request.seekerConfirmed : request.ownerConfirmed;
    final theirs = isSeeker ? request.ownerConfirmed : request.seekerConfirmed;

    if (mine && theirs) return l.journeyBothConfirmedFinishing;
    final you = mine ? l.pillYouConfirmed : l.pillYouNotYet;
    final String other;
    if (isSeeker) {
      other = theirs ? l.pillOwnerConfirmed : l.pillOwnerNotYet;
    } else {
      other = theirs ? l.pillReaderConfirmed : l.pillReaderNotYet;
    }
    return '$you · $other';
  }
}

/// One step of the journey: a node on the rail, a connector and its text.
class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.danger,
  });

  final _JourneyStep step;
  final bool isLast;

  /// Whether a stopped step should read as an error (declined) rather than
  /// a neutral ending (cancelled).
  final bool danger;

  static const double _node = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = step.state;
    final emphasised = state != _StepState.upcoming;

    final Color titleColor;
    switch (state) {
      case _StepState.current:
        titleColor = colors.primary;
      case _StepState.done:
        titleColor = colors.onSurface;
      case _StepState.stopped:
        titleColor = danger ? colors.error : colors.onSurface;
      case _StepState.upcoming:
        titleColor = colors.onSurfaceVariant;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _node,
            child: Column(
              children: [
                _buildNode(context),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: state == _StepState.done
                            ? colors.primary
                            : colors.outlineVariant,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 2,
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          step.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            color: titleColor,
                            fontWeight: emphasised
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (state == _StepState.current) ...[
                        const SizedBox(width: AppSpacing.sm),
                        StatusPill(
                          label: LibraryL10n.of(context).journeyNow,
                          tone: AppTone.primary,
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                  if (step.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.detail!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context) {
    final colors = context.colors;

    switch (step.state) {
      case _StepState.done:
        return Container(
          width: _node,
          height: _node,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.check, size: 14, color: colors.onPrimary),
        );
      case _StepState.current:
        return Container(
          width: _node,
          height: _node,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: colors.primary, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _StepState.stopped:
        final tone = context.tone(danger ? AppTone.danger : AppTone.neutral);
        return Container(
          width: _node,
          height: _node,
          decoration: BoxDecoration(
            color: tone.background,
            shape: BoxShape.circle,
            border: Border.all(color: tone.solid, width: 1.5),
          ),
          child: Icon(LucideIcons.x, size: 13, color: tone.foreground),
        );
      case _StepState.upcoming:
        return Container(
          width: _node,
          height: _node,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.outlineVariant, width: 2),
          ),
        );
    }
  }
}
