import 'package:cloud_firestore/cloud_firestore.dart';

class GiangVien {
  final String? docId;
  final String idgv;
  final String fullname;
  final String image; // chuoi base64 hoac URL
  final int sumClass;

  GiangVien({
    this.docId,
    required this.idgv,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  
  Map<String, dynamic> toMap() => {
        'IDGV': idgv,
        'Fullname': fullname,
        'Image': image,
        'SumClass': sumClass,
      };

  factory GiangVien.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return GiangVien(
      docId: doc.id,
      idgv: d['IDGV'] ?? '',
      fullname: d['Fullname'] ?? '',
      image: d['Image'] ?? '',
      sumClass: (d['SumClass'] ?? 0) as int,
    );
  }
}