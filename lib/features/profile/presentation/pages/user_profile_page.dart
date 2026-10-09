import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/firebase_service.dart';
import '../../../../core/utils/extensions.dart';
import '../../../discover/domain/entities/book.dart';
import '../../../discover/domain/entities/user.dart';
import '../../../discover/domain/usecases/book_usecases.dart';
import '../../../discover/domain/usecases/user_usecases.dart';
import '../../../library/domain/entities/request.dart';
import '../../../library/domain/usecases/get_requests_by_owner_usecase.dart';
import '../../../library/domain/usecases/get_requests_by_seeker_usecase.dart';

/// Route for [UserProfilePage]. Kept next to the page so every entry point
/// builds the same path.
String userProfilePath(String userId) => '/user/$userId';

/// Public profile of another reader: who they are, how other readers rate
/// them, and the books on their shelf.
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

/// A rating this reader received after a completed hand-off.
class _Review {
  const _Review({
    required this.rating,
    required this.text,
    required this.reviewerId,
    required this.date,
    required this.wasOwner,
  });

  final double rating;
  final String? text;
  final String reviewerId;
  final DateTime date;

  /// True when the profile owner was the one giving the book.
  final bool wasOwner;
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<User?> _user;
  late Future<List<Book>> _books;
  late Future<List<_Review>> _reviews;
  final Map<String, Future<User?>> _reviewers = {};

  bool get _isMe =>
      getIt<FirebaseService>().auth.currentUser?.uid == widget.userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _user = _fetchUser(widget.userId);
    _books = _fetchBooks();
    _reviews = _fetchReviews();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait<void>([_user, _books, _reviews]);
  }

  Future<User?> _fetchUser(String id) async {
    final result = await getIt<GetUserByIdUseCase>()(GetUserByIdParams(id));
    return result.fold((_) => null, (user) => user);
  }

  Future<List<Book>> _fetchBooks() async {
    final result = await getIt<GetBooksByOwnerUseCase>()(
      GetBooksByOwnerParams(widget.userId),
    );
    final books = result.fold((_) => <Book>[], (books) => List.of(books));
    // Books that can still be requested come first.
    books.sort((a, b) {
      final byStatus = a.status.index.compareTo(b.status.index);
      return byStatus != 0 ? byStatus : b.createdAt.compareTo(a.createdAt);
    });
    return books;
  }

  /// Ratings live on the request: `seekerRating` is what the seeker gave the
  /// owner, `ownerRating` what the owner gave the seeker.
  Future<List<_Review>> _fetchReviews() async {
    final id = widget.userId;
    final results = await Future.wait([
      getIt<GetRequestsByOwnerUseCase>()(GetRequestsByOwnerParams(id)),
      getIt<GetRequestsBySeekerUseCase>()(GetRequestsBySeekerParams(id)),
    ]);
    final asOwner = results[0].fold((_) => <BookRequest>[], (r) => r);
    final asSeeker = results[1].fold((_) => <BookRequest>[], (r) => r);

    final reviews = <_Review>[
      for (final r in asOwner)
        if (r.seekerRating != null)
          _Review(
            rating: r.seekerRating!,
            text: r.seekerReview,
            reviewerId: r.seekerId,
            date: r.updatedAt,
            wasOwner: true,
          ),
      for (final r in asSeeker)
        if (r.ownerRating != null)
          _Review(
            rating: r.ownerRating!,
            text: r.ownerReview,
            reviewerId: r.ownerId,
            date: r.updatedAt,
            wasOwner: false,
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: _user,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _ProfileScaffold(child: AppLoading());
          }
          final user = snapshot.data;
          if (user == null) {
            return _ProfileScaffold(
              child: AppErrorState(
                title: 'Reader not found',
                message: 'This profile could not be loaded right now.',
                onRetry: () => setState(_load),
              ),
            );
          }
          return _buildProfile(context, user);
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    final firstName = user.name.trim().split(RegExp(r'\s+')).first;
    final shelfTitle = _isMe
        ? 'Your shelf'
        : firstName.isEmpty
        ? 'On their shelf'
        : "On $firstName's shelf";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
          ),
          children: [
            _Header(user: user, books: _books),
            if (_isMe)
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  0,
                ),
                child: AppBanner(
                  icon: LucideIcons.eye,
                  tone: AppTone.neutral,
                  message: 'This is how other readers see your profile.',
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: _TrustCard(user: user),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _ShelfSection(title: shelfTitle, books: _books),
            const SizedBox(height: AppSpacing.xxxl),
            _ReviewsSection(
              user: user,
              reviews: _reviews,
              reviewerOf: (id) => _reviewers[id] ??= _fetchUser(id),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain scaffold body with a back button, for loading and error states.
class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Brand band with the avatar overlapping its lower edge, then name, facts
/// and the three headline numbers.
class _Header extends StatelessWidget {
  const _Header({required this.user, required this.books});

  final User user;
  final Future<List<Book>> books;

  static const double _bandHeight = 148;
  static const double _avatarRadius = 52;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    final joined = DateFormat('MMMM yyyy').format(user.createdAt);

    return Column(
      children: [
        SizedBox(
          height: top + _bandHeight + _avatarRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: top + _bandHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [palette.heroStart, palette.heroEnd],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadius.xxl),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppRadius.xxl),
                    ),
                    child: CustomPaint(
                      painter: _BandRingsPainter(
                        color: palette.onHero.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: top + AppSpacing.xs,
                left: AppSpacing.sm,
                child: IconButton(
                  tooltip: 'Back',
                  icon: Icon(LucideIcons.arrowLeft, color: palette.onHero),
                  onPressed: () => context.pop(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: UserAvatar(
                      photoUrl: user.photoUrl,
                      name: user.name,
                      radius: _avatarRadius,
                      verified: user.verifiedBadge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            children: [
              Text(
                user.name.trim().isEmpty ? 'A reader' : user.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Reader since $joined',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (user.verifiedBadge) ...[
                const SizedBox(height: AppSpacing.md),
                const StatusPill(
                  label: 'Verified reader',
                  icon: LucideIcons.badgeCheck,
                  tone: AppTone.success,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      value: user.ratingAvg > 0
                          ? user.ratingAvg.toStringAsFixed(1)
                          : '–',
                      label: 'Rating',
                      leading: Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: palette.star,
                      ),
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(
                    child: _Stat(
                      value: '${user.totalSwaps}',
                      label: user.totalSwaps == 1 ? 'Hand-off' : 'Hand-offs',
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(
                    child: FutureBuilder<List<Book>>(
                      future: books,
                      builder: (context, snapshot) => _Stat(
                        value: snapshot.hasData
                            ? '${snapshot.data!.length}'
                            : '·',
                        label: snapshot.data?.length == 1 ? 'Book' : 'Books',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Faint wheel rings on the brand band, echoing the splash screen.
class _BandRingsPainter extends CustomPainter {
  _BandRingsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    final center = Offset(size.width / 2, size.height);
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, 46.0 + i * 34, paint);
    }
  }

  @override
  bool shouldRepaint(_BandRingsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.leading});

  final String value;
  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 4)],
            Text(value, style: context.text.headlineSmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Plain-language reasons to trust (or be careful with) this reader.
class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final rows = <({IconData icon, AppTone tone, String title, String detail})>[
      if (user.verifiedBadge)
        (
          icon: LucideIcons.badgeCheck,
          tone: AppTone.success,
          title: 'Verified reader',
          detail: 'This reader carries the verified badge.',
        )
      else
        (
          icon: LucideIcons.shieldQuestion,
          tone: AppTone.neutral,
          title: 'Not verified yet',
          detail: 'Meet in a busy public place, as with any new reader.',
        ),
      if (user.totalSwaps > 0)
        (
          icon: LucideIcons.handshake,
          tone: AppTone.primary,
          title: user.totalSwaps == 1
              ? '1 completed hand-off'
              : '${user.totalSwaps} completed hand-offs',
          detail: 'Books given, received or swapped through the app.',
        )
      else
        (
          icon: LucideIcons.sprout,
          tone: AppTone.exchange,
          title: 'New to the circle',
          detail: 'No completed hand-offs yet. Everyone starts here.',
        ),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(indent: 52),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.tone(rows[i].tone).background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      rows[i].icon,
                      size: 18,
                      color: context.tone(rows[i].tone).foreground,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].title, style: context.text.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          rows[i].detail,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The reader's books as a horizontally scrolling shelf.
class _ShelfSection extends StatelessWidget {
  const _ShelfSection({required this.title, required this.books});

  final String title;
  final Future<List<Book>> books;

  static const double _coverWidth = 104;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: books,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final list = snapshot.data ?? const <Book>[];
        final available = list
            .where((b) => b.status == BookStatus.available)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              title: title,
              subtitle: loading
                  ? null
                  : list.isEmpty
                  ? null
                  : available == 0
                  ? 'Nothing available right now'
                  : available == 1
                  ? '1 book you can ask for'
                  : '$available books you can ask for',
            ),
            const SizedBox(height: AppSpacing.lg),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Row(
                  children: [
                    Skeleton(width: _coverWidth, height: 156),
                    SizedBox(width: AppSpacing.lg),
                    Skeleton(width: _coverWidth, height: 156),
                    SizedBox(width: AppSpacing.lg),
                    Skeleton(width: _coverWidth, height: 156),
                  ],
                ),
              )
            else if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: AppCard(
                  child: AppEmptyState(
                    compact: true,
                    tone: AppTone.neutral,
                    icon: LucideIcons.library,
                    title: 'No books on the shelf',
                    message: 'This reader has not shared a book yet.',
                  ),
                ),
              )
            else
              SizedBox(
                height: 252,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) =>
                      _ShelfBook(book: list[index], width: _coverWidth),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShelfBook extends StatelessWidget {
  const _ShelfBook({required this.book, required this.width});

  final Book book;
  final double width;

  @override
  Widget build(BuildContext context) {
    final available = book.status == BookStatus.available;

    return InkWell(
      onTap: () => context.push('/book/${book.id}'),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: available ? 1 : 0.55,
              child: BookCover(
                imageUrl: book.coverUrl,
                title: book.title,
                width: width,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onSurface,
                height: 1.3,
              ),
            ),
            const Spacer(),
            available
                ? StatusPill.mode(book.mode, dense: true)
                : StatusPill.book(book.status, dense: true),
          ],
        ),
      ),
    );
  }
}

/// Ratings and notes from readers this person has exchanged books with.
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({
    required this.user,
    required this.reviews,
    required this.reviewerOf,
  });

  final User user;
  final Future<List<_Review>> reviews;
  final Future<User?> Function(String id) reviewerOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: FutureBuilder<List<_Review>>(
        future: reviews,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final list = snapshot.data ?? const <_Review>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'What readers say',
                subtitle: loading || list.isEmpty
                    ? null
                    : list.length == 1
                    ? '1 review after a hand-off'
                    : '${list.length} reviews after hand-offs',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (loading)
                const Skeleton(height: 96, radius: AppRadius.xl)
              else if (list.isEmpty)
                AppCard(
                  child: AppEmptyState(
                    compact: true,
                    tone: AppTone.neutral,
                    icon: LucideIcons.messageSquareQuote,
                    title: 'No reviews yet',
                    message: user.totalSwaps > 0
                        ? 'Readers have not left a note about their hand-offs.'
                        : 'Reviews appear after a completed hand-off.',
                  ),
                )
              else
                for (int i = 0; i < list.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  _ReviewCard(
                    review: list[i],
                    reviewer: reviewerOf(list[i].reviewerId),
                  ),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.reviewer});

  final _Review review;
  final Future<User?> reviewer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = review.text?.trim() ?? '';
    final filled = review.rating.round().clamp(0, 5);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: i < filled
                      ? context.palette.star
                      : colors.outlineVariant,
                ),
              const Spacer(),
              Text(
                review.date.toRelativeTime(),
                style: context.text.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              style: context.text.bodyLarge?.copyWith(
                color: colors.onSurface,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<User?>(
            future: reviewer,
            builder: (context, snapshot) {
              final who = snapshot.data;
              final name = who?.name ?? 'A reader';
              return InkWell(
                onTap: who == null
                    ? null
                    : () => context.push(userProfilePath(who.id)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      UserAvatar(
                        photoUrl: who?.photoUrl,
                        name: who?.name,
                        radius: 12,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          review.wasOwner
                              ? '$name · received a book'
                              : '$name · gave a book',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
