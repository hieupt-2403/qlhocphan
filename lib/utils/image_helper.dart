import 'dart:convert';
import 'package:material_ui/material_ui.dart';

ImageProvider? avatarProvider(String image) {
  if (image.isEmpty) return null;
  if (image.startsWith('http')) return NetworkImage(image);
  try {
    return MemoryImage(base64Decode(image));
  } catch (_) {
    return null;
  }
}