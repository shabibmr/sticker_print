import 'package:equatable/equatable.dart';

/// Configuration model for storing Odoo connection settings
class AppConfig extends Equatable {
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
  final String fieldTestedDate;
  final String fieldSetPres;
  final String fieldTestMedium;

  // Printer configuration
  final String? defaultPrinter;
  final double labelWidth;
  final double labelHeight;
  final String labelStyle;

  const AppConfig({
    this.odooUrl = 'https://test2.graycodeanalytica.com',
    this.database = 'run.qatar.dimemarine.com.001',
    this.username = 'api_user@dimemarine.com',
    this.password = '1ddf392b3daf7b0344cb7a82c9b2dc43a4dc5004',
    this.modelJobOrder = 'sale.order',
    this.modelCertificate = 'dm.certificate',
    this.fieldRelation = 'order_id',
    this.fieldSerial = 'sequence_number',
    this.fieldCertNo = 'name',
    this.fieldIssueDate = 'calibration_date',
    this.fieldExpiryDate = 'date_expiry',
    this.fieldTestedDate = 'tested_date',
    this.fieldSetPres = 'set_pressure',
    this.fieldTestMedium = 'test_medium',
    this.defaultPrinter,
    this.labelWidth = 30.0,
    this.labelHeight = 18.0,
    this.labelStyle = 'style_1',
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
    'fieldTestedDate': fieldTestedDate,
    'fieldSetPres': fieldSetPres,
    'fieldTestMedium': fieldTestMedium,
    'defaultPrinter': defaultPrinter,
    'labelWidth': labelWidth,
    'labelHeight': labelHeight,
    'labelStyle': labelStyle,
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
      fieldSerial: json['fieldSerial'] ?? 'sequence_number',
      fieldCertNo: json['fieldCertNo'] ?? 'name',
      fieldIssueDate: json['fieldIssueDate'] ?? 'calibration_date',
      fieldExpiryDate: json['fieldExpiryDate'] ?? 'date_expiry',
      fieldTestedDate: json['fieldTestedDate'] ?? 'tested_date',
      fieldSetPres: json['fieldSetPres'] ?? 'set_pressure',
      fieldTestMedium: json['fieldTestMedium'] ?? 'test_medium',
      defaultPrinter: json['defaultPrinter'],
      labelWidth: (json['labelWidth'] ?? 30.0).toDouble(),
      labelHeight: (json['labelHeight'] ?? 18.0).toDouble(),
      labelStyle: json['labelStyle'] ?? 'style_1',
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
    String? fieldTestedDate,
    String? fieldSetPres,
    String? fieldTestMedium,
    String? defaultPrinter,
    bool clearDefaultPrinter = false,
    double? labelWidth,
    double? labelHeight,
    String? labelStyle,
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
      fieldTestedDate: fieldTestedDate ?? this.fieldTestedDate,
      fieldSetPres: fieldSetPres ?? this.fieldSetPres,
      fieldTestMedium: fieldTestMedium ?? this.fieldTestMedium,
      defaultPrinter: clearDefaultPrinter ? null : (defaultPrinter ?? this.defaultPrinter),
      labelWidth: labelWidth ?? this.labelWidth,
      labelHeight: labelHeight ?? this.labelHeight,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  List<Object?> get props => [
    odooUrl, database, username, password,
    modelJobOrder, modelCertificate, fieldRelation,
    fieldSerial, fieldCertNo, fieldIssueDate, fieldExpiryDate,
    fieldTestedDate, fieldSetPres, fieldTestMedium,
    defaultPrinter, labelWidth, labelHeight, labelStyle,
  ];
}
