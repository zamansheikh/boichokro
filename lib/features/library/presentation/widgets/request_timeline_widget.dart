import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
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
    final steps = _buildSteps();
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
                const Eyebrow('Journey'),
                const SizedBox(height: 2),
                Text(
                  _summary(steps, doneCount),
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
              label: _expanded ? 'Hide journey steps' : 'Show journey steps',
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

  String _summary(List<_JourneyStep> steps, int doneCount) {
    final status = widget.request.status;
    if (status == RequestStatus.declined) return 'Ended · request declined';
    if (status == RequestStatus.cancelled) return 'Ended · request cancelled';
    if (doneCount >= steps.length) return 'Complete · reviewed and done';

    final index = steps.indexWhere((s) => s.state != _StepState.done);
    final step = steps[index];
    return 'Step ${index + 1} of ${steps.length} · ${step.title}';
  }

  List<_JourneyStep> _buildSteps() {
    final request = widget.request;
    final isSeeker = widget.isSeeker;
    final status = request.status;
    final completed = status == RequestStatus.completed;
    final accepted = status == RequestStatus.accepted || completed;

    final steps = <_JourneyStep>[
      _JourneyStep(
        title: 'Requested',
        detail:
            '${isSeeker ? 'You asked for this book' : 'A reader asked for your book'}'
            ' · ${_formatDate(request.createdAt)}',
        state: _StepState.done,
      ),
    ];

    if (status == RequestStatus.declined) {
      steps.add(
        _JourneyStep(
          title: 'Declined',
          detail: isSeeker
              ? 'The owner could not share this book this time'
              : 'You declined this request',
          state: _StepState.stopped,
        ),
      );
      return steps;
    }

    if (status == RequestStatus.cancelled) {
      steps.add(
        _JourneyStep(
          title: 'Cancelled',
          detail: isSeeker
              ? 'You cancelled this request'
              : 'The reader cancelled their request',
          state: _StepState.stopped,
        ),
      );
      return steps;
    }

    // Accepted
    steps.add(
      _JourneyStep(
        title: 'Accepted',
        detail: accepted
            ? (request.acceptedAt != null
                  ? _formatDate(request.acceptedAt!)
                  : null)
            : isSeeker
            ? 'Waiting for the owner to reply'
            : 'Waiting for your reply',
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
        title: 'Hand-off arranged',
        detail: !accepted
            ? null
            : _arrangementDetail() ??
                  (arranged ? null : 'Agree on a time and place in chat'),
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
        title: 'Both confirmed',
        detail: completed
            ? 'The book changed hands'
            : accepted
            ? _confirmationDetail()
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
        reviewDetail = 'Leave a review to close the loop';
      } else {
        reviewDetail = 'You rated ${mine.toStringAsFixed(1)}';
        if (theirs != null) {
          reviewDetail += ' · they rated you ${theirs.toStringAsFixed(1)}';
        }
      }
    }
    steps.add(
      _JourneyStep(
        title: 'Reviewed',
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

  String? _arrangementDetail() {
    final request = widget.request;
    final method = request.exchangeMethod;
    if (method == null) return null;

    final parts = <String>[method.displayName];
    if (method == ExchangeMethod.meetup) {
      if (request.meetingTime != null) {
        parts.add(DateFormat('EEE d MMM, h:mm a').format(request.meetingTime!));
      }
      final place = request.meetingLocation?.trim() ?? '';
      if (place.isNotEmpty) parts.add(place);
    } else {
      final courier = request.courierMethod?.trim() ?? '';
      if (courier.isNotEmpty) parts.add(courier);
      final tracking = request.trackingId?.trim() ?? '';
      if (tracking.isNotEmpty) parts.add('Tracking $tracking');
    }
    return parts.join(' · ');
  }

  String _confirmationDetail() {
    final request = widget.request;
    final isSeeker = widget.isSeeker;
    final mine = isSeeker ? request.seekerConfirmed : request.ownerConfirmed;
    final theirs = isSeeker ? request.ownerConfirmed : request.seekerConfirmed;
    final other = isSeeker ? 'Owner' : 'Reader';

    if (mine && theirs) return 'Both confirmed · finishing up';
    return 'You: ${mine ? 'confirmed' : 'not yet'}'
        ' · $other: ${theirs ? 'confirmed' : 'not yet'}';
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes <= 0) return 'just now';
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return DateFormat('d MMM y').format(date);
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
                        const StatusPill(
                          label: 'Now',
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
