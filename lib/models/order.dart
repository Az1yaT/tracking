class Order {
  final String id;
  final String? senderName;
  final String? senderPhone;
  final String? receiverName;
  final String? receiverPhone;
  final String? address;
  final String? status;
  final String? courierId;
  final String? courierName;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    this.senderName,
    this.senderPhone,
    this.receiverName,
    this.receiverPhone,
    this.address,
    this.status,
    this.courierId,
    this.courierName,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      senderName: json['sender_name'],
      senderPhone: json['sender_phone'],
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      address: json['address'],
      status: json['status'],
      courierId: json['courier_id'],
      courierName: json['courier_name'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'address': address,
      'status': status,
      'courier_id': courierId,
      'courier_name': courierName,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}