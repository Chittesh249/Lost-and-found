import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io'; // For mobile file handling if needed, but Supabase upload often takes byte data or file path
// NOTE: For web compatibility, we might need Uint8List. For IO, File. 
// Supabase Flutter `upload` method supports `File`. `uploadBinary` supports `Uint8List`.
// Since we might be on web or mobile, let's try to handle both or generic XFile.

class AddLostItemPage extends StatefulWidget {
  const AddLostItemPage({super.key});

  @override
  State<AddLostItemPage> createState() => _AddLostItemPageState();
}

class _AddLostItemPageState extends State<AddLostItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  // final _imageUrlController = TextEditingController(); // REMOVED

  bool _isLoading = false;
  XFile? _selectedImage;

  // Image Picker
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Upload Image to Supabase Storage
  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    final fileExt = _selectedImage!.name.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}_$userId.$fileExt';
    final filePath = 'lost_items/$fileName';

    try {
      final bytes = await _selectedImage!.readAsBytes();
      await Supabase.instance.client.storage
          .from('images') // Ensure 'images' bucket exists
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'), // Adjust based on fileExt if needed
          );
      
      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Upload Image first
      String? uploadedImageUrl;
      if (_selectedImage != null) {
         uploadedImageUrl = await _uploadImage(user.id);
      }

      await Supabase.instance.client.from('Lost_items').insert({
        'item_name': _nameController.text,
        'description': _descriptionController.text,
        'location_lost': _locationController.text,
        'date_lost': _dateController.text,
        'image_url': uploadedImageUrl,
        'reported_by': user.id,
        'reported_by_name': user.userMetadata?['full_name'] ?? 'User',
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lost item reported successfully!")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFD5316B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Lost Item"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location Lost"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date Lost (YYYY-MM-DD)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 12),
              // Image Picker UI
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Text("Selected: ${_selectedImage!.name}", style: const TextStyle(color: Colors.green)),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
