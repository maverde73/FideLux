import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report_data.dart';
import '../../application/dashboard/get_report_data.dart';
import 'dashboard_providers.dart';

final selectedPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.month);

final getReportDataUseCaseProvider = Provider<GetReportData>((ref) {
  return GetReportData(ref.watch(dashboardRepositoryProvider));
});

final reportDataProvider = FutureProvider<ReportData>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final useCase = ref.read(getReportDataUseCaseProvider);
  return useCase(DateRange.fromPeriod(period));
});
