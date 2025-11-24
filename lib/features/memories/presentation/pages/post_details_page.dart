import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostDetailsPage extends StatelessWidget {
  final String userName;
  final String userImage;
  final String imageUrl;
  final String caption;
  final String timeAgo;
  final int likes;
  final String? goalTag;
  final int commentsCount;

  const PostDetailsPage({
    super.key,
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.caption,
    required this.timeAgo,
    this.likes = 0,
    this.goalTag,
    this.commentsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Post'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(userImage),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                timeAgo,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Image
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  // Caption and Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caption,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (goalTag != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  goalTag!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              iconSize: 28,
                              color: Colors.grey,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$likes',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 28,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$commentsCount',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Comments Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildComment(
                          context,
                          'Clarie Gor',
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuATHGafYJThG04lEy25QkjdMi-LdbFkInY0HOJh7_IDK3ImMxLoAQHtE4lTdpwuFkRorYrTnZW1XuEX_G4VMOPBKgf0RZ7wKfLLqyMzVsHdp2RyTzsOJp81EcEOtnzks8ZKJsn22wvkFUctPlknKFbMkjI7eNbFoghrk-UvQLGMJznqtD4FJjsHu3ABbDxiXC_uJ0XlTAVAp17yxr54IFjhv560fma7MX4eDpa4BRhnguLCC_Ex4bk7SopUc34FWof_IdZq8UGqRfg',
                          'Yesss! So proud of you! Way to start strong. 💪',
                        ),
                        const SizedBox(height: 16),
                        _buildComment(
                          context,
                          'Tabitha Ombura',
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBAnAI7eAmRWSSeJi0bzDIILNOEn4c4zbsqWZLSI1mY83TSHNfmxB8uzDU4UF44OqFid3_t3aYTt3QONCUUtD_uDZ0oqxFkc0McR46lxwnix_7B6SfIzVfAGki3y8OSPkScwfP_Mt6pu0Qh40PgtT76R64HKEGQEXfv1Tin66wV0l1RqlURrAVKnSONMV_wX9IUBtFcH8fmky9y0Icp-VDtSfWMFbDJtRhX-MItwQ4B4I_xrh1C5VP4RGblrC5CGohACqAFRY7Gs_o',
                          'Amazing! That sunrise looks incredible. Keep it up!',
                        ),
                        const SizedBox(height: 16),
                        _buildComment(
                          context,
                          'Frank Amwata',
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBBEf7yAu_CKTRcyvo065MuG7i4t6rmMRbeL1hqj4DeqHFJZxiWxJiiV6cMXS7IE2NzwHMMZiJbk_LLXM2lR3q1vS-Q5qGgbnkjrA16Ed2q12Y5g_M2JYkPDmtiv-fQWjlZefZ2TUGgRnEVGwFskKAS63_CR9kJpEH2cwkvXd7HPaWG23HGGuHn_E_PQDF2Q10iZtcWgGTn4mFXZG0MUqUZBxTddQH9N2yPzN-seTOIXRawLHpJX0XqsHuKR7HmWi4K6t_1F-Kl50I',
                          'Let\'s gooo! 🔥',
                        ),
                        const SizedBox(height: 100), // Space for bottom input
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDExC54qhXfDxvK_In9fEpYaXQuESef5FqDOM_x3Mni7dsvCO_hi2xIoJl1VAzwaEQBjbbWLIn5N0wnbnjsM-e0Nb-ZVoM_WZAyrYKHnwMVR6JXGDbd5o4i2sjieHHCPdEVr0GPhfxkHAtEdtD29KxD3enNcnbu00K0mdU2F2recXw74OLmEbekJyfyazGBVyGyQat_LKcMBpsCOA134GBSHlcQYIWkxiX43Iw1UBV-gXa_ggHmrPlW2iZ-LgqyRhAFsGDLzuPKBOw',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]?.withOpacity(0.3)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sentiment_satisfied),
                            color: Colors.grey[600],
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {},
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

  Widget _buildComment(
    BuildContext context,
    String name,
    String avatarUrl,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]?.withOpacity(0.3)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

