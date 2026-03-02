import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/book.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';

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
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;
  late List<String> _selectedGenres;
  late int _selectedCondition;
  late String _selectedMode;

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
    _selectedMode = widget.book.mode == BookMode.donate ? 'donate' : 'exchange';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) return;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is BookError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BookLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Book'),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: isLoading ? null : _submitUpdate,
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Title ──────────────────────────────────────
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            if (v.trim().length >
                                AppConstants.maxBookTitleLength) {
                              return 'Title is too long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Author ─────────────────────────────────────
                        TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Author *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter author name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── ISBN ───────────────────────────────────────
                        TextFormField(
                          controller: _isbnController,
                          decoration: const InputDecoration(
                            labelText: 'ISBN (optional)',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // ── Description ────────────────────────────────
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          maxLength: AppConstants.maxBookDescriptionLength,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 8),

                        // ── Genres ─────────────────────────────────────
                        Text(
                          'Genres',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: AppConstants.bookGenres.map((genre) {
                            final isSelected = _selectedGenres.contains(genre);
                            return FilterChip(
                              label: Text(genre),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedGenres.add(genre);
                                  } else {
                                    _selectedGenres.remove(genre);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // ── Condition ──────────────────────────────────
                        Text(
                          'Condition',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...List.generate(AppConstants.bookConditions.length, (
                          index,
                        ) {
                          return RadioListTile<int>(
                            dense: true,
                            title: Text(AppConstants.bookConditions[index]),
                            value: index,
                            groupValue: _selectedCondition,
                            onChanged: (v) =>
                                setState(() => _selectedCondition = v!),
                          );
                        }),
                        const SizedBox(height: 8),

                        // ── Mode ───────────────────────────────────────
                        Text(
                          'Sharing Mode',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _ModeCard(
                          icon: Icons.volunteer_activism_outlined,
                          title: 'Donate',
                          description: 'Give away this book for free',
                          isSelected: _selectedMode == 'donate',
                          onTap: () => setState(() => _selectedMode = 'donate'),
                        ),
                        const SizedBox(height: 12),
                        _ModeCard(
                          icon: Icons.swap_horiz,
                          title: 'Exchange',
                          description: 'Swap for another book',
                          isSelected: _selectedMode == 'exchange',
                          onTap: () =>
                              setState(() => _selectedMode = 'exchange'),
                        ),
                        const SizedBox(height: 32),

                        // ── Save Button ────────────────────────────────
                        FilledButton.icon(
                          onPressed: isLoading ? null : _submitUpdate,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save Changes'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
