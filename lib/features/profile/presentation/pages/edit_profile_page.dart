import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design/design.dart';
import '../../../discover/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'settings_page.dart' show ProfileMenuRow;

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
  static const double _avatarRadius = 56;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImage;
  String? _currentPhotoUrl;
  User? _currentUser;
  bool _isUploadingPhoto = false;
  bool _isUpdatingProfile = false;

  /// Set once the page is closing on purpose, so the guard lets it through.
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _nameController.addListener(_onNameChanged);
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
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  /// Rebuilds so the unsaved-changes guard follows the text field.
  void _onNameChanged() => setState(() {});

  bool get _hasChanges {
    if (_selectedImage != null) return true;
    final original = _currentUser?.name.trim() ?? '';
    return _nameController.text.trim() != original;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(
          context,
          source == ImageSource.camera
              ? 'We couldn\'t open the camera. Check the app\'s permissions.'
              : 'We couldn\'t open your photos. Check the app\'s permissions.',
          tone: AppTone.danger,
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showAppSheet<void>(
      context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Profile photo',
        subtitle: 'Other readers see this when you exchange books.',
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileMenuRow(
              icon: LucideIcons.camera,
              title: 'Take a photo',
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ProfileMenuRow(
              icon: LucideIcons.image,
              title: 'Choose from gallery',
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ProfileMenuRow(
                icon: LucideIcons.undo2,
                tone: AppTone.neutral,
                title: 'Keep my current photo',
                subtitle: 'Discard the photo you just picked',
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _currentUser;
    if (user == null) {
      showAppSnack(
        context,
        'Your profile is still loading. Try again in a moment.',
        tone: AppTone.warning,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final selectedImage = _selectedImage;

    setState(() {
      _isUpdatingProfile = true;
      _isUploadingPhoto = selectedImage != null;
    });

    if (selectedImage != null) {
      // Upload the new photo first; the name is saved once it succeeds.
      context.read<ProfileBloc>().add(
        UpdateProfilePhoto(userId: user.id, filePath: selectedImage.path),
      );
    } else {
      // Just update the name
      final updatedUser = user.copyWith(name: _nameController.text.trim());
      context.read<ProfileBloc>().add(UpdateProfileInfo(updatedUser));
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have changes that are not saved yet. If you leave now they will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() {
        _allowPop = true;
      });
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _allowPop = true;
          });
          showAppSnack(context, 'Profile updated', tone: AppTone.success);
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
              _allowPop = true;
            });
            showAppSnack(context, 'Photo updated', tone: AppTone.success);
            // Reload user data after photo update only
            context.read<ProfileBloc>().add(const LoadProfile());
            context.pop();
          }
        } else if (state is ProfileError) {
          setState(() {
            _isUpdatingProfile = false;
            _isUploadingPhoto = false;
          });
          showAppSnack(context, state.message, tone: AppTone.danger);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is ProfileLoading || _isUpdatingProfile || _isUploadingPhoto;
        final isSaving = _isUpdatingProfile || _isUploadingPhoto;

        return PopScope(
          canPop: _allowPop || !_hasChanges,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmDiscard();
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Edit profile')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xxl,
                AppSpacing.page,
                AppSpacing.xxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _buildAvatar(
                        context,
                        onTap: isLoading ? null : _showImagePickerOptions,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: isLoading ? null : _showImagePickerOptions,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(64, 44),
                        ),
                        child: Text(
                          _isUploadingPhoto
                              ? 'Uploading photo…'
                              : 'Change photo',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.xs,
                        bottom: AppSpacing.sm,
                      ),
                      child: Eyebrow('Display name'),
                    ),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        helperText: 'This is how other readers will see you.',
                        prefixIcon: Icon(LucideIcons.user, size: 20),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    const SizedBox(height: AppSpacing.xxl),
                    const AppBanner(
                      tone: AppTone.neutral,
                      message:
                          'Your profile picture will be visible to other users when you share or exchange books.',
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  top: BorderSide(color: context.colors.outlineVariant),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: FilledButton(
                    onPressed: isLoading ? null : _saveProfile,
                    child: isSaving
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                _isUploadingPhoto
                                    ? 'Uploading photo…'
                                    : 'Saving…',
                              ),
                            ],
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, {required VoidCallback? onTap}) {
    final colors = context.colors;
    final selectedImage = _selectedImage;
    const size = _avatarRadius * 2;

    return Semantics(
      button: true,
      label: 'Change profile photo',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size + AppSpacing.sm,
          height: size + AppSpacing.sm,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: selectedImage != null
                    ? CircleAvatar(
                        radius: _avatarRadius - 3,
                        backgroundColor: colors.primaryContainer,
                        backgroundImage: FileImage(selectedImage),
                      )
                    : UserAvatar(
                        photoUrl: _currentPhotoUrl,
                        name: _nameController.text,
                        radius: _avatarRadius - 3,
                      ),
              ),
              if (_isUploadingPhoto)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: colors.scrim.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: context.palette.onHero,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 3),
                  ),
                  child: Icon(
                    LucideIcons.camera,
                    size: 18,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
