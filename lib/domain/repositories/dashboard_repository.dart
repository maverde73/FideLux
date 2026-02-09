import '../entities/dashboard_data.dart';
import '../entities/report_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();

  Future<ReportData> getReportData(DateRange dateRange);

  Future<void> dismissAlert(String alertId);
}
