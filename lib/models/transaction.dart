class Transaction {
  final int? id;
  final double amount;
  final String phoneNumber;
  final String? contactName;
  final String network;
  final String category;
  final String? note;
  final bool isSuccessful;
  final DateTime createdAt;
  final double fee;

  Transaction({
    this.id,
    required this.amount,
    required this.phoneNumber,
    this.contactName,
    required this.network,
    required this.category,
    this.note,
    required this.isSuccessful,
    required this.createdAt,
    required this.fee,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'phone_number': phoneNumber,
      'contact_name': contactName,
      'network': network,
      'category': category,
      'note': note,
      'is_successful': isSuccessful ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'fee': fee,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      phoneNumber: map['phone_number'],
      contactName: map['contact_name'],
      network: map['network'],
      category: map['category'],
      note: map['note'],
      isSuccessful: map['is_successful'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      fee: map['fee'] ?? 0.0,
    );
  }
}
