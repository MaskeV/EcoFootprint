import 'package:flutter/material.dart';
import 'package:green/screens/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  OrderDetailsScreen({required this.order});

  // Define your order stages
  final List<String> stages = [
    'Order Placed',
    'Processing',
    'Shipped',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            _buildOrderSummary(),
            SizedBox(height: 20),

            // Divider
            Divider(height: 2, thickness: 2, color: Colors.grey.shade300),

            // Items Section
            SizedBox(height: 20),
            Text('Items:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildItemsList(),
            SizedBox(height: 20),

            // Order Roadmap Section
            Divider(height: 2, thickness: 2, color: Colors.grey.shade300),
            SizedBox(height: 20),
            Text('Order Roadmap:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildOrderRoadmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text('Total Price: Rs. ${order.totalPrice}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Text('Order Placed: ${order.orderDate.toLocal().toString().split(' ')[0]} at ${order.orderDate.toLocal().toString().split(' ')[1].substring(0, 5)}', style: TextStyle(fontSize: 18)), // Display date and time
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      itemBuilder: (ctx, i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${order.items[i]['name']} x ${order.items[i]['quantity']}',
            style: TextStyle(fontSize: 18), // Increased font size
          ),
        );
      },
    );
  }

  Widget _buildOrderRoadmap() {
    return Column(
      children: List.generate(stages.length, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Circle for each stage
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: index < _getCurrentStageIndex() ? Colors.green : Colors.grey,
                ),
                if (index < stages.length - 1) // Connect the stages with a line
                  Container(
                    width: 2,
                    height: 30,
                    color: index < _getCurrentStageIndex() ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            SizedBox(width: 10), // Space between circle and text
            Expanded(child: Text(stages[index], style: TextStyle(fontSize: 16))),
          ],
        );
      }),
    );
  }

  // Function to determine the current stage index based on the order status
  int _getCurrentStageIndex() {
    switch (order.orderStatus) {
      case 'Processing':
        return 1; // Processing
      case 'Shipped':
        return 2; // Shipped
      case 'Delivered':
        return 3; // Delivered
      default:
        return 0; // Order Placed
    }
  }
}

