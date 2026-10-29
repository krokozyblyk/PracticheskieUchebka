import '../models/appointment.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'api_repository_base.dart';
import 'appointment_repository.dart';

class ApiAppointmentRepository extends ApiRepositoryBase<Appointment>
    implements AppointmentRepository {
  ApiAppointmentRepository(super.dio)
    : super(
        path: 'appointments',
        fromJson: Appointment.fromJson,
        toJson: (appointment) => appointment.toJson(),
      );

  @override
  Future<PageResult<Appointment>> find(ListQuery query) =>
      fetchPage(listParams(query));
}
