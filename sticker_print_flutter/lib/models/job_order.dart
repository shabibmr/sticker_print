/// Job Order model representing a project or work order
class JobOrder {
  final int id;
  final String name;

  JobOrder({
    required this.id,
    required this.name,
  });

  /// Create from Odoo search_read result
  factory JobOrder.fromOdoo(Map<String, dynamic> data) {
    return JobOrder(
      id: data['id'] as int,
      name: data['name']?.toString() ?? 'Unnamed Job',
    );
  }

  @override
  String toString() => 'JobOrder(id: $id, name: $name)';
}
