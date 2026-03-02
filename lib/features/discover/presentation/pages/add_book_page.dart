import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/book/book_bloc.dart';
import '../bloc/book/book_event.dart';
import '../bloc/book/book_state.dart';
import '../widgets/location_picker_widget.dart';

/// Add Book Page - 3-step wizard to add a new book
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
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Photo
  File? _bookCoverImage;
  bool _isScanning = false;

  // Step 2: Details
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _selectedGenres = [];
  int _selectedCondition = 2; // Default: Good

  // Step 3: Mode
  String _selectedMode = 'donate'; // donate or exchange

  // Location
  LatLng? _selectedLocation;
  String _selectedAddress = '';

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _bookCoverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a book cover photo')),
      );
      return;
    }

    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      // Validate location is selected before proceeding to step 3
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a location for your book'),
          ),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submitBook();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _bookCoverImage = File(pickedFile.path);
      });

      // Optionally scan for ISBN
      if (source == ImageSource.camera) {
        _scanForISBN();
      }
    }
  }

  Future<void> _scanForISBN() async {
    if (_bookCoverImage == null) return;

    setState(() => _isScanning = true);

    try {
      final inputImage = InputImage.fromFile(_bookCoverImage!);
      final textRecognizer = TextRecognizer();
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
            setState(() {
              _isbnController.text = isbn;
            });
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('ISBN detected: $isbn')));
            }
            break;
          }
        }
      }

      await textRecognizer.close();
    } catch (e) {
      debugPrint('Error scanning ISBN: $e');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _submitBook() {
    if (_formKey.currentState!.validate() && _bookCoverImage != null) {
      // Check if location is selected
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')),
        );
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book added successfully!')),
          );
          context.pop();
        } else if (state is BookError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is BookLoading;

        return PopScope(
          canPop: _currentStep == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _currentStep > 0) {
              _previousStep();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Book'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_currentStep > 0) {
                          _previousStep();
                        } else {
                          context.pop();
                        }
                      },
              ),
            ),
            body: Column(
              children: [
                // Progress Indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  minHeight: 4,
                ),

                // Step Indicator
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(0, 'Photo'),
                      const SizedBox(width: 8),
                      _buildStepDivider(),
                      const SizedBox(width: 8),
                      _buildStepIndicator(1, 'Details'),
                      const SizedBox(width: 8),
                      _buildStepDivider(),
                      const SizedBox(width: 8),
                      _buildStepIndicator(2, 'Mode'),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPhotoStep(),
                      _buildDetailsStep(),
                      _buildModeStep(),
                    ],
                  ),
                ),

                // Next Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : _nextStep,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? 'Add Book' : 'Next',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 24,
      height: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Book Cover Photo',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or select from gallery',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Preview
          if (_bookCoverImage != null)
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(_bookCoverImage!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book,
                size: 100,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 24),

          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Scanning for ISBN...'),
                  ],
                ),
              ),
            ),

          // Camera Button
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Gallery Button
          OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Book Details',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the information about your book',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter book title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.words,
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
            const SizedBox(height: 16),

            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author *',
                hintText: 'Enter author name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter author name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ISBN (Optional)
            TextFormField(
              controller: _isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN (Optional)',
                hintText: 'Enter ISBN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Tell more about the book',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: AppConstants.maxBookDescriptionLength,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Genres
            Text('Genres', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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

            // Condition
            Text('Condition', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(AppConstants.bookConditions.length, (index) {
              return RadioListTile<int>(
                title: Text(AppConstants.bookConditions[index]),
                value: index,
                groupValue: _selectedCondition,
                onChanged: (value) {
                  setState(() => _selectedCondition = value!);
                },
              );
            }),
            const SizedBox(height: 24),

            // Location Selection
            Text('Location *', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: InkWell(
                onTap: _openLocationPicker,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _selectedLocation != null
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedLocation != null
                                  ? 'Location Selected'
                                  : 'Select Book Location',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (_selectedLocation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedAddress.isEmpty
                              ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                              : _selectedAddress,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_selectedLocation == null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  'Tap to select location on map',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openLocationPicker() {
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
            });
          },
        ),
      ),
    );
  }

  Widget _buildModeStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose Mode',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'How do you want to share this book?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Donate Option
          _buildModeCard(
            icon: Icons.volunteer_activism_outlined,
            title: 'Donate',
            description: 'Give away this book for free to anyone who wants it',
            isSelected: _selectedMode == 'donate',
            onTap: () => setState(() => _selectedMode = 'donate'),
          ),
          const SizedBox(height: 16),

          // Exchange Option
          _buildModeCard(
            icon: Icons.swap_horiz,
            title: 'Exchange',
            description: 'Swap this book with another book from someone else',
            isSelected: _selectedMode == 'exchange',
            onTap: () => setState(() => _selectedMode = 'exchange'),
          ),
          const SizedBox(height: 24),

          // Info box
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedMode == 'donate'
                          ? 'Anyone can request this book for free'
                          : 'Users must offer a book in exchange',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 0 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
