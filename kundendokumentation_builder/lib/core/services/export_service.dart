class ExportService {
  static Future<void> exportAsPDF(Map<String, dynamic> reportData) async {
    // TODO: PDF generieren (z. B. POST an FastAPI-Backend)
    print('Exportiere PDF mit: $reportData');
  }

  static Future<void> exportAndSendEmail(
    Map<String, dynamic> reportData,
  ) async {
    // TODO: PDF generieren + E-Mail versenden
    print('Exportiere PDF & sende per Mail: $reportData');
  }
}
