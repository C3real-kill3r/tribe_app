import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tribe/features/home/presentation/widgets/memory_card.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDExC54qhXfDxvK_In9fEpYaXQuESef5FqDOM_x3Mni7dsvCO_hi2xIoJl1VAzwaEQBjbbWLIn5N0wnbnjsM-e0Nb-ZVoM_WZAyrYKHnwMVR6JXGDbd5o4i2sjieHHCPdEVr0GPhfxkHAtEdtD29KxD3enNcnbu00K0mdU2F2recXw74OLmEbekJyfyazGBVyGyQat_LKcMBpsCOA134GBSHlcQYIWkxiX43Iw1UBV-gXa_ggHmrPlW2iZ-LgqyRhAFsGDLzuPKBOw'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Moments',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Stories / Status
            SizedBox(
              height: 110, // Increased height to prevent overflow
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildStoryAvatar(
                      context,
                      'Clarie Gor',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuATHGafYJThG04lEy25QkjdMi-LdbFkInY0HOJh7_IDK3ImMxLoAQHtE4lTdpwuFkRorYrTnZW1XuEX_G4VMOPBKgf0RZ7wKfLLqyMzVsHdp2RyTzsOJp81EcEOtnzks8ZKJsn22wvkFUctPlknKFbMkjI7eNbFoghrk-UvQLGMJznqtD4FJjsHu3ABbDxiXC_uJ0XlTAVAp17yxr54IFjhv560fma7MX4eDpa4BRhnguLCC_Ex4bk7SopUc34FWof_IdZq8UGqRfg',
                      true),
                  const SizedBox(width: 16),
                  _buildStoryAvatar(
                      context,
                      'Alvin Amwata',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
                      false),
                  const SizedBox(width: 16),
                  _buildStoryAvatar(
                      context,
                      'Tabitha Ombura',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBAnAI7eAmRWSSeJi0bzDIILNOEn4c4zbsqWZLSI1mY83TSHNfmxB8uzDU4UF44OqFid3_t3aYTt3QONCUUtD_uDZ0oqxFkc0McR46lxwnix_7B6SfIzVfAGki3y8OSPkScwfP_Mt6pu0Qh40PgtT76R64HKEGQEXfv1Tin66wV0l1RqlURrAVKnSONMV_wX9IUBtFcH8fmky9y0Icp-VDtSfWMFbDJtRhX-MItwQ4B4I_xrh1C5VP4RGblrC5CGohACqAFRY7Gs_o',
                      false),
                  const SizedBox(width: 16),
                  _buildStoryAvatar(
                      context,
                      'Frank Amwata',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBBEf7yAu_CKTRcyvo065MuG7i4t6rmMRbeL1hqj4DeqHFJZxiWxJiiV6cMXS7IE2NzwHMMZiJbk_LLXM2lR3q1vS-Q5qGgbnkjrA16Ed2q12Y5g_M2JYkPDmtiv-fQWjlZefZ2TUGgRnEVGwFskKAS63_CR9kJpEH2cwkvXd7HPaWG23HGGuHn_E_PQDF2Q10iZtcWgGTn4mFXZG0MUqUZBxTddQH9N2yPzN-seTOIXRawLHpJX0XqsHuKR7HmWi4K6t_1F-Kl50I',
                      true),
                ],
              ),
            ),

            // Feed
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                children: [
                  InkWell(
                    onTap: () => context.push('/memories/post', extra: {
                      'userName': 'Alvin Amwata',
                      'userImage':
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
                      'imageUrl':
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZcmEAD_3Rcsg8OVlxtAV-6ukxPUwxgCXtxt-Neb6Ja6XU9RyK9w1yF710YzNx90-Nsm8Cc0nJG8bm3V_9Nq9VUNR6q6YHfkkqxwc4FLN1WFZkXD_WDakg1pWb2ZuPjRntX4-8Trn-AlNbQ5YvtFNx48tEcRYkYOFTFJfu60MQcuWrH5WpkHZWIjA3zzDjAEQoN-DxIq8i8HgvK7VNBW_HkNj76Vh8-PYN0zUYTfdFlAst_AeOJAQBLJy-aJWg_LiTjdmS7C6r5o8',
                      'caption':
                          'First training session in the books! Felt great to get out there and start this journey with you all.',
                      'timeAgo': '2 hours ago',
                      'likes': 12,
                      'commentsCount': 3,
                      'goalTag': 'Goal: Run a 5K',
                    }),
                    child: const MemoryCard(
                      userName: 'Alvin Amwata',
                      userImage:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBI-EAHM1ea5gJFYdzEHRc10JyVRmp8xNZNtZFXNTrZGEzKawcFEfPNwRMhz5ZeIX4ZRYrW8PHK1BWV-yE0vZJ7TBDqmF73WBpZzUrRNcnOUIZeo6YFZw5BVSuMVVuyIW2UqvilfcIFmj8V0YFoUZADYH_WUTq30oVj0or_PvPAGqUKm6CHBiweKHhKnbQWebJiwovmpSvTBA40if-_kS95NrmoJx1aS6T-0OOSJCDV2NNT-d7RDE6Auwo1n6zQBeVvN0ozhHBtVto',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZcmEAD_3Rcsg8OVlxtAV-6ukxPUwxgCXtxt-Neb6Ja6XU9RyK9w1yF710YzNx90-Nsm8Cc0nJG8bm3V_9Nq9VUNR6q6YHfkkqxwc4FLN1WFZkXD_WDakg1pWb2ZuPjRntX4-8Trn-AlNbQ5YvtFNx48tEcRYkYOFTFJfu60MQcuWrH5WpkHZWIjA3zzDjAEQoN-DxIq8i8HgvK7VNBW_HkNj76Vh8-PYN0zUYTfdFlAst_AeOJAQBLJy-aJWg_LiTjdmS7C6r5o8',
                      caption:
                          'First training session in the books! Felt great to get out there and start this journey with you all.',
                      timeAgo: '2 hours ago',
                      likes: 12,
                      commentsCount: 3,
                      goalTag: 'Goal: Run a 5K',
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/memories/post', extra: {
                      'userName': 'Tabitha Ombura',
                      'userImage':
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDArl7QkZFntBm-LiPqnf9d7_eIYO8sEi499lpBBQ3N_jVFRiBYxGJ08yZI-I7ziKT32govvTTbznPfZX9r7uE3lOD1a3VPT7XDML4SXzRVoErm2JDEKvujLUxml37zx3uAwjoAGTcrnJusnReofRvyNoFveBZTXJa5xFaKY0_efoRxDR5T9jCHupi9vZFBX9ohNjicDV6_ls8ORZc8jFJaeoPBdvzPKhruFU-vBQW3NV9Gi9nAJFQWG2DMBRmnsTKkbOPneonG6QY',
                      'imageUrl':
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEdPJYdn-1anQAeJVs6xGdZ_a7g35dAN_V702DkgDrblvuL_XFToNdpA3NdNhbH6sz58puFMvcitxW2PuPInefdbIfWmFE4v0LdA4hXMavQaZna_vyO2rS8Y020rg_j9VMUYP2IXrvLUdSLW_K5d4M18cDBb1RoTXQSyG-6lvaX-yH6mz5n_foz5G0B1KRMIhFLHTw7X-oOLoPEM7XzGP3xg5VnVcI4AQ-tKalznK7Nkz0pgMFDb9mOBQeFcVMcEoz2uCvqypJa3Q',
                      'caption':
                          "Had the best time exploring the coast. Can't wait for our next trip!",
                      'timeAgo': 'Yesterday',
                      'likes': 8,
                      'commentsCount': 1,
                      'goalTag': null,
                    }),
                    child: const MemoryCard(
                      userName: 'Tabitha Ombura',
                      userImage:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDArl7QkZFntBm-LiPqnf9d7_eIYO8sEi499lpBBQ3N_jVFRiBYxGJ08yZI-I7ziKT32govvTTbznPfZX9r7uE3lOD1a3VPT7XDML4SXzRVoErm2JDEKvujLUxml37zx3uAwjoAGTcrnJusnReofRvyNoFveBZTXJa5xFaKY0_efoRxDR5T9jCHupi9vZFBX9ohNjicDV6_ls8ORZc8jFJaeoPBdvzPKhruFU-vBQW3NV9Gi9nAJFQWG2DMBRmnsTKkbOPneonG6QY',
                      timeAgo: 'Yesterday',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEdPJYdn-1anQAeJVs6xGdZ_a7g35dAN_V702DkgDrblvuL_XFToNdpA3NdNhbH6sz58puFMvcitxW2PuPInefdbIfWmFE4v0LdA4hXMavQaZna_vyO2rS8Y020rg_j9VMUYP2IXrvLUdSLW_K5d4M18cDBb1RoTXQSyG-6lvaX-yH6mz5n_foz5G0B1KRMIhFLHTw7X-oOLoPEM7XzGP3xg5VnVcI4AQ-tKalznK7Nkz0pgMFDb9mOBQeFcVMcEoz2uCvqypJa3Q',
                      likes: 8,
                      caption:
                          "Had the best time exploring the coast. Can't wait for our next trip!",
                      goalTag: null,
                      commentsCount: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryAvatar(
      BuildContext context, String name, String imageUrl, bool hasStory) {
    return InkWell(
      onTap: hasStory
          ? () => context.push('/memories/story', extra: {
                'userName': name,
                'userImage': imageUrl,
                'storyImageUrl': imageUrl,
                'timeAgo': '2h',
              })
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: hasStory
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: hasStory ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
