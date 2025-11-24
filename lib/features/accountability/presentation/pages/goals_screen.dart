import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          SavingsGoalItem(
            title: 'Trip to Costa Rica 🌴',
            savedAmount: 1950,
            targetAmount: 3000,
            progress: 0.65,
            participantCount: 4,
            deadline: DateTime.now().add(const Duration(days: 45)).toIso8601String(),
            category: 'Travel',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD9WT6XnxjMQK5dUp3VOLWft2BydqDrbYxsC6kILvr_Rb5dPIeLFAoPKl6yFzsiVLmXQXeXGDfL4j8CkgELI27Aj1lK9rNuTvHrHei2ixZ9nHMFHx0WgLvVBUcUl5eh5OAITXBkMUrQQG9WPFYLmORxtYJLcUncB5Oe_3JJvA61tAkw0p-16ov7NDZnSAI0HV-p9ybPtozZZfRAY5kSZl3dNQfdIfX_x2XFm3Nvsmg3VbmgJQiOiLji52qb2qvCI7iYNTWywY4aGIs',
            onTap: () => context.go('/goals/group'),
          ),
          SavingsGoalItem(
            title: 'Emergency Fund 🚨',
            savedAmount: 5000,
            targetAmount: 10000,
            progress: 0.5,
            participantCount: 1,
            deadline: DateTime.now().add(const Duration(days: 120)).toIso8601String(),
            category: 'Savings',
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.go('/goals/create'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SavingsGoalItem extends StatelessWidget {
  final String title;
  final double savedAmount;
  final double targetAmount;
  final double progress;
  final VoidCallback? onTap;
  final int? participantCount;
  final String? deadline;
  final String? category;
  final String? imageUrl;

  const SavingsGoalItem({
    super.key,
    required this.title,
    required this.savedAmount,
    required this.targetAmount,
    required this.progress,
    this.onTap,
    this.participantCount,
    this.deadline,
    this.category,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = targetAmount - savedAmount;
    final daysLeftValue = deadline != null ? _calculateDaysLeft(deadline!) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header (if provided)
            if (imageUrl != null)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (daysLeftValue != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                daysLeftValue > 0
                                    ? '$daysLeftValue days left'
                                    : 'Overdue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Amount Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                            if (category != null && imageUrl == null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category!,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${savedAmount.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'of \$${targetAmount.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                          Theme.of(context).dividerColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (remaining > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '\$${remaining.toStringAsFixed(0)} left',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (participantCount != null && participantCount! > 0)
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.person, size: 14),
                                ),
                                if (participantCount! > 1)
                                  Positioned(
                                    left: 12,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[400],
                                      child: const Icon(Icons.person, size: 14),
                                    ),
                                  ),
                                if (participantCount! > 2)
                                  Positioned(
                                    left: 24,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${participantCount! - 2}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$participantCount',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (daysLeftValue != null && imageUrl == null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: daysLeftValue <= 7
                              ? Colors.orange
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysLeftValue > 0
                              ? '$daysLeftValue days remaining'
                              : 'Deadline passed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: daysLeftValue <= 7
                                    ? Colors.orange
                                    : Colors.grey,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDaysLeft(String deadline) {
    // Simple calculation - in real app, parse the deadline string
    // For now, return a mock value
    try {
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;
      return difference;
    } catch (e) {
      return 30; // Default fallback
    }
  }
}
