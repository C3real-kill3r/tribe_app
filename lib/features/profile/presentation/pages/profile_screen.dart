import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tribe/core/di/service_locator.dart' as di;
import 'package:tribe/core/router/app_router.dart';
import 'package:tribe/features/user/presentation/bloc/user_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'Active Goals';
  File? _coverImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isCover) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isCover) {
          _coverImage = File(image.path);
        } else {
          _profileImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserBloc>()..add(LoadUserProfile()),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is UserError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserBloc>().add(LoadUserProfile());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state is UserLoaded ? state.user : null;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 16),
                  _buildUserInfo(context, user),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, user),
                  const SizedBox(height: 32),
                  _buildRecentActivity(context),
                  const SizedBox(height: 32),
                  _buildTabsAndContent(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    final coverImageUrl = user?.coverImageUrl;
    final profileImageUrl = user?.profileImageUrl;
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Cover Image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _coverImage != null
                  ? FileImage(_coverImage!) as ImageProvider
                  : (coverImageUrl != null && coverImageUrl.isNotEmpty
                      ? NetworkImage(coverImageUrl) as ImageProvider
                      : const NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDeHJq-18ClaxVINXBZ-uWMAAhloMGYLrPy4Eye0aQCKCD-HBZY-SGIvvGTekRfmztwCfIEXFLqmquCYOP65P2vDiQs8TY7YoCZuT6MMAnluWf3LZhZkS5hdXJUl8BpG3AfWLCc9jHkby7gDCE_Ogk0KcZ-mP6ZygyqELAG8rz7KhrOCUcww1WM5yg38ql3VW_UFdy8GXVQS5P_2ACl_L0PRQmOwACuXBg6ott0KZAAeFiJxWqmJwD9KC2s_8VODZjl73qPfIv6FMw') as ImageProvider),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                      onPressed: () {
                        // Use root navigator for iOS compatibility when navigating
                        // to routes outside the StatefulShellRoute
                        final rootContext = rootNavigatorKey.currentContext;
                        if (rootContext != null) {
                          GoRouter.of(rootContext).push('/settings');
                        } else {
                          // Fallback to regular context if root navigator not available
                          context.push('/settings');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Edit Cover Button
        Positioned(
          bottom: 8,
          right: 8,
          child: InkWell(
            onTap: () => _pickImage(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    'Edit cover',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Profile Avatar
        Positioned(
          bottom: -50,
          child: Stack(
            children: [
              Container(
                height: 112,
                width: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 4,
                  ),
                  image: DecorationImage(
                    image: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : (profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl) as ImageProvider
                            : const NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDDA3LI2-AtzMBHHsrrpuPpFgxfLuzB_84RM2Q66XaMlVAitG7eKbhhVY9UKfcDl20EpvLXfN6GvbGxR0GcsLzfl-Bfx59H4QP29vxIiRU108O_8wppJ-XvFKgcE1UuIeswvFRpGLaw5sHJyoDJQIyoVu5JDurn6cOwlwHa_SOQwpFHs1m4uSvu7RGbMrf5tNvf1of3_Jy5_5KyrbVYDHmKYl0GUgw8PMOSUQOSfh9emPGb-qTYmiaId3bbz8Q2lpa443fiE-MiJlg') as ImageProvider),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _pickImage(false),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, user) {
    final fullName = user?.fullName ?? 'Loading...';
    final bio = user?.bio ?? '';
    
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Column(
        children: [
          Text(
            fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          if (bio.isNotEmpty)
            Text(
              '"$bio"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            )
          else
            Text(
              'No bio yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, user) {
    final goalsAchieved = user?.goalsAchieved ?? 0;
    final photosShared = user?.photosShared ?? 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(context, goalsAchieved.toString(), 'Goals Achieved'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(context, photosShared.toString(), 'Photos Shared'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(context, Icons.celebration,
              "Completed the 'Run a 5k' goal with Cedric Ochola!"),
          const SizedBox(height: 12),
          _buildActivityItem(context, Icons.add_a_photo,
              "Added 5 new photos to 'Weekend Trip' album."),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsAndContent(BuildContext context) {
    return Column(
      children: [
        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTab(
                  context, 'Active Goals', _selectedTab == 'Active Goals'),
              _buildTab(context, 'Friends', _selectedTab == 'Friends'),
              _buildTab(context, 'Photos', _selectedTab == 'Photos'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content based on selected tab
        _buildTabContent(context),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String text, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 'Active Goals':
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildGoalCard(
                context,
                'Run a 5k',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD9WT6XnxjMQK5dUp3VOLWft2BydqDrbYxsC6kILvr_Rb5dPIeLFAoPKl6yFzsiVLmXQXeXGDfL4j8CkgELI27Aj1lK9rNuTvHrHei2ixZ9nHMFHx0WgLvVBUcUl5eh5OAITXBkMUrQQG9WPFYLmORxtYJLcUncB5Oe_3JJvA61tAkw0p-16ov7NDZnSAI0HV-p9ybPtozZZfRAY5kSZl3dNQfdIfX_x2XFm3Nvsmg3VbmgJQiOiLji52qb2qvCI7iYNTWywY4aGIs',
                0.75,
              ),
              const SizedBox(width: 16),
              _buildGoalCard(
                context,
                'Read 12 books',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBDGsRiXJcc5DkP7WlL8UeD3VxisE_lWGhy9Cd32QaNU4l-z3gYlEwQLii7zNCBSfqr8cX9-bm11z8zT1CCpO28XoDLZfLDgEVCGlHxUEFcLxEf2XZOnyX-lbg6cGN1PMO6l_QliPzTVvcCtQHu5V_oU7afKWIXNZlLVV1zmnr7spOysris4cGzv06BOovyufzXLi6uYYKddPRQl6qlM6tfmFV74Ea1iPjDLzulAQPjpy0MyTnbSCjejsP1W8mND4rlcIOi0-JQXQA',
                0.42,
              ),
              const SizedBox(width: 16),
              _buildGoalCard(
                context,
                'Meditate daily',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDeHJq-18ClaxVINXBZ-uWMAAhloMGYLrPy4Eye0aQCKCD-HBZY-SGIvvGTekRfmztwCfIEXFLqmquCYOP65P2vDiQs8TY7YoCZuT6MMAnluWf3LZhZkS5hdXJUl8BpG3AfWLCc9jHkby7gDCE_Ogk0KcZ-mP6ZygyqELAG8rz7KhrOCUcww1WM5yg38ql3VW_UFdy8GXVQS5P_2ACl_L0PRQmOwACuXBg6ott0KZAAeFiJxWqmJwD9KC2s_8VODZjl73qPfIv6FMw',
                0.90,
              ),
            ],
          ),
        );
      case 'Friends':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildFriendItem(context, 'Cedric Ochola', 'Active now', true),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Brian Onyango', 'Active 2h ago', true),
              const SizedBox(height: 12),
              _buildFriendItem(
                  context, 'Robert Angira', 'Active yesterday', false),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Derrick Juma', 'Active 3d ago', false),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Alvin Amwata', 'Active 1w ago', false),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Frank Amwata', 'Active 2w ago', false),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Clarie Gor', 'Active 1w ago', true),
              const SizedBox(height: 12),
              _buildFriendItem(context, 'Nicy Awino', 'Active 3d ago', true),
              const SizedBox(height: 12),
              _buildFriendItem(
                  context, 'Tabitha Ombura', 'Active yesterday', false),
            ],
          ),
        );
      case 'Photos':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuD9WT6XnxjMQK5dUp3VOLWft2BydqDrbYxsC6kILvr_Rb5dPIeLFAoPKl6yFzsiVLmXQXeXGDfL4j8CkgELI27Aj1lK9rNuTvHrHei2ixZ9nHMFHx0WgLvVBUcUl5eh5OAITXBkMUrQQG9WPFYLmORxtYJLcUncB5Oe_3JJvA61tAkw0p-16ov7NDZnSAI0HV-p9ybPtozZZfRAY5kSZl3dNQfdIfX_x2XFm3Nvsmg3VbmgJQiOiLji52qb2qvCI7iYNTWywY4aGIs',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFriendItem(
      BuildContext context, String name, String status, bool isOnline) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 24),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, String title, String imageUrl, double progress) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

}
