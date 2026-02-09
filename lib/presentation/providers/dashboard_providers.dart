import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard/dashboard_service.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../application/dashboard/get_dashboard_data.dart';
import 'accounting_providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final txDao = ref.watch(transactionsDaoProvider);
  final accDao = ref.watch(accountsDaoProvider);
  return DashboardService(txDao, accDao);
});

final getDashboardDataUseCaseProvider = Provider<GetDashboardData>((ref) {
  return GetDashboardData(ref.watch(dashboardRepositoryProvider));
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final useCase = ref.read(getDashboardDataUseCaseProvider);
  return useCase();
});

final criticalAlertCountProvider = Provider<int>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);
  return dashboardAsync.whenOrNull(
    data: (data) => data.activeAlerts
      .where((a) => !a.dismissed &&
        (a.level == AlertLevel.critical || a.level == AlertLevel.sos))
      .length,
  ) ?? 0;
});
