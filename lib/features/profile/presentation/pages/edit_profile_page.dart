import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../discover/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Edit Profile Page - Update name and profile picture
class EditProfilePage extends StatelessWidget {
  final User? user;
  const EditProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Use the existing ProfileBloc from parent instead of creating a new one
    return _EditProfilePageContent(user: user);
  }
}

class _EditProfilePageContent extends StatefulWidget {
  final User? user;
  const _EditProfilePageContent({this.user});

  @override
  State<_EditProfilePageContent> createState() =>
      _EditProfilePageContentState();
}

class _EditProfilePageContentState extends State<_EditProfilePageContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImage;
  String? _currentPhotoUrl;
  User? _currentUser;
  bool _isUploadingPhoto = false;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // First try to use the passed user
    if (widget.user != null) {
      _currentUser = widget.user;
      _nameController.text = widget.user!.name;
      _currentPhotoUrl = widget.user!.photoUrl;
      return;
    }

    final state = context.read<ProfileBloc>().state;
    User? user;

    if (state is ProfileLoaded) {
      user = state.user;
    } else if (state is ProfileUpdated) {
      user = state.user;
    }

    if (user != null) {
      _currentUser = user;
      _nameController.text = user.name;
      _currentPhotoUrl = user.photoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentPhotoUrl != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(LucideIcons.trash2, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentPhotoUrl = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUser == null) return;

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      // If a new image is selected, upload it first
      if (_selectedImage != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        context.read<ProfileBloc>().add(
          UpdateProfilePhoto(
            userId: _currentUser!.id,
            filePath: _selectedImage!.path,
          ),
        );
      } else if (_currentUser != null) {
        // Just update the name
        final updatedUser = _currentUser!.copyWith(
          name: _nameController.text.trim(),
        );
        context.read<ProfileBloc>().add(UpdateProfileInfo(updatedUser));
      }
    } catch (e) {
      setState(() {
        _isUpdatingProfile = false;
        _isUploadingPhoto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _currentUser = state.user;
          if (_nameController.text.isEmpty) {
            _nameController.text = state.user.name;
          }
          if (_currentPhotoUrl == null && state.user.photoUrl != null) {
            setState(() {
              _currentPhotoUrl = state.user.photoUrl;
            });
          }
        } else if (state is ProfileUpdated) {
          setState(() {
            _isUpdatingProfile = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          // Reload user data after update
          context.read<ProfileBloc>().add(const LoadProfile());
          context.pop();
        } else if (state is ProfilePhotoUpdated) {
          setState(() {
            _isUploadingPhoto = false;
            _currentPhotoUrl = state.photoUrl;
            _selectedImage = null;
          });

          // Now update the name as well
          if (_currentUser != null) {
            final updatedUser = _currentUser!.copyWith(
              name: _nameController.text.trim(),
              photoUrl: state.photoUrl,
            );
            context.read<ProfileBloc>().add(UpdateProfileInfo(updatedUser));
          } else {
            setState(() {
              _isUpdatingProfile = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo updated successfully!')),
            );
            // Reload user data after photo update only
            context.read<ProfileBloc>().add(const LoadProfile());
            context.pop();
          }
        } else if (state is ProfileError) {
          setState(() {
            _isUpdatingProfile = false;
            _isUploadingPhoto = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is ProfileLoading || _isUpdatingProfile || _isUploadingPhoto;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                onPressed: isLoading ? null : _saveProfile,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : _showImagePickerOptions,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: _getProfileImage(),
                          child: _getProfileImage() == null
                              ? Icon(
                                  LucideIcons.user,
                                  size: 60,
                                  color: colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: isLoading ? null : _showImagePickerOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.camera,
                              size: 20,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (_isUploadingPhoto)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isLoading ? null : _showImagePickerOptions,
                    child: const Text('Change Photo'),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      if (value.trim().length > 50) {
                        return 'Name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.info,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your profile picture will be visible to other users when you share or exchange books.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
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
        );
      },
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(_currentPhotoUrl!);
    }
    return null;
  }
}
