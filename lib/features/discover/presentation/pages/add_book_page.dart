import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design/design.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/book.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import '../widgets/location_picker_widget.dart';

/// Add Book Page - guided three-step flow: cover, details, sharing.
class AddBookPage extends StatelessWidget {
  const AddBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookBloc>(),
      child: const _AddBookPageContent(),
    );
  }
}

class _AddBookPageContent extends StatefulWidget {
  const _AddBookPageContent();

  @override
  State<_AddBookPageContent> createState() => _AddBookPageContentState();
}

class _AddBookPageContentState extends State<_AddBookPageContent> {
  static const List<String> _stepLabels = ['Cover', 'Details', 'Sharing'];

  int _currentStep = 0;

  // Step 1: Cover
  File? _bookCoverImage;
  bool _isScanning = false;
  bool _scanFinished = false;
  String? _detectedIsbn;
  int _scanRequest = 0;
  bool _coverError = false;

  // Step 2: Details
  final _formKey = GlobalKey<FormState>();
  final _detailsScrollController = ScrollController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedGenres = [];
  int _selectedCondition = 2; // Default: Good
  bool _hasText = false;

  // Step 3: Sharing
  String _selectedMode = 'donate'; // donate or exchange
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _locationError = false;
  final _locationKey = GlobalKey();

  List<TextEditingController> get _textControllers => [
    _titleController,
    _authorController,
    _isbnController,
    _descriptionController,
  ];

  bool get _isDirty =>
      _bookCoverImage != null ||
      _hasText ||
      _selectedGenres.isNotEmpty ||
      _selectedCondition != 2 ||
      _selectedMode != 'donate' ||
      _selectedLocation != null;

  @override
  void initState() {
    super.initState();
    for (final controller in _textControllers) {
      controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _detailsScrollController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textControllers.any((c) => c.text.trim().isNotEmpty);
    if (hasText != _hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  void _goToStep(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _currentStep = step);
  }

  void _nextStep() {
    if (_currentStep == 0 && _bookCoverImage == null) {
      _flagMissingCover();
      return;
    }

    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      _scrollDetailsToTop();
      return;
    }

    if (_currentStep < 2) {
      _goToStep(_currentStep + 1);
    } else {
      _submitBook();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _flagMissingCover() {
    setState(() => _coverError = true);
    showAppSnack(
      context,
      'Add a photo of the cover to continue',
      tone: AppTone.warning,
    );
  }

  void _scrollDetailsToTop() {
    if (!_detailsScrollController.hasClients) return;
    _detailsScrollController.animateTo(
      0,
      duration: AppMotion.medium,
      curve: AppMotion.curve,
    );
  }

  Future<void> _handleBack() async {
    if (context.read<BookBloc>().state is BookLoading) return;

    if (_currentStep > 0) {
      _previousStep();
      return;
    }

    if (_isDirty) {
      final discard = await confirmDiscardBookForm(
        context,
        title: 'Discard this book?',
        message: 'The photo and details you added won\'t be saved.',
      );
      if (!discard) return;
    }
    if (!mounted) return;
    context.pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile;
    try {
      pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        showAppSnack(
          context,
          source == ImageSource.camera
              ? 'We couldn\'t open the camera. Check the camera permission '
                    'and try again.'
              : 'We couldn\'t open your gallery. Check the photos permission '
                    'and try again.',
          tone: AppTone.danger,
        );
      }
      return;
    }

    if (pickedFile != null && mounted) {
      final file = File(pickedFile.path);
      setState(() {
        _bookCoverImage = file;
        _coverError = false;
        _scanFinished = false;
        _detectedIsbn = null;
        _scanRequest++;
      });

      // Optionally scan for ISBN
      if (source == ImageSource.camera) {
        _scanForISBN();
      }
    }
  }

  Future<void> _scanForISBN() async {
    final image = _bookCoverImage;
    if (image == null) return;

    final request = _scanRequest;
    setState(() => _isScanning = true);

    final textRecognizer = TextRecognizer();
    String? detected;
    try {
      final inputImage = InputImage.fromFile(image);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Look for ISBN pattern (ISBN-10 or ISBN-13)
      final isbnPattern = RegExp(
        r'(?:ISBN(?:-1[03])?:?\s*)?((?:\d{1,5}[-\s]?){3,5}\d{1,7})',
      );

      for (TextBlock block in recognizedText.blocks) {
        final match = isbnPattern.firstMatch(block.text);
        if (match != null) {
          final isbn = match.group(1)?.replaceAll(RegExp(r'[-\s]'), '') ?? '';
          if (isbn.length >= 10) {
            detected = isbn;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning ISBN: $e');
    } finally {
      try {
        await textRecognizer.close();
      } catch (e) {
        debugPrint('Error closing text recognizer: $e');
      }
    }

    // A newer photo replaced this one while it was being read.
    if (!mounted || request != _scanRequest) return;

    if (detected != null) {
      _isbnController.text = detected;
    }
    setState(() {
      _isScanning = false;
      _scanFinished = true;
      _detectedIsbn = detected;
    });
  }

  void _submitBook() {
    if (_bookCoverImage == null) {
      _goToStep(0);
      _flagMissingCover();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _goToStep(1);
      _scrollDetailsToTop();
      return;
    }

    // Check if location is selected
    if (_selectedLocation == null) {
      setState(() => _locationError = true);
      showAppSnack(
        context,
        'Choose a pickup location to continue',
        tone: AppTone.warning,
      );
      final locationContext = _locationKey.currentContext;
      if (locationContext != null) {
        Scrollable.ensureVisible(
          locationContext,
          duration: AppMotion.medium,
          curve: AppMotion.curve,
          alignment: 0.2,
        );
      }
      return;
    }

    final bookBloc = context.read<BookBloc>();

    // Create book with all the collected data using the new event
    bookBloc.add(
      AddBookWithImage(
        coverImage: _bookCoverImage!,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        genres: _selectedGenres,
        condition: AppConstants.bookConditions[_selectedCondition],
        mode: _selectedMode,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      ),
    );
  }

  void _openLocationPicker() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          initialLocation: _selectedLocation,
          initialAddress: _selectedAddress.isEmpty ? null : _selectedAddress,
          onLocationSelected: (location, address) {
            setState(() {
              _selectedLocation = location;
              _selectedAddress = address;
              _locationError = false;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookAdded) {
          showAppSnack(
            context,
            'Your book is on the shelf for nearby readers',
            tone: AppTone.success,
          );
          context.pop();
        } else if (state is BookError) {
          showAppSnack(context, state.message, tone: AppTone.danger);
        }
      },
      builder: (context, state) {
        final isLoading = state is BookLoading;
        final isLastStep = _currentStep == 2;

        return PopScope(
          canPop: !isLoading && _currentStep == 0 && !_isDirty,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _handleBack();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add a book'),
              leading: IconButton(
                icon: Icon(
                  _currentStep == 0 ? LucideIcons.x : LucideIcons.arrowLeft,
                ),
                tooltip: _currentStep == 0 ? 'Close' : 'Back',
                onPressed: isLoading ? null : _handleBack,
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.sm,
                  ),
                  child: _StepIndicator(
                    labels: _stepLabels,
                    current: _currentStep,
                    onStepTap: isLoading ? null : _goToStep,
                  ),
                ),
                Divider(height: 1, color: context.colors.outlineVariant),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: isLoading,
                    child: IndexedStack(
                      index: _currentStep,
                      children: [
                        _StepFade(
                          active: _currentStep == 0,
                          child: _buildCoverStep(),
                        ),
                        _StepFade(
                          active: _currentStep == 1,
                          child: _buildDetailsStep(),
                        ),
                        _StepFade(
                          active: _currentStep == 2,
                          child: _buildSharingStep(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BookFormBottomBar(
              primaryLabel: isLastStep ? 'Share this book' : 'Continue',
              primaryIcon: isLastStep ? LucideIcons.check : null,
              loadingLabel: 'Sharing your book…',
              isLoading: isLoading,
              onPrimary: _nextStep,
              secondaryLabel: _currentStep > 0 ? 'Back' : null,
              onSecondary: _previousStep,
            ),
          ),
        );
      },
    );
  }

  // ── Step 1: Cover ────────────────────────────────────────────────────────

  Widget _buildCoverStep() {
    const coverWidth = 184.0;
    final image = _bookCoverImage;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxl,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(
            step: 1,
            title: 'Start with the cover',
            subtitle:
                'A clear photo of the front helps readers recognise the book.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: image != null
                ? _LocalBookCover(
                    file: image,
                    width: coverWidth,
                    isScanning: _isScanning,
                  )
                : _CoverDropZone(
                    width: coverWidth,
                    hasError: _coverError,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
          ),
          if (_coverError && image == null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'A cover photo is required',
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          FilledButton.tonalIcon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(LucideIcons.camera, size: 18),
            label: Text(image == null ? 'Snap the cover' : 'Retake photo'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(LucideIcons.images, size: 18),
            label: const Text('Choose from gallery'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildScanBanner(),
        ],
      ),
    );
  }

  Widget _buildScanBanner() {
    final isbn = _detectedIsbn;
    if (isbn != null) {
      return AppBanner(
        tone: AppTone.success,
        icon: LucideIcons.circleCheck,
        title: 'ISBN filled in for you',
        message: 'We read $isbn from the photo. You can check it next.',
      );
    }
    if (_isScanning) {
      return const AppBanner(
        tone: AppTone.primary,
        icon: LucideIcons.scanText,
        message: 'Reading the photo for an ISBN…',
      );
    }
    if (_scanFinished) {
      return const AppBanner(
        tone: AppTone.neutral,
        icon: LucideIcons.scanText,
        message:
            'No ISBN spotted in this photo. You can type it in on the next '
            'step, or leave it out.',
      );
    }
    return const AppBanner(
      tone: AppTone.primary,
      icon: LucideIcons.scanText,
      message:
          'When you take the photo with the camera, we look for an ISBN '
          'in it and fill it in for you.',
    );
  }

  // ── Step 2: Details ──────────────────────────────────────────────────────

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      controller: _detailsScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxl,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              step: 2,
              title: 'Tell readers about it',
              subtitle: 'The title and author are all you need to continue.',
            ),
            const SizedBox(height: AppSpacing.xxl),
            BookDetailsFields(
              titleController: _titleController,
              authorController: _authorController,
              isbnController: _isbnController,
              descriptionController: _descriptionController,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const BookFormHeading(
              title: 'Condition',
              hint: 'Be honest, it builds trust.',
            ),
            const SizedBox(height: AppSpacing.md),
            BookConditionPicker(
              value: _selectedCondition,
              onChanged: (value) => setState(() => _selectedCondition = value),
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
          ],
        ),
      ),
    );
  }

  // ── Step 3: Sharing ──────────────────────────────────────────────────────

  Widget _buildSharingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxl,
        AppSpacing.page,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(
            step: 3,
            title: 'How will you share it?',
            subtitle:
                'Choose what you would like in return, and where to meet.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          BookModePicker(
            value: _selectedMode,
            onChanged: (mode) => setState(() => _selectedMode = mode),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const BookFormHeading(
            title: 'Pickup location',
            hint: 'Where readers can collect the book.',
          ),
          const SizedBox(height: AppSpacing.md),
          _PickupLocationCard(
            key: _locationKey,
            location: _selectedLocation,
            address: _selectedAddress,
            hasError: _locationError,
            onTap: _openLocationPicker,
          ),
          if (_locationError && _selectedLocation == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Text(
                'A pickup location is required',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const AppBanner(
            tone: AppTone.neutral,
            icon: LucideIcons.info,
            message:
                'Nearby readers see this spot on the map, so a public place '
                'such as a campus gate or a café works well.',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Private pieces of the add flow
// ═══════════════════════════════════════════════════════════════════════════

/// Fades a step in when it becomes the visible child of the [IndexedStack].
class _StepFade extends StatelessWidget {
  const _StepFade({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: AppMotion.medium,
      curve: AppMotion.curve,
      child: child,
    );
  }
}

/// "1 Cover — 2 Details — 3 Sharing" progress row. Finished steps can be
/// tapped to go back to them.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.labels,
    required this.current,
    required this.onStepTap,
  });

  final List<String> labels;
  final int current;
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Three labels share one row, so large font settings are capped here to
    // keep the row inside a 360dp screen.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Builder(
        builder: (context) => Row(
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.medium,
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    color: i <= current
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
              _buildStep(context, i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int step) {
    final colors = context.colors;
    final isActive = step == current;
    final isCompleted = step < current;
    final canTap = isCompleted && onStepTap != null;

    return Semantics(
      label: 'Step ${step + 1} of ${labels.length}, ${labels[step]}',
      selected: isActive,
      button: canTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: canTap ? () => onStepTap!(step) : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppMotion.medium,
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive || isCompleted
                      ? colors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? colors.primary
                        : colors.outline,
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? Icon(LucideIcons.check, size: 14, color: colors.onPrimary)
                    : Text(
                        '${step + 1}',
                        style: context.text.labelMedium?.copyWith(
                          color: isActive
                              ? colors.onPrimary
                              : colors.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                labels[step],
                style: context.text.labelMedium?.copyWith(
                  color: isActive || isCompleted
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eyebrow, serif title and supporting line that open each step.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow('Step $step of 3', color: context.colors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: context.text.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Same silhouette as the design system's `BookCover`: tight spine edge on
/// the left, rounder fore-edge on the right.
BorderRadius _bookRadius(double width) {
  final outer = Radius.circular(width * 0.08);
  final spine = Radius.circular(width * 0.03);
  return BorderRadius.only(
    topLeft: spine,
    bottomLeft: spine,
    topRight: outer,
    bottomRight: outer,
  );
}

/// Empty, book-shaped target that invites the first photo.
class _CoverDropZone extends StatelessWidget {
  const _CoverDropZone({
    required this.width,
    required this.hasError,
    required this.onTap,
  });

  final double width;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = _bookRadius(width);

    return Semantics(
      button: true,
      label: 'Snap the cover',
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: hasError ? colors.error : colors.outline,
            width: hasError ? 1.8 : 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: width * 1.5,
            child: Stack(
              children: [
                // Spine crease
                Positioned(
                  left: width * 0.075,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: colors.outlineVariant),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.16,
                      AppSpacing.lg,
                      width * 0.1,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.camera,
                            size: 24,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Snap the cover',
                          textAlign: TextAlign.center,
                          style: context.text.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Front of the book, in good light',
                          textAlign: TextAlign.center,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A locally picked photo drawn as a physical book, matching `BookCover`.
class _LocalBookCover extends StatelessWidget {
  const _LocalBookCover({
    required this.file,
    required this.width,
    this.isScanning = false,
  });

  final File file;
  final double width;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = width * 1.5;
    final radius = _bookRadius(width);
    final shade = colors.shadow;
    final sheen = context.palette.onHero;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.palette.softShadow,
            blurRadius: width * 0.18,
            offset: Offset(width * 0.04, width * 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, _, _) => ColoredBox(
                color: colors.surfaceContainerHighest,
                child: Icon(
                  LucideIcons.bookOpen,
                  size: width * 0.3,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            // Spine crease and page-edge sheen.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0, 0.035, 0.075, 0.13, 1],
                  colors: [
                    shade.withValues(alpha: 0.2),
                    shade.withValues(alpha: 0.05),
                    sheen.withValues(alpha: 0.2),
                    sheen.withValues(alpha: 0),
                    shade.withValues(alpha: 0.07),
                  ],
                ),
              ),
            ),
            if (isScanning)
              ColoredBox(
                color: colors.scrim.withValues(alpha: 0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: sheen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Reading the cover…',
                      style: context.text.labelLarge?.copyWith(color: sheen),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pickup location summary: an invitation when empty, a map preview and the
/// address once a spot is chosen. Tapping opens the location picker.
class _PickupLocationCard extends StatelessWidget {
  const _PickupLocationCard({
    super.key,
    required this.location,
    required this.address,
    required this.hasError,
    required this.onTap,
  });

  final LatLng? location;
  final String address;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spot = location;

    if (spot == null) {
      return AppCard(
        onTap: onTap,
        borderColor: hasError ? colors.error : null,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.mapPin,
                size: 20,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose a spot', style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Search, tap the map or use your current location.',
                    style: context.text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocationPreviewMap(location: spot),
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, size: 18, color: colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    address.isEmpty ? formatLatLng(spot) : address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Change',
                  style: context.text.labelLarge?.copyWith(
                    color: colors.primary,
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

// ═══════════════════════════════════════════════════════════════════════════
// Book form pieces shared by the add and edit pages
// ═══════════════════════════════════════════════════════════════════════════

/// Asks whether to throw away unsaved input. Resolves to true to discard.
Future<bool> confirmDiscardBookForm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep editing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: dialogContext.colors.error,
          ),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return discard ?? false;
}

/// Serif label that introduces a group of controls inside the book form.
class BookFormHeading extends StatelessWidget {
  const BookFormHeading({
    super.key,
    required this.title,
    this.hint,
    this.trailing,
  });

  final String title;
  final String? hint;

  /// Short status shown on the right, e.g. "3 selected".
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final muted = context.text.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.titleMedium),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(hint!, style: muted),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          Text(trailing!, style: muted?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }
}

/// Title, author, ISBN and description inputs. Must sit inside a [Form].
class BookDetailsFields extends StatelessWidget {
  const BookDetailsFields({
    super.key,
    required this.titleController,
    required this.authorController,
    required this.isbnController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController authorController;
  final TextEditingController isbnController;
  final TextEditingController descriptionController;

  // Keeps the focused field clear of the keyboard and the pinned button.
  static const EdgeInsets _scrollPadding = EdgeInsets.only(
    top: AppSpacing.xl,
    bottom: 120,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'As printed on the cover',
            prefixIcon: Icon(LucideIcons.bookOpen, size: 20),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          scrollPadding: _scrollPadding,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            if (value.trim().length > AppConstants.maxBookTitleLength) {
              return 'Title is too long';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: authorController,
          decoration: const InputDecoration(
            labelText: 'Author',
            hintText: 'Who wrote it?',
            prefixIcon: Icon(LucideIcons.userRound, size: 20),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          scrollPadding: _scrollPadding,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the author\'s name';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: isbnController,
          decoration: const InputDecoration(
            labelText: 'ISBN (optional)',
            hintText: 'The number above the barcode',
            prefixIcon: Icon(LucideIcons.barcode, size: 20),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          scrollPadding: _scrollPadding,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'What is it about? Any notes, marks or missing pages?',
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 6,
          maxLength: AppConstants.maxBookDescriptionLength,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          scrollPadding: _scrollPadding,
        ),
      ],
    );
  }
}

/// Five selectable rows, Like New to Worn, each with a one-line explanation.
///
/// [value] is the stored condition index (0 = Like New … 4 = Worn).
class BookConditionPicker extends StatelessWidget {
  const BookConditionPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const List<String> _explanations = [
    'Looks unread, with no marks or creases.',
    'Read gently. Clean pages, barely any wear.',
    'A well-kept copy with light wear.',
    'Clear wear, or some notes and highlights.',
    'Heavily used, but still readable.',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = AppConstants.bookConditions.length;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < count; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.outlineVariant),
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: i == value,
              child: InkWell(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  color: i == value
                      ? colors.primaryContainer.withValues(alpha: 0.55)
                      : Colors.transparent,
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      _RadioDot(selected: i == value, color: colors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.bookConditions[i],
                              style: context.text.titleSmall,
                            ),
                            if (i < _explanations.length) ...[
                              const SizedBox(height: 2),
                              Text(
                                _explanations[i],
                                style: context.text.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ExcludeSemantics(
                        child: ConditionMeter(condition: i, showLabel: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Genre chips with a heading that shows how many are selected.
///
/// The parent owns the list and applies [onToggle] inside `setState`.
class BookGenrePicker extends StatelessWidget {
  const BookGenrePicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<String> selected;
  final void Function(String genre, bool selected) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BookFormHeading(
          title: 'Genres',
          hint: 'Pick any that fit, so readers can find it.',
          trailing: selected.isEmpty
              ? 'Optional'
              : '${selected.length} selected',
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final genre in AppConstants.bookGenres)
              FilterChip(
                label: Text(genre),
                selected: selected.contains(genre),
                onSelected: (value) => onToggle(genre, value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Two large choice cards: give the book away, or swap it for another.
///
/// [value] is the mode string the book bloc expects: `donate` or `exchange`.
class BookModePicker extends StatelessWidget {
  const BookModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeCard(
          mode: BookMode.donate,
          title: 'Give it away',
          description: 'Free for any reader who asks for it.',
          selected: value == 'donate',
          onTap: () => onChanged('donate'),
        ),
        const SizedBox(height: AppSpacing.md),
        _ModeCard(
          mode: BookMode.exchange,
          title: 'Swap for another book',
          description: 'Readers offer one of their books in return.',
          selected: value == 'exchange',
          onTap: () => onChanged('exchange'),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final BookMode mode;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = context.tone(mode.tone);
    final radius = BorderRadius.circular(AppRadius.xl);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            constraints: const BoxConstraints(minHeight: 84),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: selected ? tone.background : colors.surface,
              borderRadius: radius,
              border: Border.all(
                color: selected ? tone.solid : colors.outlineVariant,
                width: selected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? colors.surface : tone.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(mode.icon, size: 22, color: tone.solid),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.titleMedium?.copyWith(
                          color: selected ? tone.foreground : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: context.text.bodySmall?.copyWith(
                          color: selected
                              ? tone.foreground
                              : colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _RadioDot(selected: selected, color: tone.solid),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio mark used by the condition rows and the mode cards.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : context.colors.outline,
          width: 1.8,
        ),
      ),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: selected ? 11 : 0,
        height: selected ? 11 : 0,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Primary action pinned to the bottom of a book form, with an optional
/// secondary button on its left. Shows progress and locks while [isLoading].
class BookFormBottomBar extends StatelessWidget {
  const BookFormBottomBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.isLoading,
    required this.loadingLabel,
    this.primaryIcon,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String primaryLabel;
  final IconData? primaryIcon;
  final VoidCallback onPrimary;
  final bool isLoading;
  final String loadingLabel;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Widget primaryChild = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  loadingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (primaryIcon != null) ...[
                Icon(primaryIcon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  primaryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              if (secondaryLabel != null) ...[
                OutlinedButton(
                  onPressed: isLoading ? null : onSecondary,
                  child: Text(secondaryLabel!),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: isLoading ? null : onPrimary,
                  child: primaryChild,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
