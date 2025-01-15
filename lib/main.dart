import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thenewvideocallapp/screens/login_page.dart';
import 'package:thenewvideocallapp/screens/profile_page.dart';
import 'package:thenewvideocallapp/screens/userlistpage.dart';
import 'package:thenewvideocallapp/screens/video_call_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://sjqlnrztidffvuapbijf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqcWxucnp0aWRmZnZ1YXBiaWpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc0MjY1ODEsImV4cCI6MjA0MzAwMjU4MX0.VPRwCLYdj3H3axMwLVsjFLaKOGzaJJftpDH-Ae-KLKI',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Call App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final session = snapshot.data!.session;
            // If user is logged in, show HomePage
            if (session != null) {
              return const HomePage();
            }
          }
          // If user is not logged in, show LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}

// Home content widget for the first tab
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
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
                    'Video Calls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Main content
            Expanded(
              child: Center(
                child: Card(
                  elevation: 0,
                  color: const Color(0xFFE3F2FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.video_call,
                          size: 64,
                          color: Color(0xFF0D47A1),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Start or Join a Meeting',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Connect with others through video calls',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VideoCallPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Start Video Call',
                              style: TextStyle(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressedTime;

   final _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  final List<Widget> _pages = [
    const HomeContent(),
    const UserListPage(),
    const ProfilePage(),

  ];

  void _showExitToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Press back again to exit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

         final currentNavigatorKey = _navigatorKeys[_selectedIndex];
        final canPop = await currentNavigatorKey?.currentState?.maybePop() ?? false;
        
        if (!canPop) {
          final DateTime currentTime = DateTime.now();
          if (_lastBackPressedTime == null ||
              currentTime.difference(_lastBackPressedTime!) > const Duration(seconds: 2)) {
            _lastBackPressedTime = currentTime;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Press back again to exit')),
            );
            return;
          }
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages.asMap().map((index, page) {
            return MapEntry(
              index,
              Navigator(
                key: _navigatorKeys[index],
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => page,
                    settings: settings,
                  );
                },
              ),
            );
          }).values.toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}