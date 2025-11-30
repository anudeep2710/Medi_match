import 'package:flutter/material.dart';
import 'package:medimatch/services/firebase_chat_service.dart' as firebase_chat;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewChatScreen extends StatefulWidget {
  final bool isGroup;

  const NewChatScreen({
    Key? key,
    this.isGroup = false,
  }) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final firebase_chat.FirebaseChatService _chatService = firebase_chat.FirebaseChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<firebase_chat.UserProfile> _allUsers = [];
  List<firebase_chat.UserProfile> _filteredUsers = [];
  List<firebase_chat.UserProfile> _selectedUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Don't load contacts immediately - wait for user to search
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredUsers = [];
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      // Search for real users in Firebase
      final users = await _chatService.searchUsers(query.trim());

      // Filter out current user
      final currentUserId = _auth.currentUser?.uid;
      final filteredUsers = users.where((user) => user.uid != currentUserId).toList();

      setState(() {
        _filteredUsers = filteredUsers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        _searchUsers(query);
      }
    });
  }

  void _toggleUserSelection(firebase_chat.UserProfile user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        if (widget.isGroup) {
          _selectedUsers.add(user);
        } else {
          // For one-on-one chat, only allow one selection
          _selectedUsers = [user];
        }
      }
    });
  }

  void _createChat() async {
    if (widget.isGroup) {
      if (_selectedUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one user')),
        );
        return;
      }

      if (_groupNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a group name')),
        );
        return;
      }

      // TODO: Implement group chat creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group chat feature coming soon!')),
      );
    } else {
      if (_selectedUsers.length != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select one user')),
        );
        return;
      }

      // Create a one-on-one chat with real Firebase user
      final selectedUser = _selectedUsers.first;

      // Return user info to parent screen
      Navigator.pop(context, {
        'userId': selectedUser.uid,
        'userName': selectedUser.displayName,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroup ? 'New Group' : 'New Chat'),
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _createChat,
              child: Text(
                widget.isGroup ? 'Create' : 'Chat',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (widget.isGroup && _selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Group name',
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          if (_selectedUsers.isNotEmpty) _buildSelectedUsersChips(),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptySearchState()
                : _filteredUsers.isEmpty && !_isLoading
                    ? _buildNoUsersFound()
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final isSelected = _selectedUsers.contains(user);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.displayName.isNotEmpty
                                        ? user.displayName[0].toUpperCase()
                                        : 'U',
                                      style: TextStyle(
                                        color: Colors.teal.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(user.displayName),
                            subtitle: user.email != null ? Text(user.email!) : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user.isOnline)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                            onTap: () => _toggleUserSelection(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for users',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a name to find other MediMatch users',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoUsersFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching with a different name',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedUsersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _selectedUsers.map((user) {
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                      style: TextStyle(
                        color: Colors.teal.shade800,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            label: Text(user.displayName),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => _toggleUserSelection(user),
          );
        }).toList(),
      ),
    );
  }
}

// UserContact class removed - now using firebase_chat.UserProfile
