class BookingModel {
  final String id, parentId, nannyId, status, address;
  final DateTime date;
  final String startTime, endTime;
  final int numberOfChildren;
  final List<int> childrenAges;
  final double totalPrice, commission;
  final String? notes;

  BookingModel({required this.id, required this.parentId, required this.nannyId, required this.date, required this.startTime, required this.endTime, required this.numberOfChildren, required this.childrenAges, required this.totalPrice, required this.commission, required this.status, required this.address, this.notes});
}
