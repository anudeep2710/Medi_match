import 'package:flutter/material.dart';
import 'package:medimatch/services/chat_service.dart';

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
  final List<UserContact> _allContacts = [];
  List<UserContact> _filteredContacts = [];
  List<UserContact> _selectedContacts = [];
  bool _isLoading = true;
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would load contacts from a backend
      // For this example, we'll use mock data
      final sampleContacts = [
        UserContact(
          id: 'user1',
          name: 'John Doe',
          avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
        ),
        UserContact(
          id: 'user2',
          name: 'Jane Smith',
          avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
        ),
        UserContact(
          id: 'user3',
          name: 'Robert Johnson',
          avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
        ),
        UserContact(
          id: 'user4',
          name: 'Emily Davis',
          avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
        ),
        UserContact(
          id: 'user5',
          name: 'Michael Wilson',
          avatar: 'https://randomuser.me/api/portraits/men/3.jpg',
        ),
      ];
      
      setState(() {
        _allContacts.addAll(sampleContacts);
        _filteredContacts = List.from(_allContacts);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List.from(_allContacts);
      } else {
        _filteredContacts = _allContacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleContactSelection(UserContact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _createChat() {
    if (widget.isGroup) {
      if (_selectedContacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one contact')),
        );
        return;
      }
      
      if (_groupNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a group name')),
        );
        return;
      }
      
      // Create a group chat
      final groupName = _groupNameController.text.trim();
      final groupID = 'group_${DateTime.now().millisecondsSinceEpoch}';
      
      // In a real app, you would create the group on your backend
      // For now, we'll just return the group info
      Navigator.pop(
        context,
        ChatConversation(
          id: groupID,
          userId: groupID,
          name: groupName,
          isGroup: true,
        ),
      );
    } else {
      if (_selectedContacts.length != 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select one contact')),
        );
        return;
      }
      
      // Create a one-on-one chat
      final contact = _selectedContacts.first;
      final conversationID = 'chat_${contact.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      Navigator.pop(
        context,
        ChatConversation(
          id: conversationID,
          userId: contact.id,
          name: contact.name,
          isGroup: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroup ? 'New Group' : 'New Chat'),
        actions: [
          if (_selectedContacts.isNotEmpty)
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
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterContacts,
            ),
          ),
          if (widget.isGroup && _selectedContacts.isNotEmpty)
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
          if (_selectedContacts.isNotEmpty) _buildSelectedContactsChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? const Center(child: Text('No contacts found'))
                    : ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final isSelected = _selectedContacts.contains(contact);
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: contact.avatar != null
                                  ? NetworkImage(contact.avatar!)
                                  : null,
                              child: contact.avatar == null
                                  ? Text(contact.name[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(contact.name),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : null,
                            onTap: () => _toggleContactSelection(contact),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContactsChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _selectedContacts.map((contact) {
          return Chip(
            avatar: CircleAvatar(
              backgroundImage: contact.avatar != null
                  ? NetworkImage(contact.avatar!)
                  : null,
              child: contact.avatar == null
                  ? Text(contact.name[0].toUpperCase())
                  : null,
            ),
            label: Text(contact.name),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => _toggleContactSelection(contact),
          );
        }).toList(),
      ),
    );
  }
}

class UserContact {
  final String id;
  final String name;
  final String? avatar;

  UserContact({
    required this.id,
    required this.name,
    this.avatar,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
