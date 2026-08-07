/// RiderMate 2.0 — Emergency Contact Model
class EmergencyContactModel {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final int orderIndex;

  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relation': relation,
        'phone': phone,
        'orderIndex': orderIndex,
      };

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) => EmergencyContactModel(
        id: json['id'] as String,
        name: json['name'] as String,
        relation: json['relation'] as String,
        phone: json['phone'] as String,
        orderIndex: json['orderIndex'] as int,
      );
}
