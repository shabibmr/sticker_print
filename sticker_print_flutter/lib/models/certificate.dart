import 'package:equatable/equatable.dart';

/// Certificate model representing a label to be printed
class Certificate extends Equatable {
  final int id;
  final String name;
  final String serial;
  final String certNo;
  final String issueDate;
  final String expiryDate;
  final String testedDate;
  final String setPressure;
  final String testMedium;

  const Certificate({
    required this.id,
    this.name = '',
    this.serial = '',
    this.certNo = '',
    this.issueDate = '',
    this.expiryDate = '',
    this.testedDate = '',
    this.setPressure = '',
    this.testMedium = '',
  });

  /// Odoo returns false (bool) instead of null for empty fields — normalise to ''.
  static String _odooStr(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  /// Create from Odoo search_read result
  factory Certificate.fromOdoo(
    Map<String, dynamic> data, {
    required String fieldSerial,
    required String fieldCertNo,
    required String fieldIssueDate,
    required String fieldExpiryDate,
    required String fieldTestedDate,
    required String fieldSetPres,
    required String fieldTestMedium,
  }) {
    return Certificate(
      id: data['id'] as int,
      name: _odooStr(data['name']).isNotEmpty ? _odooStr(data['name']) : 'No Name',
      serial: _odooStr(data[fieldSerial]),
      certNo: _odooStr(data[fieldCertNo]),
      issueDate: _odooStr(data[fieldIssueDate]),
      expiryDate: _odooStr(data[fieldExpiryDate]),
      testedDate: _odooStr(data[fieldTestedDate]),
      setPressure: _odooStr(data[fieldSetPres]),
      testMedium: _odooStr(data[fieldTestMedium]),
    );
  }

  /// Get the last segment of certNo split by "/"
  String get shortCertNo {
    if (certNo.isEmpty) return '';
    final parts = certNo.split('/');
    return parts.last;
  }

  /// Format tested date for display (DD/MM/YYYY)
  String get formattedTestedDate {
    if (testedDate.isEmpty) return '';
    try {
      final date = DateTime.parse(testedDate);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return testedDate;
    }
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

  @override
  List<Object?> get props => [id, name, serial, certNo, issueDate, expiryDate, testedDate, setPressure, testMedium];

  @override
  String toString() {
    return 'Certificate(id: $id, name: $name, serial: $serial, certNo: $certNo, issueDate: $issueDate, expiryDate: $expiryDate, testedDate: $testedDate, setPressure: $setPressure, testMedium: $testMedium)';
  }
}
