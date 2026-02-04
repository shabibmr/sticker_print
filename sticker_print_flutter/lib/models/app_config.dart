/// Configuration model for storing Odoo connection settings
class AppConfig {
  final String odooUrl;
  final String database;
  final String username;
  final String password;
  
  // Model configuration
  final String modelJobOrder;
  final String modelCertificate;
  final String fieldRelation;
  
  // Field mappings
  final String fieldSerial;
  final String fieldCertNo;
  final String fieldIssueDate;
  final String fieldExpiryDate;

  AppConfig({
    this.odooUrl = 'https://test2.graycodeanalytica.com',
    this.database = 'run.qatar.dimemarine.com.001',
    this.username = 'api_user@dimemarine.com',
    this.password = '1ddf392b3daf7b0344cb7a82c9b2dc43a4dc5004',
    this.modelJobOrder = 'sale.order',
    this.modelCertificate = 'dm.certificate',
    this.fieldRelation = 'order_id',
    this.fieldSerial = 'serial_number',
    this.fieldCertNo = 'name',
    this.fieldIssueDate = 'calibration_date',
    this.fieldExpiryDate = 'date_expiry',
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'odooUrl': odooUrl,
        'database': database,
        'username': username,
        'password': password,
        'modelJobOrder': modelJobOrder,
        'modelCertificate': modelCertificate,
        'fieldRelation': fieldRelation,
        'fieldSerial': fieldSerial,
        'fieldCertNo': fieldCertNo,
        'fieldIssueDate': fieldIssueDate,
        'fieldExpiryDate': fieldExpiryDate,
      };

  /// Create from JSON
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      odooUrl: json['odooUrl'] ?? 'https://test2.graycodeanalytica.com',
      database: json['database'] ?? 'run.qatar.dimemarine.com.001',
      username: json['username'] ?? 'api_user@dimemarine.com',
      password: json['password'] ?? '1ddf392b3daf7b0344cb7a82c9b2dc43a4dc5004',
      modelJobOrder: json['modelJobOrder'] ?? 'sale.order',
      modelCertificate: json['modelCertificate'] ?? 'dm.certificate',
      fieldRelation: json['fieldRelation'] ?? 'order_id',
      fieldSerial: json['fieldSerial'] ?? 'serial_number',
      fieldCertNo: json['fieldCertNo'] ?? 'name',
      fieldIssueDate: json['fieldIssueDate'] ?? 'calibration_date',
      fieldExpiryDate: json['fieldExpiryDate'] ?? 'date_expiry',
    );
  }

  /// Check if all required connection fields are filled
  bool get isValid {
    return odooUrl.isNotEmpty &&
        database.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty;
  }

  /// Create a copy with updated fields
 AppConfig copyWith({
    String? odooUrl,
    String? database,
    String? username,
    String? password,
    String? modelJobOrder,
    String? modelCertificate,
    String? fieldRelation,
    String? fieldSerial,
    String? fieldCertNo,
    String? fieldIssueDate,
    String? fieldExpiryDate,
  }) {
    return AppConfig(
      odooUrl: odooUrl ?? this.odooUrl,
      database: database ?? this.database,
      username: username ?? this.username,
      password: password ?? this.password,
      modelJobOrder: modelJobOrder ?? this.modelJobOrder,
      modelCertificate: modelCertificate ?? this.modelCertificate,
      fieldRelation: fieldRelation ?? this.fieldRelation,
      fieldSerial: fieldSerial ?? this.fieldSerial,
      fieldCertNo: fieldCertNo ?? this.fieldCertNo,
      fieldIssueDate: fieldIssueDate ?? this.fieldIssueDate,
      fieldExpiryDate: fieldExpiryDate ?? this.fieldExpiryDate,
    );
  }
}
