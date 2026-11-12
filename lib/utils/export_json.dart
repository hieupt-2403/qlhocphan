import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../models/giang_vien.dart';

/// Tai file GiangVien.json ve may (chay tren web).
void downloadJson(List<GiangVien> list) {
  final data = list.map((e) => e.toMap()).toList(); // chi 4 truong
  final text = const JsonEncoder.withIndent('  ').convert(data);

  final blob = html.Blob([text], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'GiangVien.json')
    ..click();
  html.Url.revokeObjectUrl(url);
}