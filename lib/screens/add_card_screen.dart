import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedBrand = "apple";
  File? _imageFile;
  final _brands = ["apple", "samsung", "xiaomi", "poco", "realme", "infinix"];
  final _picker = ImagePicker();
  bool _isLoading = false;

  // Theme colors from AdminHomeScreen
  static const Color kBlue = Color(0xFF1565C0);
  static const Color kSurface = Color(0xFFFDFEFF);

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveCard() async {
    if (_imageFile == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final ext = _imageFile!.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'jpg' || ext == 'jpeg')
          ? 'image/jpeg'
          : (ext == 'png')
          ? 'image/png'
          : 'image/*';
      final base64Image = "data:$mimeType;base64,${base64Encode(bytes)}";

      await FirebaseFirestore.instance.collection(_selectedBrand).add({
        'title': _titleController.text,
        'description': _descController.text,
        'imagePath': base64Image,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Card saved successfully!")));

      _titleController.clear();
      _descController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      print("🔥 Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 8,
        color: kBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Brand",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => _selectedBrand = value!),
                items: _brands
                    .map(
                      (brand) => DropdownMenuItem(
                        value: brand,
                        child: Text(
                          brand.toUpperCase(),
                          style: const TextStyle(color: kBlue),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Phone Title",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ), // style for placeholder
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  hintText: "Description (optional)",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),
              _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, height: 150),
                    )
                  : const Text(
                      "No image selected",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(
                  Icons.image,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                label: const Text(
                  "Pick Image",
                  style: TextStyle(color: Color.fromARGB(255, 254, 255, 255)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveCard,
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Save Card"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: kBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
