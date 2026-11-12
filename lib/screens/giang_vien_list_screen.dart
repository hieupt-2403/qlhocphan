import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/giang_vien.dart';
import '../services/giang_vien_service.dart';
import '../utils/delete_helper.dart';
import '../utils/export_json.dart';
import '../utils/image_helper.dart';
import '../utils/text_helper.dart';
import 'giang_vien_detail_screen.dart';
import 'giang_vien_form_screen.dart';

enum SortOption { nameAsc, nameDesc, idAsc, classDesc, classAsc }

const _sortLabels = {
  SortOption.nameAsc: 'Name A - Z',
  SortOption.nameDesc: 'Name Z - A',
  SortOption.idAsc: 'ID ascending',
  SortOption.classDesc: 'Classes: high to low',
  SortOption.classAsc: 'Classes: low to high',
};

class GiangVienListScreen extends StatefulWidget {
  const GiangVienListScreen({super.key});

  @override
  State<GiangVienListScreen> createState() => _GiangVienListScreenState();
}

class _GiangVienListScreenState extends State<GiangVienListScreen> {
  final _service = GiangVienService();
  final _searchCtrl = TextEditingController();
  String _keyword = ''; // lowercase, accents removed
  SortOption _sort = SortOption.nameAsc;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _compareName(GiangVien a, GiangVien b) =>
      removeDiacritics(a.fullname).compareTo(removeDiacritics(b.fullname));

  void _sortList(List<GiangVien> list) {
    switch (_sort) {
      case SortOption.nameAsc:
        list.sort(_compareName);
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => _compareName(b, a));
        break;
      case SortOption.idAsc:
        list.sort((a, b) =>
            removeDiacritics(a.idgv).compareTo(removeDiacritics(b.idgv)));
        break;
      case SortOption.classDesc:
        list.sort((a, b) => b.sumClass.compareTo(a.sumClass));
        break;
      case SortOption.classAsc:
        list.sort((a, b) => a.sumClass.compareTo(b.sumClass));
        break;
    }
  }

  Future<void> _export() async {
    try {
      final list = await _service.getAllOnce();
      downloadJson(list);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Exported ${list.length} lecturers to GiangVien.json'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Do you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) await FirebaseAuth.instance.signOut();
  }

  void _openForm([GiangVien? gv]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GiangVienFormScreen(giangVien: gv)),
    );
  }

  void _openDetail(GiangVien gv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GiangVienDetailScreen(docId: gv.docId!),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(GiangVien gv) {
    final avatar = avatarProvider(gv.image);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openDetail(gv),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: avatar,
                child: avatar == null
                    ? Icon(Icons.person, size: 40, color: Colors.blue.shade300)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                gv.fullname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('ID: ${gv.idgv}',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.class_, size: 16),
                label: Text('${gv.sumClass} classes'),
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _openForm(gv),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Delete',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => deleteWithUndo(context, gv),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.school),
            SizedBox(width: 10),
            Text('Lecturer Management'),
          ],
        ),
        actions: [
          if (MediaQuery.of(context).size.width > 600)
            Center(
              child: Text(email,
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
            ),
          IconButton(
            tooltip: 'Export JSON file',
            icon: const Icon(Icons.download),
            onPressed: _export,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add lecturer'),
      ),
      body: StreamBuilder<List<GiangVien>>(
        stream: _service.getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          final totalClass = all.fold<int>(0, (s, e) => s + e.sumClass);
          final list = all.where((gv) {
            if (_keyword.isEmpty) return true;
            return removeDiacritics(gv.fullname).contains(_keyword) ||
                removeDiacritics(gv.idgv).contains(_keyword);
          }).toList();
          _sortList(list);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        _statCard(Icons.people, 'Total lecturers',
                            '${all.length}', Colors.blue),
                        const SizedBox(width: 12),
                        _statCard(Icons.class_, 'Total classes', '$totalClass',
                            Colors.deepPurple),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search by name or ID...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _keyword.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _keyword = '');
                                      },
                                    ),
                            ),
                            onChanged: (v) => setState(
                                () => _keyword = removeDiacritics(v.trim())),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<SortOption>(
                          tooltip: 'Sort',
                          initialValue: _sort,
                          onSelected: (v) => setState(() => _sort = v),
                          itemBuilder: (_) => SortOption.values
                              .map((o) => PopupMenuItem(
                                    value: o,
                                    child: Text(_sortLabels[o]!),
                                  ))
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sort),
                                if (MediaQuery.of(context).size.width > 600) ...[
                                  const SizedBox(width: 6),
                                  Text(_sortLabels[_sort]!),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_search,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                Text(
                                  _keyword.isEmpty
                                      ? 'No lecturers yet'
                                      : 'No results found',
                                  style:
                                      TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisExtent: 270,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, i) => _card(list[i]),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}