import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/core/widgets/main_scaffold.dart';
import 'package:tribe/features/accountability/presentation/pages/goals_screen.dart';
import 'package:tribe/features/accountability/presentation/pages/group_goal_screen.dart';
import 'package:tribe/features/accountability/presentation/pages/create_goal_screen.dart';
import 'package:tribe/features/auth/presentation/pages/login_page.dart';
import 'package:tribe/features/auth/presentation/pages/signup_page.dart';
import 'package:tribe/features/auth/presentation/pages/splash_screen.dart';
import 'package:tribe/features/auth/presentation/pages/welcome_page.dart';
import 'package:tribe/features/chat/presentation/pages/chat_screen.dart';
import 'package:tribe/features/chat/presentation/pages/conversation_screen.dart';
import 'package:tribe/features/chat/presentation/pages/select_kin_screen.dart';
import 'package:tribe/features/chat/presentation/pages/select_group_screen.dart';
import 'package:tribe/features/home/home_screen.dart';
import 'package:tribe/features/memories/presentation/pages/memories_screen.dart';
import 'package:tribe/features/memories/presentation/pages/post_details_page.dart';
import 'package:tribe/features/memories/presentation/pages/story_detail_page.dart';
import 'package:tribe/features/profile/presentation/pages/profile_screen.dart';
import 'package:tribe/features/settings/presentation/pages/settings_page.dart';
import 'package:tribe/features/settings/presentation/pages/account_settings_page.dart';
import 'package:tribe/features/settings/presentation/pages/appearance_settings_page.dart';
import 'package:tribe/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:tribe/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:tribe/features/notifications/presentation/pages/notifications_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Export root navigator key for navigation outside shell (fixes iOS navigation issue)
GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
              routes: [
                // Specific routes must come before parameterized routes
                GoRoute(
                  path: 'select-kin',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SelectKinScreen(),
                ),
                GoRoute(
                  path: 'select-group',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SelectGroupScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final chatId = state.pathParameters['id']!;
                    final extra = state.extra as Map<String, dynamic>?;
                    return ConversationScreen(
                      chatId: chatId,
                      chatName: extra?['chatName'] as String?,
                      chatImageUrl: extra?['chatImageUrl'] as String?,
                      isGroup: extra?['isGroup'] as bool?,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsScreen(),
              routes: [
                GoRoute(
                  path: 'group',
                  builder: (context, state) => const GroupGoalScreen(),
                ),
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CreateGoalScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/memories',
              builder: (context, state) => const MemoriesScreen(),
              routes: [
                GoRoute(
                  path: 'post',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return PostDetailsPage(
                      userName: extra['userName'] as String,
                      userImage: extra['userImage'] as String,
                      imageUrl: extra['imageUrl'] as String,
                      caption: extra['caption'] as String,
                      timeAgo: extra['timeAgo'] as String,
                      likes: extra['likes'] as int? ?? 0,
                      commentsCount: extra['commentsCount'] as int? ?? 0,
                      goalTag: extra['goalTag'] as String?,
                    );
                  },
                ),
                GoRoute(
                  path: 'story',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return StoryDetailPage(
                      userName: extra['userName'] as String,
                      userImage: extra['userImage'] as String,
                      storyImageUrl: extra['storyImageUrl'] as String,
                      timeAgo: extra['timeAgo'] as String,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountSettingsPage(),
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearanceSettingsPage(),
                ),
                GoRoute(
                  path: 'privacy',
                  builder: (context, state) => const PrivacySettingsPage(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
