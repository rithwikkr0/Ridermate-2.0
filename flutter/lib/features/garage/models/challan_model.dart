class ChallanModel {
  final String id;
  final String vehicleId;
  final String userId;
  final String challanNumber;
  final double amount;
  final DateTime date;
  final String authority;
  final String offense;
  final String status;
  final String source;
  final DateTime createdAt;

  const ChallanModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.challanNumber,
    required this.amount,
    required this.date,
    required this.authority,
    required this.offense,
    required this.status,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'user_id': userId,
      'challan_number': challanNumber,
      'amount': amount,
      'date': date.toIso8601String(),
      'authority': authority,
      'offense': offense,
      'status': status,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChallanModel.fromMap(Map<String, dynamic> map) {
    return ChallanModel(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      userId: map['user_id'] as String,
      challanNumber: map['challan_number'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] as String),
      authority: map['authority'] as String? ?? '',
      offense: map['offense'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      source: map['source'] as String? ?? 'manual',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ChallanModel copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? challanNumber,
    double? amount,
    DateTime? date,
    String? authority,
    String? offense,
    String? status,
    String? source,
    DateTime? createdAt,
  }) {
    return ChallanModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      challanNumber: challanNumber ?? this.challanNumber,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      authority: authority ?? this.authority,
      offense: offense ?? this.offense,
      status: status ?? this.status,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
