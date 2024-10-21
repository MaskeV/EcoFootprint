import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green/screens/orderDetailsScreen.dart';
import 'package:green/screens/order.dart' as custom_order; // Import the Order model

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: const Color.fromARGB(255, 59, 89, 152),
      ),
      body: currentUser == null
          ? Center(child: Text('Please log in to view your orders.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: currentUser.uid) // Fetch orders for the logged-in user
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching orders: ${snapshot.error}'));
                }

                // Map through the documents in the snapshot
                final orders = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>; // Get the data as a map

                  // Create a list of items from the data
                  List<Map<String, dynamic>> itemsList = List<Map<String, dynamic>>.from(data['items'] ?? []);

                  return custom_order.Order(
                    id: doc.id,
                    items: itemsList, // Store the list of items
                    totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0, // Total price
                    orderStatus: data['orderStatus'] ?? 'Unknown', // Provide default if null
                    orderDate: (data['orderDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
                    paymentId: data['paymentId'] ?? 'Unknown', // Add paymentId
                  );
                }).toList();

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text('Order ID: ${orders[i].id}'),
                        subtitle: Text(
                          'Total: Rs. ${orders[i].totalPrice}\n'
                          'Status: ${orders[i].orderStatus}',
                        ),
                        trailing: Text(
                          '${orders[i].orderDate.toLocal()}'.split(' ')[0], // Display only the date
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: orders[i]), // Navigate to order details
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
