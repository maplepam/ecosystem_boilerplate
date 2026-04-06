import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_detail_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmployeeAssignmentDetailResponse', () {
    test('profileIdFromFirstItem reads first item profile_id', () {
      const String jsonStr = '''
{
  "status_code": 200,
  "data": {
    "items": [
      { "profile_id": "prof-1", "employee_number": "1" }
    ]
  }
}''';
      final EmployeeAssignmentDetailResponse r =
          EmployeeAssignmentDetailResponse.fromDynamic(jsonStr);
      expect(r.statusCode, 200);
      expect(r.profileIdFromFirstItem, 'prof-1');
    });

    test('profileIdFromFirstItem is empty when items missing', () {
      final EmployeeAssignmentDetailResponse r =
          EmployeeAssignmentDetailResponse.fromJson(<String, dynamic>{
        'status_code': 200,
        'data': <String, dynamic>{'items': <dynamic>[]},
      });
      expect(r.profileIdFromFirstItem, '');
    });

    test('resolvedCompanyClientRecipientId falls back to company_hcm_reference_id',
        () {
      final EmployeeAssignmentDetailItem item = EmployeeAssignmentDetailItem.fromJson(
        <String, dynamic>{
          'profile_id': 'p1',
          'company_hcm_reference_id': 'hcm-uuid-1',
          'employee_assignment_id': 'ea-1',
        },
      );
      expect(item.companyId, isNull);
      expect(item.resolvedCompanyClientRecipientId, 'hcm-uuid-1');
    });
  });
}
