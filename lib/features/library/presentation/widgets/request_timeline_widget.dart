import 'package:flutter/material.dart';
import '../../domain/entities/request.dart';

class RequestTimelineWidget extends StatelessWidget {
  final BookRequest request;
  final bool isSeeker;

  const RequestTimelineWidget({
    super.key,
    required this.request,
    required this.isSeeker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _getTimelineSteps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Progress Timeline',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isCompleted
                              ? theme.colorScheme.primary
                              : step.isActive
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: step.isCompleted || step.isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: step.isCompleted
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: theme.colorScheme.onPrimary,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: step.isCompleted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: step.isCompleted || step.isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: step.isCompleted || step.isActive
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (step.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              step.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
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
          }),
        ],
      ),
    );
  }

  List<TimelineStep> _getTimelineSteps() {
    final status = request.status;

    return [
      TimelineStep(
        title: 'Step 1: Request Sent',
        subtitle: _formatDate(request.createdAt),
        isCompleted: true,
        isActive: false,
      ),
      TimelineStep(
        title:
            status == RequestStatus.accepted ||
                status == RequestStatus.completed
            ? 'Step 2: Approval Received ✓'
            : status == RequestStatus.declined
            ? 'Step 2: Request Declined'
            : 'Step 2: Waiting Approval',
        subtitle: request.acceptedAt != null
            ? _formatDate(request.acceptedAt!)
            : null,
        isCompleted:
            status == RequestStatus.accepted ||
            status == RequestStatus.completed,
        isActive: status == RequestStatus.pending,
      ),
      if (status == RequestStatus.accepted || status == RequestStatus.completed)
        TimelineStep(
          title: status == RequestStatus.completed
              ? 'Step 3: Exchange Completed ✓'
              : 'Step 3: Exchange Stage',
          subtitle: _getCompletionDetails(),
          isCompleted: status == RequestStatus.completed,
          isActive: status == RequestStatus.accepted,
        ),
    ];
  }

  String _getCompletionDetails() {
    if (request.status == RequestStatus.completed) {
      return 'Exchange completed successfully';
    }

    final confirmations = <String>[];
    if (request.ownerConfirmed) {
      confirmations.add('Owner confirmed ✓');
    } else {
      confirmations.add('Owner: pending');
    }
    if (request.seekerConfirmed) {
      confirmations.add('Requester confirmed ✓');
    } else {
      confirmations.add('Requester: pending');
    }

    if (request.ownerConfirmed && request.seekerConfirmed) {
      return 'Both confirmed - completing...';
    }

    return confirmations.join(' • ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Just now';
        }
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class TimelineStep {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isActive;

  TimelineStep({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });
}
