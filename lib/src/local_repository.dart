import 'package:hive/hive.dart';

import '../models/report_model.dart';


class LocalReportRepository {
  static const String _boxName = 'reports';

  Future<Box<Report>> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Report>(_boxName);
    }
    return Hive.box<Report>(_boxName);
  }

  Future<void> addReport(Report report) async {
    final box = await openBox();
    await box.put(report.id, report);
  }

  Future<List<Report>> getUserReports(String userId) async {
    final box = await openBox();
    return box.values.where((report) => report.userId == userId).toList();
  }

  Future<void> deleteReport(String reportId) async {
    final box = await openBox();
    await box.delete(reportId);
  }

  Future<void> updateReport(Report updatedReport) async {
    final box = await openBox();
    await box.put(updatedReport.id, updatedReport);
  }
}