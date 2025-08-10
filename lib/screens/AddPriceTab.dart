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
    'apple': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'mother_borad',
      'back_camera',
      'home_button',
      'back_glass',
      'housing_case',
      'camara_lens',
      'antena_signal',
      'simCard_reader',
      'volumMuteBtns',
      'power_btn',
      'flex_charge',
      'haptic',
      'face_id',
      'sim_card',
    ],
    'samsung': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'motherboard',
      'back_camera',
      'camera_lens',
      'flex_charge',
      'usb_c',
      'power_button',
      'volume_buttons',
      'back_glass',
      'housing_case',
      'antenna_signal',
      'sim_card_reader',
      'sim_card',
      'vibrator',
    ],
    'xiaomi': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'motherboard',
      'back_camera',
      'camera_lens',
      'flex_charge',
      'usb_c',
      'power_button',
      'volume_buttons',
      'back_glass',
      'housing_case',
      'antenna_signal',
      'sim_card_reader',
      'sim_card',
      'vibrator',
    ],
    'poco': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'motherboard',
      'back_camera',
      'camera_lens',
      'flex_charge',
      'usb_c',
      'power_button',
      'volume_buttons',
      'back_glass',
      'housing_case',
      'antenna_signal',
      'sim_card_reader',
      'sim_card',
      'vibrator',
    ],
    'realme': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'motherboard',
      'back_camera',
      'camera_lens',
      'flex_charge',
      'usb_c',
      'power_button',
      'volume_buttons',
      'back_glass',
      'housing_case',
      'antenna_signal',
      'sim_card_reader',
      'sim_card',
      'vibrator',
    ],
    'infinix': [
      'screen',
      'battery',
      'front_camera',
      'ear_speaker',
      'loud_speaker',
      'motherboard',
      'back_camera',
      'camera_lens',
      'flex_charge',
      'usb_c',
      'power_button',
      'volume_buttons',
      'back_glass',
      'housing_case',
      'antenna_signal',
      'sim_card_reader',
      'sim_card',
      'vibrator',
    ],
  };

  final Map<String, Map<String, List<String>>> _brandPartVariants = {
    'apple': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'mother_borad': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camara_lens': ['ORGNAL(أصلية)'],
      'antena_signal': ['ORGNAL(أصلية)'],
      'simCard_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volumMuteBtns': ['ORGNAL(أصلية)'],
      'power_btn': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
    },
    'samsung': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'motherboard': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camera_lens': ['ORGNAL(أصلية)'],
      'antenna_signal': ['ORGNAL(أصلية)'],
      'sim_card_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volume_mute_buttons': ['ORGNAL(أصلية)'],
      'power_button': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
    },
    'xiaomi': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'motherboard': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camera_lens': ['ORGNAL(أصلية)'],
      'antenna_signal': ['ORGNAL(أصلية)'],
      'sim_card_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volume_mute_buttons': ['ORGNAL(أصلية)'],
      'power_button': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
    },
    'poco': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'motherboard': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camera_lens': ['ORGNAL(أصلية)'],
      'antenna_signal': ['ORGNAL(أصلية)'],
      'sim_card_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volume_mute_buttons': ['ORGNAL(أصلية)'],
      'power_button': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
    },
    'realme': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'motherboard': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camera_lens': ['ORGNAL(أصلية)'],
      'antenna_signal': ['ORGNAL(أصلية)'],
      'sim_card_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volume_mute_buttons': ['ORGNAL(أصلية)'],
      'power_button': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
    },
    'infinix': {
      'screen': ['ORGNAL(أصلية)', 'OLED(درجة أولى)', 'LCD(درجة تانية)'],
      'battery': ['ORGNAL(أصلية)', 'iRANGE(درجة اولى)', 'HOCO(درجة تانية)'],
      'front_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'ear_speaker': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'motherboard': ['64GB', '128GB', '256GB', '512GB', '1TB'],
      'back_camera': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'home_button': ['ORGNAL(أصلية)'],
      'flex_charge': ['Flex charge(قاعدة شحن)'],
      'loud_speaker': ['ORGNAL(أصلية)'],
      'back_glass': ['ORGNAL(أصلية)'],
      'housing_case': ['ORGNAL(أصلية)', 'COPY(درجة اولى)'],
      'camera_lens': ['ORGNAL(أصلية)'],
      'antenna_signal': ['ORGNAL(أصلية)'],
      'sim_card_reader': ['One Card(شفرة وحدة)', 'Double Card(شفرتين)'],
      'volume_mute_buttons': ['ORGNAL(أصلية)'],
      'power_button': ['ORGNAL(أصلية)'],
      'sim_card': ['ORGNAL(أصلية)'],
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
        _selectedModelTitle == null ||
        _selectedPart == null ||
        _selectedVariant == null ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    // ---- Make local, non-nullable copies (fixes the promotion error) ----
    final String brand = _selectedBrand!.toLowerCase();
    final String cardId = _selectedModelId!;
    final String cardTitle = _selectedModelTitle!;
    final String part = _selectedPart!;
    final String variant = _selectedVariant!;
    // --------------------------------------------------------------------

    // Parse price as number (site expects numbers, not strings)
    final priceText = _priceController.text.trim();
    final double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Price must be a number")));
      return;
    }

// Save exactly where the website reads: part_prices/${brand}_${cardId}
final String docId = '${brand}_${cardId}';
final ref = FirebaseFirestore.instance.collection('part_prices').doc(docId);

// 1) Write in a transaction and CAPTURE the updated prices map
Map<String, dynamic> updatedPrices = await FirebaseFirestore.instance.runTransaction((tx) async {
  final snap = await tx.get(ref);
  Map<String, dynamic> data = {};
  if (snap.exists && snap.data() != null) {
    data = Map<String, dynamic>.from(snap.data() as Map<String, dynamic>);
  }

  final Map<String, dynamic> prices = Map<String, dynamic>.from(data['prices'] ?? {});
  final Map<String, dynamic> partMap = Map<String, dynamic>.from(prices[part] ?? {});

  partMap[variant] = 'د.ل $priceText'; // store with currency
  prices[part] = partMap;

  data['brand']  = brand;
  data['cardId'] = cardId;
  data['title']  = cardTitle;
  data['prices'] = prices;

  tx.set(ref, data, SetOptions(merge: false));
  return prices; // <-- return the full nested map
});

// 2) Mirror the SAME nested prices into the brand/<cardId> doc
await FirebaseFirestore.instance
    .collection(brand)   // e.g. "apple"
    .doc(cardId)        // the phone's document ID
    .set({'prices': updatedPrices}, SetOptions(merge: true));



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
    // White input style function
InputDecoration whiteInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color.fromARGB(184, 135, 131, 131)),
    filled: true,
    fillColor: Colors.white, // <-- force white fill
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
    ),
  );
}



        const Color kBlue = Color(0xFF1565C0);

    final currentParts = _selectedBrand != null
        ? _brandParts[_selectedBrand!] ?? []
        : [];
    final currentVariants = (_selectedBrand != null && _selectedPart != null)
        ? (_brandPartVariants[_selectedBrand!]?[_selectedPart!] ?? [])
        : [];
return SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kBlue, // Your blue color constant
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        DropdownButtonFormField<String>(
          value: _selectedBrand,
          hint: const Text("Select Brand"),
          decoration: whiteInputDecoration("Select Brand"),
          dropdownColor: Colors.white,
          items: _brands
              .map((b) =>
                  DropdownMenuItem(value: b, child: Text(b.toUpperCase())))
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

        // Model
        DropdownButtonFormField<String>(
          value: _selectedModelTitle,
          hint: const Text("Select Model"),
          decoration: whiteInputDecoration("Phone Title"),
          dropdownColor: Colors.white,
          items: _models
              .map((m) =>
                  DropdownMenuItem(value: m['title'], child: Text(m['title']!)))
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

        // Part
        DropdownButtonFormField<String>(
          value: _selectedPart,
          hint: const Text("Select Part"),
          decoration: whiteInputDecoration("Part"),
          dropdownColor: Colors.white,
          isExpanded: true,
          items: currentParts
              .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedPart = val;
              _selectedVariant = null;
            });
          },
        ),
        const SizedBox(height: 10),

        // Variant
        DropdownButtonFormField<String>(
          value: _selectedVariant,
          hint: const Text("Select Variant"),
          decoration: whiteInputDecoration("Variant"),
          dropdownColor: Colors.white,
          isExpanded: true,
          items: currentVariants
              .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) => setState(() => _selectedVariant = val),
        ),
        const SizedBox(height: 10),

        // Price
   TextField(
  controller: _priceController,
  keyboardType: TextInputType.number,
  decoration: _inputDecoration("Enter Price").copyWith(
    prefixText: 'د.ل ',
    prefixStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
),

      
        const SizedBox(height: 20),

        // Save Button
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Price"),
            onPressed: _savePrice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    ),
  ),
);

  }

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint, // <-- hint inside the box
    hintStyle: const TextStyle(color: Colors.black54),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

}