
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class VideoCallPage extends StatefulWidget {
  final String? initialRoomName;
  final String? initialDisplayName;

  const VideoCallPage({
    super.key, 
    this.initialRoomName,
    this.initialDisplayName,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final jitsiMeet = JitsiMeet();
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roomController.text = widget.initialRoomName ?? '';
    _nameController.text = widget.initialDisplayName ?? '';
    if (!kIsWeb) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
  if (Platform.isIOS) {
    await Permission.camera.request();
    await Permission.microphone.request();
    
    // Check if permissions were granted
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      // Show alert dialog to explain why permissions are needed
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'Camera and microphone access is required for video calls. '
              'Please enable them in your device settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  } else {
    await Permission.camera.request();
    await Permission.microphone.request();
  }
}

  Future<void> _joinMeeting() async {
    if (_isLoading) return;

    if (_roomController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both room name and your name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        final roomName = Uri.encodeComponent(_roomController.text.trim());
        final displayName = Uri.encodeComponent(_nameController.text.trim());
        final url = Uri.parse('https://meet.jit.si/$roomName#userInfo.displayName="$displayName"');
        
        await launchUrl(
          url,
          webOnlyWindowName: '_self',
          mode: LaunchMode.inAppWebView,
        );
        return;
      } 

      // Check permissions for mobile platforms
      final cameraGranted = await Permission.camera.isGranted;
      final microphoneGranted = await Permission.microphone.isGranted;

      if (!cameraGranted || !microphoneGranted) {
        throw Exception('Camera and microphone permissions are required');
      }

      final options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.jit.si",
        room: _roomController.text.trim(),
        configOverrides: {
          "startWithAudioMuted": isAudioMuted,
          "startWithVideoMuted": isVideoMuted,
          "prejoinPageEnabled": false,
          "enableWelcomePage": false,
        },
        featureFlags: {
          "ios.recording.enabled": false,
          "android.recording.enabled": false,
          "livestreaming.enabled": false,
          "meeting-name.enabled": true,
          "raise-hand.enabled": true,
          "video-share.enabled": true,
          "calendar.enabled": false,
          "pipEnabled": true,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: _nameController.text.trim(),
          email: Supabase.instance.client.auth.currentUser?.email ?? "",
        ),
      );
    
      await jitsiMeet.join(options);
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
 void launchJitsiUrl(Uri url) {
    // This will be replaced by the appropriate method depending on the platform
    // For web, we can use window.open
    // For mobile, we can use url_launcher
    throw UnimplementedError('Implement the appropriate URL launch method for your platform');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(200, 227, 242, 250),
                              ),
                              child: const IconButton(
                                icon: Icon(Icons.person_outline, size: 36),
                                onPressed: null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Video Call',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isAudioMuted ? Icons.mic_off : Icons.mic,
                                color: const Color(0xFF0D47A1),
                              ),
                              onPressed: () => setState(() => isAudioMuted = !isAudioMuted),
                            ),
                            IconButton(
                              icon: Icon(
                                isVideoMuted ? Icons.videocam_off : Icons.videocam,
                                color: const Color(0xFF0D47A1),
                              ),
                              onPressed: () => setState(() => isVideoMuted = !isVideoMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Meeting form section
                  Card(
                    elevation: 0,
                    color: const Color(0xFFE3F2FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Join Meeting',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _nameController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _roomController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: 'Room Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.meeting_room),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _joinMeeting,
                              icon: _isLoading 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.video_call),
                              label: Text(
                                _isLoading ? 'Joining...' : 'Join Meeting',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status section
                  Card(
                    elevation: 0,
                    color: const Color(0xFFE3F2FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meeting Controls',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusItem(
                            icon: isAudioMuted ? Icons.mic_off : Icons.mic,
                            label: 'Audio',
                            status: isAudioMuted ? 'Muted' : 'Unmuted',
                          ),
                          const SizedBox(height: 12),
                          _buildStatusItem(
                            icon: isVideoMuted ? Icons.videocam_off : Icons.videocam,
                            label: 'Video',
                            status: isVideoMuted ? 'Off' : 'On',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String status,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          status,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  void dispose() {
    jitsiMeet.hangUp();
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}