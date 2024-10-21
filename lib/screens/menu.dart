import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green/screens/auth.dart';
import 'package:green/screens/carbonfootprint_calculator.dart';
import 'package:green/screens/cart.dart';
import 'package:green/screens/chatbot_screen.dart';
import 'package:green/screens/dashboard.dart';
import 'package:green/screens/eco_apps_screen.dart';
import 'package:green/screens/green_shop.dart';
import 'package:green/screens/order_history_screen.dart';
import 'package:green/screens/recycle.dart';
import 'package:green/screens/profile.dart';
import 'package:green/screens/order.dart'; // Import OrderScreen
import 'package:green/screens/orderDetailsScreen.dart'; // Import OrderDetailsScreen
import 'package:shared_preferences/shared_preferences.dart'; // For shared preferences

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final appTitle = 'EcoFootprint';
  String? userEmail;
  String? userName;
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _showCarbonFootprintTip(); // Call the method to show the tip when the app opens
  }

  // Fetch user details from Firebase
  void _getUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userEmail = user.email;
          userName = userData['username'];
          isLoading = false; // Set loading to false when done
        });
      } else {
        setState(() {
          isLoading = false; // Set loading to false if user is null
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  // Show a popup dialog with a carbon footprint tip
  void _showCarbonFootprintTip() async {
    final prefs = await SharedPreferences.getInstance();
    bool? hasVisited = prefs.getBool('hasVisited');

    if (hasVisited == null || !hasVisited) {
      _showTipDialog();
      await prefs.setBool('hasVisited', true); // Update the visit status
    }
  }

  void _showTipDialog() {
    final carbonFootprintTips = [
      'Reduce your meat consumption to help lower greenhouse gas emissions from livestock.',
      'Use energy-efficient appliances to cut down on electricity usage.',
      'Walk, bike, or use public transportation to reduce your carbon footprint.',
      'Plant trees to absorb carbon dioxide from the atmosphere.',
      'Cut down on plastic use to minimize fossil fuel-based production and waste.',
      'Switch to renewable energy sources like solar or wind power for a greener footprint.',
    ];

    // Pick a random tip from the list
    final randomTip = (carbonFootprintTips..shuffle()).first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Carbon Footprint Tip'),
          content: Text(randomTip),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : MyHomePage(
              title: appTitle,
              userEmail: userEmail,
              userName: userName,
              showPopup: _showTipDialog, // Pass the method to show the tip popup
            ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final String? userEmail;
  final String? userName;
  final Function showPopup;

  const MyHomePage({
    super.key,
    required this.title,
    required this.userEmail,
    required this.userName,
    required this.showPopup,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 59, 89, 152),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Large sustainability image at the top
          Container(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/big.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
          ),
          // Grid for Carbon Footprint, Recycler, E-store, AI Chatbot, and Eco Apps
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20.0),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildCard(
                  context,
                  'Carbon Footprint',
                  'assets/images/green.png',
                CarbonFootprintCalculatorPage(),
                ),
                _buildCard(
                  context,
                  'Green Store',
                  'assets/images/estore.jpg',
                  GreenShopScreen(),
                ),
                _buildCard(
                  context,
                  'Recycler',
                  'assets/images/recycler.jpg',
                  RecyclerScreen(),
                ),
                _buildCard(
                  context,
                  'Eco Apps',
                  'assets/images/recycle.jpg',
                  EcoAppsScreen(),
                ),
                _buildCard(
                  context,
                  'AI Chatbot',
                  'assets/images/chatbot.png',
                  ChatbotScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 59, 89, 152),
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color.fromARGB(255, 49, 76, 129)),
                accountName: Text(userName ?? 'No username found'),
                accountEmail: Text(userEmail ?? 'No email found'),
                currentAccountPictureSize: const Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 38, 50, 56),
                  child: Text(
                    userName != null ? userName![0].toUpperCase() : 'A',
                    style: const TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userEmail: userEmail,
                      userName: userName,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String imagePath, Widget screen) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
