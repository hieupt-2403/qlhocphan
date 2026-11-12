import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/giang_vien.dart';

class GiangVienService {
  final _col = FirebaseFirestore.instance.collection('GiangVien');

  Stream<List<GiangVien>> getAll() {
    return _col.snapshots().map(
          (snap) => snap.docs.map((d) => GiangVien.fromDoc(d)).toList(),
        );
  }

  Future<List<GiangVien>> getAllOnce() async {
    final snap = await _col.get();
    return snap.docs.map((d) => GiangVien.fromDoc(d)).toList();
  }

  
  Stream<GiangVien?> watch(String docId) {
    return _col
        .doc(docId)
        .snapshots()
        .map((d) => d.exists ? GiangVien.fromDoc(d) : null);
  }

  
  Future<bool> existsIdgv(String idgv, {String? excludeDocId}) async {
    final snap = await _col.where('IDGV', isEqualTo: idgv).get();
    return snap.docs.any((d) => d.id != excludeDocId);
  }

  Future<void> add(GiangVien gv) => _col.add(gv.toMap());

  Future<void> update(GiangVien gv) => _col.doc(gv.docId).update(gv.toMap());

  Future<void> delete(String docId) => _col.doc(docId).delete();

  // Hoan tac xoa: tao lai dung docId cu
  Future<void> restore(GiangVien gv) => _col.doc(gv.docId).set(gv.toMap());
}