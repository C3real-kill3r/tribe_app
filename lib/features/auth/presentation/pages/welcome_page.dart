import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tribe/core/theme/app_theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _notificationsEnabled = true;
  bool _photosEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    // Check notification permission
    final notificationStatus = await Permission.notification.status;
    
    // Check photo permission (use photos for both iOS and Android 13+)
    final photoStatus = await Permission.photos.status;
    
    if (mounted) {
      setState(() {
        _notificationsEnabled = notificationStatus.isGranted;
        _photosEnabled = photoStatus.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1(context),
                  _buildStep2(context),
                  _buildStep3(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (_currentPage < 2)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Continue'),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/signup'),
                            child: const Text('Create Account'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.primary
                                  : AppTheme.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diversity_3, size: 40, color: AppTheme.primaryDark),
              const SizedBox(width: 8),
              Text(
                'Together',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDthIwgiDXVqoUKkXG4uBFGdS7WWXfvZaazImDLYudi2mXupXnh8mnQCATqEgJJoF1L3PDp34y6fQhXO-Qgt58_Ovmd0u-vD1EJhOj6hNy8ddjFgSsbddLJjRyYJVduUN373UOeqFYPK1hh4_HmkDzRL5QYoy5LHMpczVWgF2pwJ7zuvvKnwwAfX4D3Htya3ZVjhuPVcqL2Hlt8s24BcfZildVwTfQXeJ44G3fjO8mXUQC5lCFBJqdHdGYmlWlEroS5uUwgtfKE2Ts',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Strengthen Friendships, Achieve Goals Together.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Everything You Need to Succeed Together',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            context,
            Icons.photo_camera,
            'Share Photos & Moments',
            'Capture and share your journey with friends.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.forum,
            'Group Chat & Messaging',
            'Stay connected and motivate each other.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.flag,
            'Collaborative Goal Setting',
            'Set and track your collective ambitions.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.shield_outlined,
            'Accountability Partners',
            'Keep each other on track and celebrate wins.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryDark, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Just a Few More Steps',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable these features for the best experience.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 32),
          _buildPermissionItem(
            context,
            Icons.notifications,
            'Enable Notifications',
            'Get updates on goal progress.',
            _notificationsEnabled,
            (value) async {
              if (value) {
                // Request notification permission
                final status = await Permission.notification.request();
                setState(() {
                  _notificationsEnabled = status.isGranted;
                });
                
                if (status.isDenied) {
                  _showPermissionDialog(
                    context,
                    'Notification Permission',
                    'Please enable notifications in your device settings to receive updates on goal progress.',
                  );
                } else if (status.isPermanentlyDenied) {
                  _showPermissionSettingsDialog(
                    context,
                    'Notification Permission',
                    'Notifications are permanently denied. Please enable them in your device settings.',
                  );
                }
              } else {
                // User disabled notifications
                setState(() {
                  _notificationsEnabled = false;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            context,
            Icons.photo_library,
            'Access Photos',
            'Share memories with your group.',
            _photosEnabled,
            (value) async {
              if (value) {
                // Request photo permission
                // Use photos for both iOS and Android 13+
                // For older Android versions, fallback to storage
                Permission photoPermission = Permission.photos;
                
                // Check if photos permission is available (Android 13+)
                final photosStatus = await Permission.photos.status;
                if (!photosStatus.isGranted && photosStatus.isDenied) {
                  // Try storage for older Android versions
                  final storageStatus = await Permission.storage.status;
                  if (storageStatus.isDenied || storageStatus.isGranted) {
                    photoPermission = Permission.storage;
                  }
                }
                
                final status = await photoPermission.request();
                setState(() {
                  _photosEnabled = status.isGranted;
                });
                
                if (status.isDenied) {
                  _showPermissionDialog(
                    context,
                    'Photo Permission',
                    'Please enable photo access in your device settings to share memories with your group.',
                  );
                } else if (status.isPermanentlyDenied) {
                  _showPermissionSettingsDialog(
                    context,
                    'Photo Permission',
                    'Photo access is permanently denied. Please enable it in your device settings.',
                  );
                }
              } else {
                // User disabled photo access
                setState(() {
                  _photosEnabled = false;
                });
              }
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Your privacy is important to us. We will never share your data without your permission.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppTheme.primaryLight
                  : AppTheme.primaryLight.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isEnabled
                  ? AppTheme.primaryDark
                  : AppTheme.primaryDark.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isEnabled
                            ? null
                            : Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.color
                                ?.withOpacity(0.6),
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isEnabled
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
