import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Group {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int memberCount;
  final bool isPrivate;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.memberCount = 0,
    this.isPrivate = false,
  });
}

class SelectGroupScreen extends StatefulWidget {
  const SelectGroupScreen({super.key});

  @override
  State<SelectGroupScreen> createState() => _SelectGroupScreenState();
}

class _SelectGroupScreenState extends State<SelectGroupScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Group> _allGroups = [];
  List<Group> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGroups() {
    // TODO: Replace with actual API call to get tribes/groups
    // For now, using mock data
    setState(() {
      _allGroups = [
        Group(
          id: '1',
          name: 'Marathon Crew',
          description: 'Training for the next marathon together',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXiZsPYz0VolLUviyCMilRR3IruUkVfaZlreTtEpBZ72CfL2P78a58RDTPBh5AAWNG1YRLG23VuaGFz0PrXwtr2VPGDwqUqmuu0EcO38jNQCgAMLcSiMTDlBzmcq5e2yD0FiVHoh0S7GCZdfeaYSqxEO9ZS54mioTUtZAXBKNmnVk_bYxWESBfinRaO4c068arwMg7oR6P6GF9llprSidsTNX-9thY-9-y-s9MHIYlE_jWU00vWyqkBa3QgtJG82aL6jat9efs0Ok',
          memberCount: 6,
          isPrivate: false,
        ),
        Group(
          id: '2',
          name: 'Fitness Tribe',
          description: 'Stay fit together',
          imageUrl: null,
          memberCount: 12,
          isPrivate: false,
        ),
        Group(
          id: '3',
          name: 'Book Club',
          description: 'Monthly book discussions',
          imageUrl: null,
          memberCount: 8,
          isPrivate: true,
        ),
        Group(
          id: '4',
          name: 'Study Group',
          description: 'Academic support and study sessions',
          imageUrl: null,
          memberCount: 5,
          isPrivate: false,
        ),
      ];
      _filteredGroups = _allGroups;
    });
  }

  void _filterGroups() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGroups = _allGroups;
      } else {
        _filteredGroups = _allGroups
            .where((group) =>
                group.name.toLowerCase().contains(query) ||
                (group.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  void _selectGroup(Group group) {
    // Navigate to conversation with selected group
    context.go(
      '/chat/group-${group.id}',
      extra: {
        'chatName': group.name,
        'chatImageUrl': group.imageUrl,
        'isGroup': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Tribe'),
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
                hintText: 'Search tribes...',
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
          // Groups list
          Expanded(
            child: _filteredGroups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No tribes found'
                              : 'No tribes match your search',
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
                              ? 'Join or create a tribe to get started'
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
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroups[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 32,
                            backgroundImage: group.imageUrl != null
                                ? NetworkImage(group.imageUrl!)
                                : null,
                            child: group.imageUrl == null
                                ? Text(
                                    group.name[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                            backgroundColor: group.imageUrl == null
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              if (group.isPrivate)
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (group.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  group.description!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${group.memberCount} ${group.memberCount == 1 ? 'member' : 'members'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                          onTap: () => _selectGroup(group),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

