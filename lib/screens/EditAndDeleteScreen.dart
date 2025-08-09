import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAndDeleteScreen extends StatefulWidget {
  const EditAndDeleteScreen({super.key});

  @override
  State<EditAndDeleteScreen> createState() => _EditAndDeleteScreenState();
}

class _EditAndDeleteScreenState extends State<EditAndDeleteScreen> {
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
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Manage Cards"),
        backgroundColor:  Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedBrand,
              decoration: InputDecoration(
                labelText: "\n\nSelect Brand\n\n\n",
                filled: true,
                fillColor:  Color(0xFFC5E1A5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              dropdownColor: Colors.white,
              onChanged: (value) => setState(() => _selectedBrand = value!),
              items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b.toUpperCase()))).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(_selectedBrand).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No cards found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: const Color(0xFFE8F5E9),
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
                            const SizedBox(height: 10),
                            Text(
                              data['title'] ?? "",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF33691E)),
                            ),
                            Text(
                              data['description'] ?? "",
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const Divider(height: 20, color: Colors.black26),
                            ...parts.map((part) {
                              final priceMap = (data['prices'] ?? {})[part] ?? <String, dynamic>{};
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("🛠 $part", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 4),
                                  ...priceMap.entries.map((entry) {
                                    final controller = TextEditingController(text: entry.value.toString());
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(flex: 2, child: Text("${entry.key}:", style: TextStyle(color: Colors.teal))),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 3,
                                            child: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                isDense: true,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              ),
                                              onSubmitted: (newVal) => _updatePrice(docId, part, entry.key, newVal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
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
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
