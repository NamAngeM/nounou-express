class BookingModel {
  final String id, parentId, nannyId, status, address;
  final DateTime date;
  final String startTime, endTime;
  final int numberOfChildren;
  final List<int> childrenAges;
  final double totalPrice, commission;
  final String? notes;

  BookingModel({
    required this.id,
    required this.parentId,
    required this.nannyId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.numberOfChildren,
    required this.childrenAges,
    required this.totalPrice,
    required this.commission,
    required this.status,
    required this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'nannyId': nannyId,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'numberOfChildren': numberOfChildren,
    'childrenAges': childrenAges,
    'totalPrice': totalPrice,
    'commission': commission,
    'status': status,
    'address': address,
    'notes': notes,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'] as String? ?? '',
    parentId: json['parentId'] as String? ?? '',
    nannyId: json['nannyId'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    startTime: json['startTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    numberOfChildren: (json['numberOfChildren'] as num?)?.toInt() ?? 0,
    childrenAges:
        (json['childrenAges'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [],
    totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    commission: (json['commission'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? '',
    address: json['address'] as String? ?? '',
    notes: json['notes'] as String?,
  );
}
