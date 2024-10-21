class Order {
  final String id;
  final List<Map<String, dynamic>> items; // Change this to match how you structure items
  final double totalPrice;
  final String orderStatus;
  final DateTime orderDate;
  final String paymentId;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.orderStatus,
    required this.orderDate,
    required this.paymentId,
  });
}
