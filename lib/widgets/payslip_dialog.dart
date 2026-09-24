import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/driver.dart';
import '../models/payroll.dart';
import '../models/bus.dart';

class PayslipDialog extends StatelessWidget {
  final Driver driver;
  final Payroll payroll;
  final Bus? bus;

  const PayslipDialog({
    super.key,
    required this.driver,
    required this.payroll,
    this.bus,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###', 'ar');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'مؤسسة سويقات أبو طالب',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.receipt_long_rounded, color: Color(0xFF1E3A8A)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Official Document Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'تقرير ومسير الأجور الشهري لسائقي الأسطول',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'دورة أجور شهر: ${payroll.monthName} ${payroll.year} • مؤسسة سويقات أبو طالب',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Driver Information Grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('اسم السائق', driver.name, isBold: true),
                        _buildInfoColumn('رقم رخصة السياقة', driver.licenseNumber),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFCBD5E1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('الحافلة المخصصة', bus?.busNumber ?? 'حافلة الأسطول'),
                        _buildInfoColumn('طريقة ونظام العمل', driver.shiftPattern.title, isHighlight: true),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFCBD5E1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('رقم الهاتف', driver.phone),
                        _buildInfoColumn('الرحلات المنجزة', '${payroll.completedTripsCount} رحلة'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Financial Items
              const Text(
                'تفاصيل المستحقات والأجر بالدينار الجزائري (دج):',
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildFinancialRow('الراتب الأساسي الشهري', '${currencyFormatter.format(payroll.baseSalary)} دج'),
              _buildFinancialRow(
                'علاوة الرحلات المنجزة (${payroll.completedTripsCount} رحلة × ${driver.tripBonusRate.toInt()} دج)',
                '+${currencyFormatter.format(payroll.tripBonuses)} دج',
                isPositive: true,
              ),
              if (payroll.overtimePay > 0)
                _buildFinancialRow(
                  'أجر الساعات الإضافية (${payroll.overtimeHours.toStringAsFixed(1)} س)',
                  '+${currencyFormatter.format(payroll.overtimePay)} دج',
                  isPositive: true,
                ),
              if (payroll.incentives > 0)
                _buildFinancialRow(
                  'مكافآت وحوافز تشجيعية',
                  '+${currencyFormatter.format(payroll.incentives)} دج',
                  isPositive: true,
                ),
              if (payroll.deductions > 0)
                _buildFinancialRow(
                  'الخصومات (اقتطاعات الغياب)',
                  '-${currencyFormatter.format(payroll.deductions)} دج',
                  isNegative: true,
                ),

              const Divider(height: 24, thickness: 1.5),

              // Net Total Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormatter.format(payroll.netSalary)} دج',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const Text(
                      'الصافي الإجمالي المستحق للدفع:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Signatures Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('توقيع واستلام السائق', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 26),
                        Text('........................', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('إدارة المؤسسة والختم', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 26),
                        Text('مؤسسة سويقات أبو طالب', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons: Print PDF & Dismiss
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printReport(context),
                      icon: const Icon(Icons.print_rounded, size: 20),
                      label: const Text(
                        'طباعة تقرير الأجر (PDF / طابعة)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, {bool isBold = false, bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
            fontWeight: isBold || isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isPositive = false, bool isNegative = false}) {
    Color valColor = const Color(0xFF0F172A);
    if (isPositive) valColor = const Color(0xFF059669);
    if (isNegative) valColor = const Color(0xFFDC2626);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valColor,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReport(BuildContext context) async {
    final currencyFormatter = NumberFormat('#,###', 'ar');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        final font = await PdfGoogleFonts.cairoRegular();
        final fontBold = await PdfGoogleFonts.cairoBold();

        doc.addPage(
          pw.Page(
            pageFormat: format,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: font, bold: fontBold),
            build: (pw.Context ctx) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('دورة الأجور: ${payroll.monthName} ${payroll.year}', style: const pw.TextStyle(fontSize: 11)),
                            pw.Text('تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('مؤسسة سويقات أبو طالب', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            pw.Text('إدارة الرحلات والأسطول وحساب الأجور', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          ],
                        ),
                      ],
                    ),
                    pw.Divider(thickness: 1.5, color: PdfColors.blue800),
                    pw.SizedBox(height: 12),

                    pw.Center(
                      child: pw.Text(
                        'كشف وتقرير الأجر الشهري للسائق',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.SizedBox(height: 14),

                    // Driver details
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey400),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('اسم السائق: ${driver.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text('رقم الرخصة: ${driver.licenseNumber}', style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('الحافلة المخصصة: ${bus?.busNumber ?? "حافلة الأسطول"}', style: const pw.TextStyle(fontSize: 11)),
                              pw.Text('طريقة العمل: ${driver.shiftPattern.title}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue800)),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('الهاتف: ${driver.phone}', style: const pw.TextStyle(fontSize: 11)),
                              pw.Text('عدد الرحلات المنجزة: ${payroll.completedTripsCount} رحلة', style: const pw.TextStyle(fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 18),

                    // Financial table
                    pw.Text('تفاصيل المستحقات بالدينار الجزائري (دج):', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),

                    _pwRow('الراتب الأساسي الشهري', '${currencyFormatter.format(payroll.baseSalary)} دج'),
                    _pwRow('علاوة الرحلات المنجزة (${payroll.completedTripsCount} رحلة)', '+${currencyFormatter.format(payroll.tripBonuses)} دج', isPos: true),
                    if (payroll.overtimePay > 0)
                      _pwRow('بدل ساعات إضافية (${payroll.overtimeHours.toStringAsFixed(1)} س)', '+${currencyFormatter.format(payroll.overtimePay)} دج', isPos: true),
                    if (payroll.incentives > 0)
                      _pwRow('مكافآت وحوافز تشجيعية', '+${currencyFormatter.format(payroll.incentives)} دج', isPos: true),
                    if (payroll.deductions > 0)
                      _pwRow('الخصومات (اقتطاعات الغياب)', '-${currencyFormatter.format(payroll.deductions)} دج', isNeg: true),

                    pw.Divider(thickness: 1.5),

                    // Net Box
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        border: pw.Border.all(color: PdfColors.blue700, width: 1.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${currencyFormatter.format(payroll.netSalary)} دج',
                            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.Text('الصافي النهائي المستحق للدفع:', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    // Signatures
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Column(
                          children: [
                            pw.Text('توقيع واستلام السائق', style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 35),
                            pw.Text('................................', style: const pw.TextStyle(color: PdfColors.grey500)),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('إدارة المؤسسة والختم الرسمي', style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 35),
                            pw.Text('مؤسسة سويقات أبو طالب', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );

        return doc.save();
      },
    );
  }

  pw.Widget _pwRow(String label, String value, {bool isPos = false, bool isNeg = false}) {
    PdfColor col = PdfColors.black;
    if (isPos) col = PdfColors.green800;
    if (isNeg) col = PdfColors.red800;

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: col, fontSize: 11)),
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
