/// Certificate model representing a label to be printed
class Certificate {
  final int id;
  final String name;
  final String serial;
  final String certNo;
  final String issueDate;
  final String expiryDate;

  Certificate({
    required this.id,
    this.name = '',
    this.serial = '',
    this.certNo = '',
    this.issueDate = '',
    this.expiryDate = '',
  });

  /// Create from Odoo search_read result
  factory Certificate.fromOdoo(Map<String, dynamic> data, {
    required String fieldSerial,
    required String fieldCertNo,
    required String fieldIssueDate,
    required String fieldExpiryDate,
  }) {
    return Certificate(
      id: data['id'] as int,
      name: data['name']?.toString() ?? 'No Name',
      serial: data[fieldSerial]?.toString() ?? '',
      certNo: data[fieldCertNo]?.toString() ?? '',
      issueDate: data[fieldIssueDate]?.toString() ?? '',
      expiryDate: data[fieldExpiryDate]?.toString() ?? '',
    );
  }

  /// Format issue date for display (DD/MM/YYYY)
  String get formattedIssueDate {
    if (issueDate.isEmpty) return '';
    try {
      final date = DateTime.parse(issueDate);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return issueDate; // Return as-is if parsing fails
    }
  }

  /// Format expiry date for display (DD/MM/YYYY)
  String get formattedExpiryDate {
    if (expiryDate.isEmpty) return '';
    try {
      final date = DateTime.parse(expiryDate);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return expiryDate; // Return as-is if parsing fails
    }
  }
}
