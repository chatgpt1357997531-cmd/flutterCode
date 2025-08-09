import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPriceTab extends StatefulWidget {
  const AddPriceTab({super.key});

  @override
  State<AddPriceTab> createState() => _AddPriceTabState();
}

class _AddPriceTabState extends State<AddPriceTab> {
  final List<String> _brands = [
    'apple',
    'samsung',
    'xiaomi',
    'poco',
    'realme',
    'infinix',
  ];
  final Map<String, List<String>> _brandParts = {
    'apple': ['screen', 'battery', 'face_id', 'home_button'],
    'samsung': ['screen', 'battery', 'fingerprint_sensor', 'spen'],
    'xiaomi': ['screen', 'battery', 'usb_port'],
    'poco': ['screen', 'battery'],
    'realme': ['screen', 'battery', 'front_camera'],
    'infinix': ['screen', 'battery', 'ear_speaker'],
  };

  final Map<String, Map<String, List<String>>> _brandPartVariants = {
    'apple': {
      'screen': ['LCD', 'OLED'],
      'battery': ['Original', 'Copy'],
      'face_id': ['Module'],
      'home_button': ['Touch ID', 'Regular'],
    },
    'samsung': {
      'screen': ['Super AMOLED', 'TFT'],
      'battery': ['Standard'],
      'fingerprint_sensor': ['Under Display', 'Side Mounted'],
      'spen': ['Standard'],
    },
    'xiaomi': {
      'screen': ['LCD'],
      'battery': ['Standard'],
      'usb_port': ['Type-C'],
    },
    'poco': {
      'screen': ['LCD'],
      'battery': ['Standard'],
    },
    'realme': {
      'screen': ['LCD'],
      'battery': ['Standard'],
      'front_camera': ['8MP', '16MP'],
    },
    'infinix': {
      'screen': ['LCD'],
      'battery': ['Standard'],
      'ear_speaker': ['Standard'],
    },
  };

  String? _selectedBrand;
  String? _selectedModelId;
  String? _selectedModelTitle;
  String? _selectedPart;
  String? _selectedVariant;
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, String>> _models = [];

  Future<void> _loadModels(String brand) async {
    final snapshot = await FirebaseFirestore.instance.collection(brand).get();
    setState(() {
      _models = snapshot.docs.map((doc) {
        final title = doc.data()['title']?.toString() ?? doc.id;
        return {'id': doc.id, 'title': title};
      }).toList();
      _selectedModelId = null;
      _selectedModelTitle = null;
    });
  }

  Future<void> _savePrice() async {
    if (_selectedBrand == null ||
        _selectedModelId == null ||
        _selectedPart == null ||
        _selectedVariant == null ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final price = _priceController.text.trim();
    final docRef = FirebaseFirestore.instance
        .collection(_selectedBrand!)
        .doc(_selectedModelId!);
    final doc = await docRef.get();
    Map<String, dynamic> prices = {};

    if (doc.exists && doc.data()?['prices'] != null) {
      prices = Map<String, dynamic>.from(doc.data()!['prices']);
    }

    prices[_selectedPart!] ??= {};
    prices[_selectedPart!][_selectedVariant!] = price;
    await docRef.update({'prices': prices});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Price saved successfully")));

    setState(() {
      _selectedBrand = null;
      _selectedModelId = null;
      _selectedModelTitle = null;
      _selectedPart = null;
      _selectedVariant = null;
    });
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentParts = _selectedBrand != null
        ? _brandParts[_selectedBrand!] ?? []
        : [];
    final currentVariants = (_selectedBrand != null && _selectedPart != null)
        ? (_brandPartVariants[_selectedBrand!]?[_selectedPart!] ?? [])
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedBrand,
            hint: const Text("Select Brand"),
            decoration: _inputDecoration("Brand"),
            items: _brands
                .map(
                  (b) =>
                      DropdownMenuItem(value: b, child: Text(b.toUpperCase())),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedBrand = val;
                _selectedModelId = null;
                _selectedModelTitle = null;
                _selectedPart = null;
                _selectedVariant = null;
                _models = [];
              });
              _loadModels(val!);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedModelTitle,
            hint: const Text("Select Model"),
            decoration: _inputDecoration("Model"),
            items: _models
                .map(
                  (m) => DropdownMenuItem(
                    value: m['title'],
                    child: Text(m['title']!),
                  ),
                )
                .toList(),
            onChanged: (val) {
              final model = _models.firstWhere((e) => e['title'] == val);
              setState(() {
                _selectedModelTitle = model['title'];
                _selectedModelId = model['id'];
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedPart,
            hint: const Text("Select Part"),
            decoration: _inputDecoration("Part"),
            isExpanded: true,
            items: currentParts
                .map<DropdownMenuItem<String>>(
                  (p) => DropdownMenuItem<String>(value: p, child: Text(p)),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedPart = val;
                _selectedVariant = null;
              });
            },
          ),

          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedVariant,
            hint: const Text("Select Variant"),
            decoration: _inputDecoration("Variant"),

            isExpanded: true,
            items: currentVariants
                .map<DropdownMenuItem<String>>(
                  (v) => DropdownMenuItem<String>(value: v, child: Text(v)),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedVariant = val),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration("Enter Price"),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Price"),
              onPressed: _savePrice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF558B2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFDCEDC8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
