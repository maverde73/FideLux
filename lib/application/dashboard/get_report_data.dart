import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/report_data.dart';

class GetReportData {
  final DashboardRepository _repository;

  GetReportData(this._repository);

  Future<ReportData> call(DateRange dateRange) {
    return _repository.getReportData(dateRange);
  }
}
