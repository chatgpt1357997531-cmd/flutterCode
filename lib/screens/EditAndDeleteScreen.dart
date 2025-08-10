import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAndDeleteScreen extends StatefulWidget {
  const EditAndDeleteScreen({super.key});

  @override
  State<EditAndDeleteScreen> createState() => _EditAndDeleteScreenState();
}

class _EditAndDeleteScreenState extends State<EditAndDeleteScreen> {
  // Theme colors (match AdminHomeScreen)
  static const Color kBlue = Color(0xFF1565C0);
  static const Color kBlueLight = Color(0xFFE3F2FD);
  static const Color kSurface = Color(0xFFFDFEFF);

  final List<String> _brands = ['apple', 'samsung', 'xiaomi', 'poco', 'realme', 'infinix'];
  String _selectedBrand = 'apple';
  final parts = ['screen', 'battery', 'front_camera', 'ear_speaker'];

  Future<void> _deleteCard(String docId) async {
    await FirebaseFirestore.instance.collection(_selectedBrand).doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Card deleted")),
    );
  }

  Future<void> _updatePrice(String docId, String part, String type, String newPrice) async {
    final docRef = FirebaseFirestore.instance.collection(_selectedBrand).doc(docId);
    final doc = await docRef.get();
    Map<String, dynamic> prices = {};

    if (doc.exists && doc.data()?['prices'] != null) {
      prices = Map<String, dynamic>.from(doc['prices']);
    }

    prices[part] ??= {};
    prices[part][type] = newPrice;

    await docRef.update({'prices': prices});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Price updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the parent AppBar (from AdminHomeScreen) show; keep this page clean
      backgroundColor: kSurface,
      body: Column(
        children: [
          // Brand selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              value: _selectedBrand,
              decoration: InputDecoration(
                labelText: "Select Brand",
                labelStyle: const TextStyle(color: kBlue, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlueLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              dropdownColor: Colors.white,
              iconEnabledColor: kBlue,
              onChanged: (value) => setState(() => _selectedBrand = value!),
              items: _brands
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.toUpperCase(), style: const TextStyle(color: kBlue, fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),

          // List of cards
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(_selectedBrand).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No cards found", style: TextStyle(color: Colors.black54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card
                    (
                      elevation: 6,
                      shadowColor: kBlue.withOpacity(0.15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['imagePath'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  Uri.parse(data['imagePath']).data!.contentAsBytes(),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              data['title'] ?? "",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kBlue),
                            ),
                            if ((data['description'] ?? '').toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  data['description'],
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Divider(height: 20, color: kBlueLight.withOpacity(0.9), thickness: 1),

                            // Prices editor for selected parts
                            ...parts.map((part) {
                              final priceMap = (data['prices'] ?? {})[part] ?? <String, dynamic>{};
                              if (priceMap.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text("🛠 $part — no variants yet",
                                      style: const TextStyle(color: Colors.black54)),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("🛠 $part",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: kBlue, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  ...priceMap.entries.map((entry) {
                                    final controller = TextEditingController(text: entry.value.toString());
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text("${entry.key}:",
                                                style: const TextStyle(
                                                    color: kBlue, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 3,
                                            child: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: kSurface,
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10)),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: kBlueLight),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide:
                                                      const BorderSide(color: kBlue, width: 1.5),
                                                ),
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 10),
                                              ),
                                              onSubmitted: (newVal) =>
                                                  _updatePrice(docId, part, entry.key, newVal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                ],
                              );
                            }),

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _deleteCard(docId),
                                icon: const Icon(Icons.delete),
                                label: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 2,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
