import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/listing/gen/listing_l10n.dart';
import '../../domain/entities/book.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import 'add_book_page.dart'
    show
        BookConditionPicker,
        BookDetailsFields,
        BookFormBottomBar,
        BookFormHeading,
        BookGenrePicker,
        BookModePicker,
        confirmDiscardBookForm;

/// Edit Book Page – pre‑filled form to update an existing book's details.
class EditBookPage extends StatelessWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookBloc>(),
      child: _EditBookPageContent(book: book),
    );
  }
}

class _EditBookPageContent extends StatefulWidget {
  final Book book;
  const _EditBookPageContent({required this.book});

  @override
  State<_EditBookPageContent> createState() => _EditBookPageContentState();
}

class _EditBookPageContentState extends State<_EditBookPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;
  late List<String> _selectedGenres;
  late int _selectedCondition;
  late String _selectedMode;
  bool _textChanged = false;

  String get _initialMode =>
      widget.book.mode == BookMode.donate ? 'donate' : 'exchange';

  bool get _genresChanged {
    final original = widget.book.genres;
    return _selectedGenres.length != original.length ||
        !_selectedGenres.every(original.contains);
  }

  bool get _isDirty =>
      _textChanged ||
      _genresChanged ||
      _selectedCondition != widget.book.condition ||
      _selectedMode != _initialMode;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn ?? '');
    _descriptionController = TextEditingController(
      text: widget.book.description ?? '',
    );
    _selectedGenres = List<String>.from(widget.book.genres);
    _selectedCondition = widget.book.condition;
    _selectedMode = _initialMode;

    for (final controller in [
      _titleController,
      _authorController,
      _isbnController,
      _descriptionController,
    ]) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final book = widget.book;
    final changed =
        _titleController.text != book.title ||
        _authorController.text != book.author ||
        _isbnController.text != (book.isbn ?? '') ||
        _descriptionController.text != (book.description ?? '');
    if (changed != _textChanged && mounted) {
      setState(() => _textChanged = changed);
    }
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) {
      // Title and author, the only validated fields, sit at the top.
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: AppMotion.medium,
          curve: AppMotion.curve,
        );
      }
      return;
    }

    FocusScope.of(context).unfocus();

    final updatedBook = widget.book.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim().isEmpty
          ? null
          : _isbnController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      genres: _selectedGenres,
      condition: _selectedCondition,
      mode: _selectedMode == 'donate' ? BookMode.donate : BookMode.exchange,
      updatedAt: DateTime.now(),
    );

    context.read<BookBloc>().add(UpdateBook(updatedBook));
  }

  Future<void> _handleBack() async {
    if (context.read<BookBloc>().state is BookLoading) return;

    if (_isDirty) {
      final l = ListingL10n.of(context);
      final discard = await confirmDiscardBookForm(
        context,
        title: l.discardEditTitle,
        message: l.discardEditMessage,
      );
      if (!discard) return;
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookUpdated) {
          showAppSnack(
            context,
            ListingL10n.of(context).snackChangesSaved,
            tone: AppTone.success,
          );
          context.pop();
        } else if (state is BookError) {
          showAppSnack(context, state.message, tone: AppTone.danger);
        }
      },
      builder: (context, state) {
        final isLoading = state is BookLoading;
        final l = ListingL10n.of(context);

        return PopScope(
          canPop: !isLoading && !_isDirty,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _handleBack();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.editBookTitle),
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                tooltip: context.core.commonBack,
                onPressed: isLoading ? null : _handleBack,
              ),
            ),
            body: AbsorbPointer(
              absorbing: isLoading,
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BookSummaryCard(book: widget.book),
                      const SizedBox(height: AppSpacing.xxl),

                      BookFormHeading(title: l.detailsHeading),
                      const SizedBox(height: AppSpacing.md),
                      BookDetailsFields(
                        titleController: _titleController,
                        authorController: _authorController,
                        isbnController: _isbnController,
                        descriptionController: _descriptionController,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      BookFormHeading(
                        title: l.conditionHeading,
                        hint: l.conditionHint,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BookConditionPicker(
                        value: _selectedCondition,
                        onChanged: (value) =>
                            setState(() => _selectedCondition = value),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      BookGenrePicker(
                        selected: _selectedGenres,
                        onToggle: (genre, selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenres.add(genre);
                            } else {
                              _selectedGenres.remove(genre);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      BookFormHeading(
                        title: l.sharingHeading,
                        hint: l.sharingHint,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BookModePicker(
                        value: _selectedMode,
                        onChanged: (mode) =>
                            setState(() => _selectedMode = mode),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BookFormBottomBar(
              primaryLabel: l.actionSaveChanges,
              primaryIcon: LucideIcons.check,
              loadingLabel: l.loadingSaving,
              isLoading: isLoading,
              onPrimary: _submitUpdate,
            ),
          ),
        );
      },
    );
  }
}

/// Read-only header that shows which book is being edited.
class _BookSummaryCard extends StatelessWidget {
  const _BookSummaryCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      child: Row(
        children: [
          BookCover(imageUrl: book.coverUrl, width: 60, title: book.title),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(ListingL10n.of(context).editingEyebrow),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusPill.book(book.status, dense: true),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ListingL10n.of(context).editSummaryNote,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
