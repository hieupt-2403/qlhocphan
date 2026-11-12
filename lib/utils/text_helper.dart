const _groups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<String, String> _map = {
  for (final e in _groups.entries)
    for (final c in e.value.split('')) c: e.key,
};

String removeDiacritics(String input) {
  // bo cac dau roi (truong hop chu go dang to hop)
  final s = input.toLowerCase().replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  final sb = StringBuffer();
  for (final ch in s.split('')) {
    sb.write(_map[ch] ?? ch);
  }
  return sb.toString();
}


String tenGoi(String fullname) {
  final parts = fullname.trim().split(RegExp(r'\s+'));
  return removeDiacritics(parts.isEmpty ? '' : parts.last);
}