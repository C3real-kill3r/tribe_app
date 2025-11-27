import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Kin {
  final String id;
  final String name;
  final String username;
  final String? imageUrl;
  final bool isOnline;
  final String? lastSeenAt;

  Kin({
    required this.id,
    required this.name,
    required this.username,
    this.imageUrl,
    this.isOnline = false,
    this.lastSeenAt,
  });
}

class SelectKinScreen extends StatefulWidget {
  const SelectKinScreen({super.key});

  @override
  State<SelectKinScreen> createState() => _SelectKinScreenState();
}

class _SelectKinScreenState extends State<SelectKinScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Kin> _allKins = [];
  List<Kin> _filteredKins = [];

  @override
  void initState() {
    super.initState();
    _loadKins();
    _searchController.addListener(_filterKins);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadKins() {
    // TODO: Replace with actual API call to /api/v1/friends
    // For now, using mock data
    setState(() {
      _allKins = [
        Kin(
          id: '1',
          name: 'Derrick Juma',
          username: 'derrickjuma',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
          isOnline: true,
        ),
        Kin(
          id: '2',
          name: 'Nicy Awino',
          username: 'nicyawino',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFoA_yURU6LOksgiJrNkBWXq83x7Yk7-NMK00CzpRGZyIOzUXbBh8kFz5K_vsmywO63XghCxZQLhyzH6PHfc5YsTLpNO5MMI6yfGytFqBmTBT21T3roUDxpcVdKNvs_-O-XcPXAvntGMgSdvSdiPLs0f8SSchrECbUmJgUU7MgCvOy1uYeueiufNpRn7N95UnX10iL8ERBPI7yr7Fc7AfywOBobOkL8s0PQKIirc8148Ntfgwsqhjb-QwbMPb3tqingB6mIHknjZs',
          isOnline: false,
          lastSeenAt: '2 hours ago',
        ),
        Kin(
          id: '3',
          name: 'Cedric Ochola',
          username: 'cedricochola',
          imageUrl: null,
          isOnline: true,
        ),
        Kin(
          id: '4',
          name: 'Sarah Mwangi',
          username: 'sarahmwangi',
          imageUrl: null,
          isOnline: false,
          lastSeenAt: 'Yesterday',
        ),
      ];
      _filteredKins = _allKins;
    });
  }

  void _filterKins() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredKins = _allKins;
      } else {
        _filteredKins = _allKins
            .where((kin) =>
                kin.name.toLowerCase().contains(query) ||
                kin.username.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _selectKin(Kin kin) {
    // Navigate to conversation with selected kin
    context.go(
      '/chat/user-${kin.id}',
      extra: {
        'chatName': kin.name,
        'chatImageUrl': kin.imageUrl,
        'isGroup': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Kin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}), // Trigger rebuild for clear button
              decoration: InputDecoration(
                hintText: 'Search kins...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {}); // Update UI immediately
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          // Kins list
          Expanded(
            child: _filteredKins.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No kins found'
                              : 'No kins match your search',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Add friends to start messaging'
                              : 'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredKins.length,
                    itemBuilder: (context, index) {
                      final kin = _filteredKins[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: kin.imageUrl != null
                                  ? NetworkImage(kin.imageUrl!)
                                  : null,
                              child: kin.imageUrl == null
                                  ? Text(
                                      kin.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                              backgroundColor: kin.imageUrl == null
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            if (kin.isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          kin.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          kin.isOnline
                              ? 'Online'
                              : (kin.lastSeenAt ?? 'Offline'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: kin.isOnline
                                    ? Colors.green
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                              ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        onTap: () => _selectKin(kin),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

