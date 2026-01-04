import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'common_pdf_viewer.dart';
import 'dart:html' as html;

class CPDFGenerator {
  final BuildContext context;
  final Font? font;
  final List<pw.Widget> header;
  final List<pw.Widget> footer;
  final List<pw.Widget> body;
  final void Function() fun;
  final PageOrientation? orientation;
  final bool isHeaderSpace;
  final bool isHeaderAllPage;
  final pw.EdgeInsetsGeometry margin;
  final bool isShowPageNo;
  final String reportTitle;
  CPDFGenerator(
      {required this.context,
      this.reportTitle = 'Report',
      required this.font,
      required this.header,
      required this.body,
      required this.footer,
      void Function()? fun,
      this.margin = const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      this.orientation = PageOrientation.portrait,
      this.isHeaderSpace = true,
      this.isHeaderAllPage = true,
      this.isShowPageNo = false})
      : fun = fun ?? (() {});
  String getDate() {
    return DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
  }

  pw.Widget _header() => pw.Column(children: [
        pw.Column(
            // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: header //[

            ),
        pw.SizedBox(height: isHeaderSpace ? 15 : 0),
        pw.Divider(height: isHeaderSpace ? 2 : 0),
        pw.SizedBox(height: isHeaderSpace ? 15 : 0),
      ]);
  pw.Widget _footer() => pw.Column(children: [
        pw.Divider(height: 2),
        pw.SizedBox(height: 4),
        pw.Column(children: footer),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
          Pwidget.textCaption('Printed Date', font, 8),
          pw.SizedBox(width: 8),
          Pwidget.textCaption(getDate(), font, 7.5)
        ]),
        pw.SizedBox(height: 4),
      ]);

  // ignore: non_constant_identifier_names
  void ShowReport() async {
    pw.Document d = await _generatePDfDocument(_header(), body, _footer(),
        font!, margin, orientation, isHeaderAllPage);

    // ignore: use_build_context_synchronously
    _openPdfFromDocument(d, context, reportTitle, fun);
  }
}

Future<void> _openPdfFromDocument(
  Document pdfFile,
  BuildContext context, [
  String title = 'Report',
  void Function()? onComplete,
]) async {
  // Convert PDF to bytes
  final bytes = await _convertPdfToBytes(pdfFile);
  final base64Data = base64Encode(bytes);

  // Show report immediately with valid context
  if (context.mounted) {
    await CReportVewer.showReport(context, base64Data);
  }

  // Call callback if provided
  onComplete?.call();
}

Future<pw.Document> _generatePDfDocument(
  pw.Widget header,
  List<pw.Widget> body,
  pw.Widget footer,
  pw.Font font, [
  pw.EdgeInsetsGeometry margin =
      const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
  PageOrientation? orientation = PageOrientation.portrait,
  bool isShowHeaderAllPage = true,
  bool isShowPageNo = false,
]) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      maxPages: 2000,
      orientation: orientation,
      pageFormat: orientation == PageOrientation.portrait
          ? PdfPageFormat.a4
          : PdfPageFormat(PdfPageFormat.a4.height,
              PdfPageFormat.a4.width), //PdfPageFormat.a4,
      margin: margin,
      header: (pw.Context context) {
        return isShowHeaderAllPage
            ? header
            : (context.pageNumber == 1 ? header : pw.SizedBox.shrink());
      },
      footer: (context) {
        return pw.Column(children: <pw.Widget>[
          footer,
          if (isShowPageNo) // ,
            Pwidget.textOne(
                font,
                '',
                'Page : ${context.pageLabel} of ${context.pagesCount}',
                7.5,
                Pwidget.mainAxisAlignmentEnd)
          //pw.Text(context.pageLabel),
        ]);
      },
      build: (context) => body,
    ),
  );

  return pdf;
}

Future<Uint8List> _convertPdfToBytes(Document pdf) async {
  // Save the PDF document as bytes
  return await pdf.save();
   
}

__splitText(pw.Font? font, String text, [double fontSize = 9]) => pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: fontSize))));

enum _CPdfPageOrientation {
  portrait,
  landscape,
}

extension PdfPageOrientation on _CPdfPageOrientation {
  PageOrientation get pageOrientation {
    switch (this) {
      case _CPdfPageOrientation.portrait:
        return PageOrientation.portrait;
      case _CPdfPageOrientation.landscape:
        return PageOrientation.landscape;
    }
  }
}

class Pwidget {
  Future<pw.Font> pwFontloader(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  static pw.Widget center(pw.Widget child) => pw.Center(child: child);
  static pw.Widget tableColumnHeader(String name, pw.Font? font,
          [pw.Alignment aligment = pw.Alignment.centerLeft,
          double fontSize = 12,
          pw.FontWeight fontWeight = pw.FontWeight.bold]) =>
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: pw.Align(
              alignment: aligment,
              child: pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      font: font))));

  static pw.SizedBox sizedBox(
          [double height = 0, double width = 0, pw.Widget? child]) =>
      pw.SizedBox(height: height, width: width, child: child ?? pw.SizedBox());

  static pw.BoxDecoration boxDecorationFooter =
      const pw.BoxDecoration(color: PdfColors.grey100);

  static pw.TableRow tableRow(List<pw.Widget> children,
          [pw.BoxDecoration decoration = const pw.BoxDecoration(
            color: PdfColors.white,
          )]) =>
      pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: children,
          decoration: decoration);

  static pw.Alignment aligmentRight = pw.Alignment.centerRight;
  static pw.Alignment aligmentLeft = pw.Alignment.centerLeft;
  static pw.Alignment aligmentCenter = pw.Alignment.center;
  static pw.MainAxisAlignment mainAxisAlignmentStart =
      pw.MainAxisAlignment.start;
  static pw.MainAxisAlignment mainAxisAlignmentEnd = pw.MainAxisAlignment.end;
  static pw.MainAxisAlignment mainAxisAlignmentCenter =
      pw.MainAxisAlignment.center;

  static pw.CrossAxisAlignment crossAxisAligmentCenter =
      pw.CrossAxisAlignment.center;

  static pw.MainAxisAlignment pwMainAxisAlignmentSpaceBetween =
      pw.MainAxisAlignment.spaceBetween;
  static pw.Widget tableCell2(
    String name,
    pw.Font? font, [
    pw.Alignment aligment = pw.Alignment.centerLeft,
    double fontSize = 9,
    pw.FontWeight fontWeight = pw.FontWeight.bold,
    PdfColor pdfColor = PdfColors.black,
    double vericalPadding = 8,
  ]) =>
      pw.Padding(
          padding:
              pw.EdgeInsets.symmetric(horizontal: 4, vertical: vericalPadding),
          child: pw.Align(
              alignment: aligment,
              child: pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: fontSize, font: font, color: pdfColor))));

  static pw.Widget tableCell(String name, pw.Font? font,
          [pw.Alignment aligment = pw.Alignment.centerLeft,
          double fontSize = 9,
          pw.FontWeight fontWeight = pw.FontWeight.bold,
          PdfColor pdfColor = PdfColors.black,
          double verticalPadding = 2]) =>
      pw.Padding(
          padding:
              pw.EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
          child: pw.Align(
              alignment: aligment,
              child: pw.Text(name,
                  style: pw.TextStyle(
                      fontSize: fontSize, font: font, color: pdfColor))));
  static pw.Widget tableCellBlackLine() => pw.Row(children: [
        pw.Expanded(child: pw.Container(color: PdfColors.black, height: 0.5))
      ]);

  static pw.Widget textCaption(
    String name,
    pw.Font? font, [
    double fontSize = 9,
    pw.FontWeight fontWeight = pw.FontWeight.bold,
    pw.Alignment aligment = pw.Alignment.centerLeft,
    PdfColor color = PdfColors.black,
  ]) =>
      pw.Align(
          alignment: aligment,
          child: pw.Text(name,
              style: pw.TextStyle(
                  fontSize: fontSize,
                  font: font,
                  color: color,
                  fontWeight: fontWeight)));

  static Map<int, pw.TableColumnWidth> _pwTableColumnWidthGenerator(
      List<int> columnWidth) {
    final Map<int, pw.TableColumnWidth> columnWidthMap = {};

    for (int i = 0; i < columnWidth.length; i++) {
      columnWidthMap[i] = pw.FlexColumnWidth(columnWidth[i].toDouble());
    }
    return columnWidthMap;
  }

  static pw.Widget generateTable(List<int> columnWidth,
          List<pw.Widget> headerRow, List<pw.TableRow> bodyChildren,
          [bool is_border = true]) =>
      pw.Table(
        border: is_border
            ? pw.TableBorder.all(color: PdfColors.black)
            : const pw.TableBorder(),
        columnWidths: _pwTableColumnWidthGenerator(columnWidth),
        children: [
          headerRow.isEmpty
              ? const pw.TableRow(children: [])
              : pw.TableRow(
                  decoration: is_border
                      ? const pw.BoxDecoration(color: PdfColors.grey300)
                      : const pw.BoxDecoration(),
                  children: headerRow),
          ...bodyChildren
        ],
      );

  static pw.Widget text2Col(pw.Font? font, String caption1, String text1,
          String caption2, String text2,
          [double fontSize = 9]) =>
      pw.Table(columnWidths: _pwTableColumnWidthGenerator([70, 50]), children: [
        pw.TableRow(children: [
          pw.Row(children: [
            textCaption(caption1, font, fontSize),
            textCaption(text1, font, fontSize, pw.FontWeight.normal),
          ]),
          pw.Row(children: [
            pw.Spacer(),
            textCaption(caption2, font, fontSize),
            textCaption(text2, font, fontSize, pw.FontWeight.normal),
          ]),
        ])
      ]);
  static pw.Widget height([double height = 8]) => pw.SizedBox(height: height);
  static pw.Widget textOne(pw.Font? font, String caption, String text,
          [double fontSize = 9,
          pw.MainAxisAlignment aligment = pw.MainAxisAlignment.center]) =>
      pw.Row(mainAxisAlignment: aligment, children: [
        pw.Text(caption,
            style: pw.TextStyle(
                fontSize: fontSize,
                font: font,
                //color: color,
                fontWeight: pw.FontWeight.bold)),
        pw.Text(text,
            style: pw.TextStyle(
                fontSize: fontSize,
                font: font,
                //color: color,
                fontWeight: pw.FontWeight.bold))
      ]);

  static pw.Widget memoryImage(pw.MemoryImage image,
          [double width = 150, double height = 80]) =>
      pw.Image(image, width: width, height: height);

static pw.Image image(pw.MemoryImage image,double width, double height)=>pw.Image(image, width: width, height: height);


  Future<pw.Widget> logoImage(String impBundlePath,
      [double width = 150, double height = 80]) async {
    var image = await pwLoadImageWidget(impBundlePath);
    return pw.Image(image, width: width, height: height);
  }

  Future<pw.MemoryImage> pwLoadImageWidget(String logoImage) async {
    // Load the image from assets

    final imageData = await rootBundle.load(logoImage);

    // Convert the image data to a MemoryImage
    final image = pw.MemoryImage(
      imageData.buffer.asUint8List(),
    );
    return image;
  }

  static pw.Widget tableCell2Column(String name1, String name2, pw.Font? font,
          [pw.Alignment aligment = pw.Alignment.centerLeft,
          double fontSize = 9,
          pw.FontWeight fontWeight = pw.FontWeight.bold]) =>
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: pw.Column(
              crossAxisAlignment: aligment == pw.Alignment.centerLeft
                  ? pw.CrossAxisAlignment.start
                  : aligment == pw.Alignment.center
                      ? pw.CrossAxisAlignment.center
                      : pw.CrossAxisAlignment.end,
              children: [
                pw.Text(name1,
                    style: pw.TextStyle(fontSize: fontSize, font: font)),
                pw.Text(name2,
                    style: pw.TextStyle(fontSize: fontSize, font: font))
              ]));

  static pw.Widget tableCellUnderLine() => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(children: [
        pw.Expanded(
            child: pw.Container(height: 0.2, color: const PdfColor.fromInt(0)))
      ]));
  pw.FontWeight pwFontWigthBold = pw.FontWeight.bold;

  static pw.Widget column(List<pw.Widget> list,
          {pw.CrossAxisAlignment crossAxisAlign =
              pw.CrossAxisAlignment.start}) =>
      pw.Column(crossAxisAlignment: crossAxisAlign, children: list);

  static pw.Widget row(List<pw.Widget> list,
          [pw.MainAxisAlignment mainAxisAlignment = pw.MainAxisAlignment.start,
          pw.CrossAxisAlignment crossAxisAlignment =
              pw.CrossAxisAlignment.start]) =>
      pw.Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: list);

  static pw.Widget rowSplitCell(pw.Font? font, String w1, String w2,
          [double fontSize = 9]) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
            child: pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                        right:
                            pw.BorderSide(color: PdfColors.black, width: 0.5))),
                child: __splitText(font, w1, fontSize))),
        pw.Expanded(
            child: pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                )),
                child: __splitText(font, w2, fontSize)))
      ]);
}
