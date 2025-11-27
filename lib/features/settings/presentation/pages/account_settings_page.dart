import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tribe/core/di/service_locator.dart' as di;
import 'package:tribe/features/user/presentation/bloc/user_bloc.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to track if user made changes
    _nameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserBloc>()..add(LoadUserProfile()),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // Populate fields with user data
            if (!_hasChanges) {
              _nameController.text = state.user.fullName;
              _usernameController.text = state.user.username;
              _emailController.text = state.user.email;
            }
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserLoaded && _hasChanges) {
            // Successfully updated
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _hasChanges = false;
            });
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final user = state is UserLoaded ? state.user : null;
            final isLoading = state is UserLoading || state is UserUpdating;
            
            return Scaffold(
              appBar: AppBar(
                title: const Text('Account Settings'),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 64,
                                    backgroundImage: user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty
                                        ? NetworkImage(user.profileImageUrl!)
                                        : null,
                                    backgroundColor: Colors.grey[300],
                                    child: user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty
                                        ? const Icon(Icons.person, size: 48)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          width: 4,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                const SizedBox(height: 32),
                // Profile Section
                _buildSectionTitle('Profile'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                ),
                const SizedBox(height: 32),
                // Account Security Section
                _buildSectionTitle('Account Security'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                // Change Password Section
                _buildSectionTitle('Change Password'),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  isVisible: _isCurrentPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  isVisible: _isNewPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
          // Floating Save Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading || !_hasChanges
                        ? null
                        : () {
                            // Validate passwords if changing
                            if (_newPasswordController.text.isNotEmpty) {
                              if (_currentPasswordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter current password'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (_newPasswordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('New passwords do not match'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (_newPasswordController.text.length < 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password must be at least 8 characters'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            }
                            
                            // Update profile
                            context.read<UserBloc>().add(
                              UpdateUserProfile(
                                fullName: _nameController.text.trim(),
                                username: _usernameController.text.trim(),
                                email: _emailController.text.trim(),
                                bio: null, // Bio is not in account settings, it's in profile
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}

