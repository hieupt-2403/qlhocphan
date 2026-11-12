import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import '../models/giang_vien.dart';
import '../services/giang_vien_service.dart';

class GiangVienFormScreen extends StatefulWidget {
  final GiangVien? giangVien;
  const GiangVienFormScreen({super.key, this.giangVien});

  @override
  State<GiangVienFormScreen> createState() => _GiangVienFormScreenState();
}

class _GiangVienFormScreenState extends State<GiangVienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GiangVienService();
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sumCtrl;
  String _image = '';
  bool _saving = false;
  String? _idError;

  bool get _isEdit => widget.giangVien != null;

  @override
  void initState() {
    super.initState();
    final gv = widget.giangVien;
    _idCtrl = TextEditingController(text: gv?.idgv ?? '');
    _nameCtrl = TextEditingController(text: gv?.fullname ?? '');
    _sumCtrl = TextEditingController(text: gv?.sumClass.toString() ?? '');
    _image = gv?.image ?? '';
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _sumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      imageQuality: 60,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _image = base64Encode(bytes));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final gv = GiangVien(
      docId: widget.giangVien?.docId,
      idgv: _idCtrl.text.trim(),
      fullname: _nameCtrl.text.trim(),
      image: _image,
      sumClass: int.parse(_sumCtrl.text.trim()),
    );
    try {
      final exists =
          await _service.existsIdgv(gv.idgv, excludeDocId: gv.docId);
      if (exists) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _idError = 'IDGV "${gv.idgv}" already exists';
        });
        _formKey.currentState!.validate();
        return;
      }
      if (_isEdit) {
        await _service.update(gv);
      } else {
        await _service.add(gv);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? preview;
    if (_image.isNotEmpty) {
      preview = _image.startsWith('http')
          ? NetworkImage(_image)
          : MemoryImage(base64Decode(_image));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Edit lecturer' : 'Add lecturer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: preview,
                          child: preview == null
                              ? Icon(Icons.add_a_photo,
                                  size: 36, color: Colors.blue.shade300)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _image.isEmpty ? 'Tap to choose a photo' : 'Tap to change photo',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _idCtrl,
                        decoration: InputDecoration(
                          labelText: 'Lecturer ID',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (_) {
                          if (_idError != null) {
                            setState(() => _idError = null);
                          }
                        },
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter the lecturer ID';
                          }
                          return _idError;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter the full name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _sumCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Total classes',
                          prefixIcon: const Icon(Icons.class_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter the total classes';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null) return 'Must be a whole number';
                          if (n < 0) return 'Cannot be negative';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_isEdit ? 'Update' : 'Add',
                                  style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}