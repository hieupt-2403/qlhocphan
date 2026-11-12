import 'package:material_ui/material_ui.dart';
import '../models/giang_vien.dart';
import '../services/giang_vien_service.dart';
import '../utils/delete_helper.dart';
import '../utils/image_helper.dart';
import 'giang_vien_form_screen.dart';

class GiangVienDetailScreen extends StatelessWidget {
  final String docId;
  GiangVienDetailScreen({super.key, required this.docId});

  final _service = GiangVienService();

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GiangVien?>(
      stream: _service.watch(docId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final gv = snapshot.data;
        if (gv == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lecturer details')),
            body: const Center(child: Text('This lecturer no longer exists')),
          );
        }
        final avatar = avatarProvider(gv.image);

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            title: const Text('Lecturer details'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: avatar,
                          child: avatar == null
                              ? Icon(Icons.person,
                                  size: 80, color: Colors.blue.shade300)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          gv.fullname,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        _infoRow(Icons.badge, 'Lecturer ID (IDGV)', gv.idgv),
                        _infoRow(
                            Icons.person, 'Full name (Fullname)', gv.fullname),
                        _infoRow(Icons.class_, 'Total classes (SumClass)',
                            '${gv.sumClass}'),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GiangVienFormScreen(giangVien: gv),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                onPressed: () async {
                                  final nav = Navigator.of(context);
                                  final deleted =
                                      await deleteWithUndo(context, gv);
                                  if (deleted) nav.pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}