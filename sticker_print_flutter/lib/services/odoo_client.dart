import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/app_config.dart';
import '../models/job_order.dart';
import '../models/certificate.dart';

/// Odoo XML-RPC Client - handles all communication with Odoo server
/// 
/// ✅ NO CORS ISSUES - Direct HTTP from Flutter app
class OdooClient {
  final AppConfig config;
  int? _uid;

  OdooClient(this.config);

  /// Build XML-RPC method call
  String _buildXmlCall(String methodName, List<dynamic> params) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('methodCall', nest: () {
      builder.element('methodName', nest: methodName);
      builder.element('params', nest: () {
        for (final param in params) {
          builder.element('param', nest: () {
            builder.element('value', nest: () {
              _buildXmlValue(builder, param);
            });
          });
        }
      });
    });
    return builder.buildDocument().toXmlString();
  }

  /// Convert Dart value to XML-RPC value
  void _buildXmlValue(XmlBuilder builder, dynamic value) {
    if (value == null) {
      builder.element('nil');
    } else if (value is bool) {
      builder.element('boolean', nest: value ? '1' : '0');
    } else if (value is int) {
      builder.element('int', nest: value.toString());
    } else if (value is double) {
      builder.element('double', nest: value.toString());
    } else if (value is String) {
      builder.element('string', nest: value);
    } else if (value is List) {
      builder.element('array', nest: () {
        builder.element('data', nest: () {
          for (final item in value) {
            builder.element('value', nest: () {
              _buildXmlValue(builder, item);
            });
          }
        });
      });
    } else if (value is Map) {
      builder.element('struct', nest: () {
        for (final entry in value.entries) {
          builder.element('member', nest: () {
            builder.element('name', nest: entry.key.toString());
            builder.element('value', nest: () {
              _buildXmlValue(builder, entry.value);
            });
          });
        }
      });
    }
  }

  /// Parse XML-RPC response
  dynamic _parseXmlResponse(String xmlText) {
    final document = XmlDocument.parse(xmlText);

    // Check for fault
    final fault = document.findAllElements('fault').firstOrNull;
    if (fault != null) {
      final faultValue = _parseXmlValue(fault.findElements('value').first);
      throw Exception(
          'Odoo Error: ${faultValue['faultString']} (${faultValue['faultCode']})');
    }

    // Parse response
    final param = document
        .findAllElements('methodResponse')
        .first
        .findAllElements('params')
        .first
        .findAllElements('param')
        .first
        .findElements('value')
        .first;

    return _parseXmlValue(param);
  }

  /// Parse XML value recursively
  dynamic _parseXmlValue(XmlElement valueNode) {
    final child = valueNode.childElements.firstOrNull;
    if (child == null) return valueNode.innerText;

    switch (child.name.local) {
      case 'string':
        return child.innerText;
      case 'int':
      case 'i4':
        return int.parse(child.innerText);
      case 'double':
        return double.parse(child.innerText);
      case 'boolean':
        return child.innerText == '1';
      case 'nil':
        return null;
      case 'array':
        final dataNode = child.findElements('data').first;
        return dataNode.findElements('value').map(_parseXmlValue).toList();
      case 'struct':
        final map = <String, dynamic>{};
        for (final member in child.findElements('member')) {
          final name = member.findElements('name').first.innerText;
          final value = member.findElements('value').first;
          map[name] = _parseXmlValue(value);
        }
        return map;
      default:
        return child.innerText;
    }
  }

  /// Execute XML-RPC call
  Future<dynamic> _execute(String endpoint, String method,
      List<dynamic> params) async {
    final url = '${config.odooUrl}/xmlrpc/2/$endpoint';
    final body = _buildXmlCall(method, params);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'text/xml'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          'HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
    }

    return _parseXmlResponse(response.body);
  }

  /// Authenticate and get UID
  Future<int> authenticate() async {
    final params = [
      config.database,
      config.username,
      config.password,
      {},
    ];

    final uid = await _execute('common', 'authenticate', params);

    if (uid == null || uid == false) {
      throw Exception('Authentication failed. Check credentials.');
    }

    _uid = uid as int;
    return _uid!;
  }

  /// Search and read records
  Future<List<dynamic>> searchRead(
    String model,
    List<dynamic> domain,
    List<String> fields,
  ) async {
    if (_uid == null) await authenticate();

    final params = [
      config.database,
      _uid,
      config.password,
      model,
      'search_read',
      [domain],
      {'fields': fields, 'limit': 100},
    ];

    final result = await _execute('object', 'execute_kw', params);
    return result as List<dynamic>;
  }

  /// List job orders
  Future<List<JobOrder>> listJobOrders({String searchTerm = ''}) async {
    final model = config.modelJobOrder;
    final domain = searchTerm.isEmpty
        ? []
        : [
            ['name', 'ilike', searchTerm]
          ];

    final results = await searchRead(model, domain, ['id', 'name']);
    return results.map((data) => JobOrder.fromOdoo(data as Map<String, dynamic>)).toList();
  }

  /// List certificates for a job order
  Future<List<Certificate>> listCertificates(int jobOrderId) async {
    final model = config.modelCertificate;
    final relationField = config.fieldRelation;

    final domain = [
      [relationField, '=', jobOrderId]
    ];

    final fields = [
      'id',
      'name',
      config.fieldSerial,
      config.fieldCertNo,
      config.fieldIssueDate,
      config.fieldExpiryDate,
    ];

    final results = await searchRead(model, domain, fields);
    return results
        .map((data) => Certificate.fromOdoo(
              data as Map<String, dynamic>,
              fieldSerial: config.fieldSerial,
              fieldCertNo: config.fieldCertNo,
              fieldIssueDate: config.fieldIssueDate,
              fieldExpiryDate: config.fieldExpiryDate,
            ))
        .toList();
  }
}
