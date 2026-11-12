import 'package:material_ui/material_ui.dart';
import '../models/giang_vien.dart';
import '../services/giang_vien_service.dart';

/// Returns true if the lecturer was deleted.
Future<bool> deleteWithUndo(BuildContext context, GiangVien gv) async {
  final service = GiangVienService();
  final messenger = ScaffoldMessenger.of(context);

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded,
          color: Colors.orange, size: 40),
      title: const Text('Confirm deletion'),
      content: Text('Are you sure you want to delete "${gv.fullname}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true) return false;

  await service.delete(gv.docId!);

  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text('Deleted "${gv.fullname}"'),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => service.restore(gv),
      ),
    ),
  );
  return true;
}