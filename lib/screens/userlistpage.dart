import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thenewvideocallapp/screens/video_call_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  RealtimeChannel? _statusChannel;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _setupRealtimeSubscription();
    _updateUserStatus('online'); // Set current user's status to online
  }

  Future<void> _updateUserStatus(String status) async {
    try {
      await _supabase.from('profiles')
          .update({'status': status})
          .eq('id', _supabase.auth.currentUser!.id);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  
  void _setupRealtimeSubscription() {
    _statusChannel = _supabase.channel('public:profiles')
    .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'profiles',
      callback: (payload) {
        _loadUsers(); // Reload users when someone's status changes
      },
    )
    .subscribe();

  }

  Future<void> _loadUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
          id,
          first_name,
          last_name,
          school,
          grade,
          profile_picture,
          status,
          is_verified
        ''')
          .neq('id', _supabase.auth.currentUser!.id);
          

      if (mounted) {
        setState(() {
          _users = (response as List<dynamic>).cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
         setState(() {
        _users = [];
        _loading = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
        );
        setState(() => _loading = false);
      }
    }
  }

  void _startCallWithUser(Map<String, dynamic> user) {
    // Create a unique room name using both user IDs
    final myId = _supabase.auth.currentUser!.id;
    final peerId = user['id'];
    // Sort IDs to ensure consistent room names regardless of who initiates
    final sortedIds = [myId, peerId]..sort();
    final roomName = 'call_${sortedIds.join('_')}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallPage(
          initialRoomName: roomName,
          initialDisplayName: '${user['first_name']} ${user['last_name']}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter users to show online users first
    final onlineUsers = _users.where((u) => u['status'] == 'online').toList();
    final offlineUsers = _users.where((u) => u['status'] != 'online').toList();
    final sortedUsers = [...onlineUsers, ...offlineUsers];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Peers',
            style: TextStyle(color: Color(0xFF0D47A1))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : sortedUsers.isEmpty
              ? const Center(
                  child: Text('No other users available',
                      style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedUsers.length,
                  itemBuilder: (context, index) {
                    final user = sortedUsers[index];
                    final isOnline = user['status'] == 'online';
                    
                    return _buildUserCard(user, isOnline);
                  },
                ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isOnline) {
    final fullName = 
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    
    return Card(
      elevation: 0,
      color: const Color(0xFFE3F2FA),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF0D47A1),
              backgroundImage: user['profile_picture'] != null
                  ? NetworkImage(user['profile_picture'])
                  : null,
              child: user['profile_picture'] == null
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['school'] != null)
              Text(
                user['school'],
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (user['grade'] != null)
              Text(
                'Grade ${user['grade']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.video_call,
            color: Color(0xFF0D47A1),
            size: 32,
          ),
          onPressed: isOnline ? () => _startCallWithUser(user) : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _updateUserStatus('offline');
    _statusChannel?.unsubscribe();
    super.dispose();
  }
}