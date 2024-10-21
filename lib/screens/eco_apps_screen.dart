import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:green/screens/details.dart';

class EcoAppsScreen extends StatefulWidget {
  const EcoAppsScreen({Key? key}) : super(key: key);

  @override
  _EcoAppsScreenState createState() => _EcoAppsScreenState();
}

class _EcoAppsScreenState extends State<EcoAppsScreen> {
  final CollectionReference _sustainableAppsCollection =
      FirebaseFirestore.instance.collection('recommendations');
  String _selectedCategory = 'All';


  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(imageUrl, fit: BoxFit.cover),
        );
      },
    );
  }

  void _navigateToDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  String _trimDescription(String description, {int maxLength = 50}) {
    if (description.length > maxLength) {
      return description.substring(0, maxLength) + '...';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Apps'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            items: <String>['All', 'Recycling', 'Energy Saving', 'Eco Shopping']
                .map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                // Apply filtering logic
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _sustainableAppsCollection
            .where('category', isEqualTo: _selectedCategory == 'All' ? null : _selectedCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          final List<DocumentSnapshot> documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(child: Text('No apps found'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> product =
                  documents[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () => _navigateToDetails(product),
                  leading: GestureDetector(
                    onTap: () => _showFullImage(product['imageUrl']),
                    child: product['imageUrl'] != null && product['imageUrl'] != ''
                        ? Image.network(
                            product['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                  ),
                  title: Text(product['name'] ?? 'Unknown'),
                  subtitle: Text(
                    _trimDescription(product['description'] ?? 'No description'),
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
