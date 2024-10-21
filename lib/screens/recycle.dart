import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For handling files (images)
import 'package:flutter_map/flutter_map.dart'; // For Flutter Map
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:geolocator/geolocator.dart'; // For getting user location
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart'; // To open URLs (like attributions)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: RecyclerScreen(),
  ));
}

class RecyclerScreen extends StatefulWidget {
  @override
  _RecyclerScreenState createState() => _RecyclerScreenState();
}

class _RecyclerScreenState extends State<RecyclerScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  File? _selectedImage;
  String _selectedCategory = "Donate"; // Default category
  String? _selectedOrganization;

  Position? _currentPosition;
  bool _isLoadingLocation = false; // To track loading state for location

  // List of organizations for donation
  final List<String> _organizations = [
    "Environment Protection",
    "Community Development",
    "Educational Aid",
    "Animal Welfare",
    "Health Care",
  ];

  // Firestore reference
  CollectionReference recycledItems = FirebaseFirestore.instance.collection('recycledItems');

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Function to add a new item to Firestore
  Future<void> _addItemToFirestore() async {
    final String itemName = _itemController.text.trim();
    if (itemName.isNotEmpty) {
      await recycledItems.add({
        'name': itemName,
        'category': _selectedCategory,
        'organization': _selectedCategory == "Donate" ? _selectedOrganization : null,
        'expectedPrice': _selectedCategory == "Sell" ? _priceController.text.trim() : null,
        'itemAge': _selectedCategory == "Sell" ? _ageController.text.trim() : null,
        'imagePath': _selectedImage?.path ?? 'No Image',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear inputs after adding the item
      _itemController.clear();
      _priceController.clear();
      _ageController.clear();
      _selectedImage = null;
      _selectedOrganization = null;

      setState(() {}); // Update the UI after adding the item
    }
  }

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true; // Show loading indicator
    });
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      } catch (e) {
        print('Error getting location: $e');
        setState(() {
          _isLoadingLocation = false; // Stop loading if there's an error
        });
      }
    } else {
      setState(() {
        _isLoadingLocation = false; // Stop loading if permission is denied
      });
      print('Location permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recycler"),
        backgroundColor:Color.fromARGB(255, 62, 152, 79), // Bronze color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Text field to enter a recyclable item
            TextField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: 'Enter item name',
                labelStyle: TextStyle(color: Colors.black87), // Darker label for better contrast
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.black87),
                  onPressed: _addItemToFirestore,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Radio buttons for choosing Donate or Sell
            Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: Text('Donate', style: TextStyle(color: Colors.black87)),
                    leading: Radio<String>(
                      value: 'Donate',
                      groupValue: _selectedCategory,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Sell', style: TextStyle(color: Colors.black87)),
                    leading: Radio<String>(
                      value: 'Sell',
                      groupValue: _selectedCategory,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Dropdown for selecting organization if donating
            if (_selectedCategory == "Donate")
              DropdownButton<String>(
                hint: Text("Select Organization", style: TextStyle(color: Colors.black87)),
                value: _selectedOrganization,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOrganization = newValue;
                  });
                },
                items: _organizations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black87)),
                  );
                }).toList(),
              ),

            // Additional fields for "Sell"
            if (_selectedCategory == "Sell") ...[
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Enter Expected Price',
                  labelStyle: TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Enter Age of Item (in years)',
                  labelStyle: TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            SizedBox(height: 10),

            // Button to select an image
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image, color: Colors.white),
              label: Text('Pick Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 51, 174, 74), // Light beige background
              ),
            ),
            SizedBox(height: 10),

            // Preview of the selected image
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 150,
                  )
                : Text("No image selected", style: TextStyle(color: Colors.black45)),

            SizedBox(height: 20),

            // Interactive Map Button
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: Icon(Icons.map, color: Colors.white),
              label: Text('Show Nearby Locations', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 64, 153, 50), // Dark brown color for map button
              ),
            ),

            SizedBox(height: 20),

            // Show loading indicator while getting location
            if (_isLoadingLocation)
              Center(child: CircularProgressIndicator())
            else if (_currentPosition != null)
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), // Dynamic user location
                    initialZoom: 9.2, // Initial zoom level
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                      userAgentPackageName: 'com.example.app',
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Center(child: Text("Map not available")),

            // List of recycled items
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: recycledItems.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final name = doc['name'];
                      final category = doc['category'];

                      return ListTile(
                        title: Text(name, style: TextStyle(color: Colors.black87)),
                        subtitle: Text("Category: $category", style: TextStyle(color: Colors.black54)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
