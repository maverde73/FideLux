import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_data.dart';

class GetDashboardData {
  final DashboardRepository _repository;

  GetDashboardData(this._repository);

  Future<DashboardData> call() {
    return _repository.getDashboardData();
  }
}
