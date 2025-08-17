import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const kBlue = Color(0xFF007BEF);

class ManageAccessoriesScreen extends StatefulWidget {
  const ManageAccessoriesScreen({super.key});

  @override
  State<ManageAccessoriesScreen> createState() => _ManageAccessoriesScreenState();
}

class _ManageAccessoriesScreenState extends State<ManageAccessoriesScreen> {
  final _searchController = TextEditingController();

  // Keep in sync with your Add screen brands
  final _brands = const ['apple', 'samsung', 'xiaomi', 'realme', 'infinix', 'poco'];
  String _selectedBrand = 'apple';

  // EN-only UI categories + "All"
  final _categories = const [
    'All',
    'Case',
    'Charger',
    'Cable',
    'Screen Protector',
    'Earbuds',
    'Power Bank',
    'Other',
  ];
  String _selectedCategory = 'All';

  String _collectionFor(String brand) => 'accessories_${brand.toLowerCase()}';

  // ---- Category normalization (handles EN, AR, bilingual "EN / AR") ----
  String _normalizeCat(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return 'other';
    // Split bilingual "EN / AR" -> take EN part
    final enPart = s.contains('/') ? s.split('/').first.trim() : s;

    final lower = enPart.toLowerCase();
    // map common Arabic-only to EN
    const arToEn = {
      'غلاف': 'case',
      'شاحن': 'charger',
      'سلك': 'cable',
      'لاصقة شاشة': 'screen protector',
      'سماعات': 'earbuds',
      'بنك طاقة': 'power bank',
      'أخرى': 'other',
      'اخري': 'other',
    };
    if (arToEn.containsKey(lower)) return arToEn[lower]!;

    // normalize variants
    switch (lower) {
      case 'case': return 'case';
      case 'charger': return 'charger';
      case 'cable': return 'cable';
      case 'screen protector': return 'screen protector';
      case 'earbuds': return 'earbuds';
      case 'power bank': return 'power bank';
      case 'other': return 'other';
    }

    return lower; // fallback
  }

  Future<void> _confirmDelete(String coll, String docId, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Are you sure you want to delete “$title”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await FirebaseFirestore.instance.collection(coll).doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coll = _collectionFor(_selectedBrand);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header (no AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Manage Accessories',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBrand,
                          items: _brands
                              .map((b) => DropdownMenuItem(value: b, child: Text(b.toUpperCase())))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedBrand = v ?? 'apple'),
                          decoration: InputDecoration(
                            labelText: 'Brand',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v ?? 'All'),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            filled: true, fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by title…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection(coll)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No documents in this brand.'));
                  }

                  final q = _searchController.text.trim().toLowerCase();
                  final uiCat = _normalizeCat(_selectedCategory); // normalized UI selection

                  final filtered = docs.where((d) {
                    final data = d.data();
                    final title = (data['title'] ?? '').toString().toLowerCase();
                    final docCat = _normalizeCat((data['category'] ?? 'Other').toString());
                    final inSearch = q.isEmpty || title.contains(q);
                    final inCat = (uiCat == 'all') || (docCat == uiCat);
                    return inSearch && inCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No items found. Try “All” or another brand.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final d = filtered[i];
                      final data = d.data();
                      final id = d.id;
                      final title = (data['title'] ?? 'Accessory').toString();
                      final price = (data['price'] is num)
                          ? (data['price'] as num)
                          : num.tryParse('${data['price']}') ?? 0;
                      final img = (data['imagePath'] ?? '').toString();
                      final isDataUrl = img.startsWith('data:image');

                      final tile = ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isDataUrl
                              ? Image.memory(
                                  base64Decode(img.split(',').last),
                                  width: 56, height: 56, fit: BoxFit.cover,
                                )
                              : Image.network(
                                  img.isEmpty ? 'https://via.placeholder.com/64' : img,
                                  width: 56, height: 56, fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${price.toStringAsFixed(2)} LYD'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(coll, id, title),
                          tooltip: 'Delete',
                        ),
                        onTap: () => _confirmDelete(coll, id, title), // quick delete on tap (optional)
                      );

                      return Dismissible(
                        key: Key(id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _confirmDelete(coll, id, title);
                          return false; // we handle deletion ourselves
                        },
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: tile,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
