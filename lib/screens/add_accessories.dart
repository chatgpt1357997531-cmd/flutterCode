import 'dart:convert';
import 'dart:io';

import 'package:adminpanelapp/screens/ManageAccessoriesScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const kBlue = Color(0xFF007BEF);

class AddAccessoriesScreen extends StatefulWidget {
  const AddAccessoriesScreen({super.key});

  @override
  State<AddAccessoriesScreen> createState() => _AddAccessoriesScreenState();
}

class _AddAccessoriesScreenState extends State<AddAccessoriesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  final _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  // ----- Brands & Categories (EN only) -----
  final _brands = const [
    'apple',
    'samsung',
    'xiaomi',
    'realme',
    'infinix',
    'poco',
  ];
  String _selectedBrand = 'apple';

  final _categories = const [
    '(كفرات)Cases',
    '(شواحن)Charger',
    '(وصلة)Cables',
    '(شاشة حماية)Screen Protector',
    '(سماعات)Earbuds',
    '(شحن خارجي)Power Bank',
     '(ملحقات الالعاب)Games Relateds',
    '(اخرى)Other',
  ];
  String _selectedCategory = 'Case';

  // ---------- Helpers ----------
  InputDecoration _input(
    String label, {
    Widget? prefix,
    String? hint,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black45),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBlue, width: 1.7),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _extOf(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : '';
  }

  String _collectionFor(String brand) => 'accessories_${brand.toLowerCase()}';

  // Normalize Arabic/Persian digits silently (for devices using those keyboards)
  String _normalizeDigits(String input) {
    const easternArabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(easternArabic[i], '$i');
      out = out.replaceAll(persian[i], '$i');
    }
    return out;
  }

  num? _parsePrice(String raw) {
    final normalized = _normalizeDigits(raw).trim();
    if (normalized.isEmpty) return null;
    // allow comma or dot as decimal separator
    return num.tryParse(normalized.replaceAll(',', '.'));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) setState(() => _imageFile = File(picked.path));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: kBlue),
                    foregroundColor: kBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAccessory() async {
    // Validate BEFORE toggling loading
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final priceParsed = _parsePrice(_priceController.text);

    if (_imageFile == null ||
        title.isEmpty ||
        desc.isEmpty ||
        priceParsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Encode image as base64 (website reads imagePath as a data URL)
      final bytes = await _imageFile!.readAsBytes();
      final ext = _extOf(_imageFile!.path);
      final mime = (ext == 'jpg' || ext == 'jpeg')
          ? 'image/jpeg'
          : (ext == 'png')
          ? 'image/png'
          : 'image/*';
      final base64Image = 'data:$mime;base64,${base64Encode(bytes)}';

      final coll = _collectionFor(_selectedBrand);

      // Firestore document shape matches your site
      await FirebaseFirestore.instance.collection(coll).add({
        'title': title,
        'description': desc,
        'desc': desc, // kept for web compatibility
        'imagePath': base64Image,
        'brand': _selectedBrand.toLowerCase(),
        'category': _selectedCategory, // EN only (site can adapt)
        'type': 'accessory',
        'price': priceParsed, // numeric
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Accessory saved ✅')));

      // Clear form (keep brand for faster repeated entry)
      setState(() {
        _titleController.clear();
        _descController.clear();
        _priceController.clear();
        _selectedCategory = _categories.first;
        _imageFile = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No AppBar. Clean header inside the body.
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header (replace your current header Text with this)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 48,
                      ), // spacer to balance the trailing button
                      const Text(
                        'Add Accessory',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ManageAccessoriesScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune, size: 18),
                        label: const Text('Manage'),
                        style: TextButton.styleFrom(foregroundColor: kBlue),
                      ),
                    ],
                  ),

                  // Form
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Brand & Category
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedBrand,
                                items: _brands
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b.toUpperCase()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(
                                  () => _selectedBrand = v ?? 'apple',
                                ),
                                decoration: _input('Brand'),
                                dropdownColor: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Category',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: -4,
                                children: _categories.map((c) {
                                  final selected = _selectedCategory == c;
                                  return ChoiceChip(
                                    selected: selected,
                                    label: Text(
                                      c,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    selectedColor: kBlue,
                                    backgroundColor: const Color(0xFFF2F4F7),
                                    onSelected: (_) =>
                                        setState(() => _selectedCategory = c),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: _input(
                            'Title',
                            prefix: const Icon(Icons.title),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        TextFormField(
                          controller: _descController,
                          decoration: _input(
                            'Description',
                            prefix: const Icon(Icons.description),
                          ),
                          minLines: 2,
                          maxLines: 6,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Description is required'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Price
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9\.,]'),
                            ),
                          ],
                          decoration: _input(
                            'Price',
                            prefix: const Icon(Icons.attach_money),
                            suffixText: 'LYD',
                          ),
                          validator: (v) {
                            final p = _parsePrice(v ?? '');
                            if (p == null) return 'Invalid price';
                            if (p < 0) return 'Price cannot be negative';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Image picker
                        InkWell(
                          onTap: _showImageSourceSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 190,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _imageFile == null
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 40,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Pick product image (camera / gallery)',
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 10,
                                          top: 10,
                                          child: Material(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: InkWell(
                                              onTap: _showImageSourceSheet,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky bottom Save
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() != true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fix the errors above'),
                              ),
                            );
                            return;
                          }
                          if (_imageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please choose an image'),
                              ),
                            );
                            return;
                          }
                          _saveAccessory();
                        },
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dim loading overlay
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(color: Colors.black.withOpacity(0.18)),
              ),
            ),
        ],
      ),
    );
  }
}
