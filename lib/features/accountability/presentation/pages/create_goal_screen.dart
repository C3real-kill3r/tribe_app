import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Goal'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, "What's the Goal?",
                      "Give your goal a clear, inspiring name."),
                  const SizedBox(height: 16),
                  _buildTextField(
                      context, 'Goal Name', 'Plan our trip to Italy'),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Description',
                      'Add more details about your goal...',
                      maxLines: 4),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, "Choose a Target", ""),
                  const SizedBox(height: 16),
                  _buildTargetTypeSelector(context),
                  const SizedBox(height: 16),
                  _buildTextField(context, 'Target Amount', '2,000.00',
                      prefix: '\$'),
                  const SizedBox(height: 32),
                  _buildInviteSection(context),
                  const SizedBox(height: 16),
                  _buildSearchField(context),
                  const SizedBox(height: 16),
                  _buildSelectedFriends(context),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, String placeholder,
      {int maxLines = 1, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'Savings Amount',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Target Date',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Your Crew',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Who will help you achieve this?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search friends...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSelectedFriends(BuildContext context) {
    return Column(
      children: [
        _buildFriendItem(
          context,
          'Nicy Awino',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDXbxhS2vJup3EK0JHHXF1pGstWttGco_NcxL0BMpfSW-MJylfnN5MK1BCMdpiFfGqmuOgEOnjmP4vwDuV5jfVTZ6Eh4fp1I3bbgv2-DYPU31k2FYFCG4C2LAFFymwmoI8_fZKdPKppyt_7fPSS4wXC2e7UzBQWZFUA4987_ktEixxJSl2egdeU9JKBs4zRx1dB0Qbeh1cvbkcmvZBIDGoRzHjrW8ifOv68eYRd9VbHqr8k1d7R7HmTR0Ws5wF6WndOnlinlhRda_g',
        ),
        const SizedBox(height: 8),
        _buildFriendItem(
          context,
          'Clarie Gor',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCs0B_jylJ2PVV8gwucPUZDla_dh5nJdTX1BKKbzqWigBSkKBd_M9BIDG2iCwGCK0oUJadFjG9tbU3xYbHzndygQoQOLB6KwsdKSzPzZXiVLO3BMdxolbAAPGGbBEdPViRyAq9A9Gp0HvsG5SY7i1KMUCMsSczI82KzlfZ6Mtm_tNEQ2pNUeRm6_T76y-gmdJQ1MTDLsjke07JhvaGHVIzuGk-CJcb9v3oX07saLGGN43aVyTsXqfZNmrTe7xJxXgy1s8VvXVIJ3vg',
        ),
      ],
    );
  }

  Widget _buildFriendItem(BuildContext context, String name, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {},
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
            child: const Text('Create Goal'),
          ),
        ),
      ),
    );
  }
}
