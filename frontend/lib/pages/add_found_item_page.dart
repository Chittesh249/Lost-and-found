import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddFoundItemPage extends StatefulWidget {
  const AddFoundItemPage({super.key});

  @override
  State<AddFoundItemPage> createState() => _AddFoundItemPageState();
}

class _AddFoundItemPageState extends State<AddFoundItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _contactController = TextEditingController();
  
  // Security Question Fields
  final _securityQuestionController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  bool _isLoading = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _prefillContactInfo();
  }

  void _prefillContactInfo() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Try to get phone from auth object or metadata
      String? phone = user.phone;
      if (phone == null || phone.isEmpty) {
        phone = user.userMetadata?['phone'] ?? user.userMetadata?['phone_number'];
      }
      if (phone != null && phone.isNotEmpty) {
        _contactController.text = phone;
      }
    }
  }

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

  // Upload Image
  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    final fileExt = _selectedImage!.name.split('.').last;
    final fileName = '${DateTime.now().toIso8601String()}_$userId.$fileExt';
    final filePath = 'found_items/$fileName';

    try {
      final bytes = await _selectedImage!.readAsBytes();
      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      
      final imageUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      // Continue without image or handle error?
      // For now, let's treat image upload failure as non-blocking but warn?
      // Or throw exception to stop submission.
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? uploadedImageUrl;
      if (_selectedImage != null) {
        uploadedImageUrl = await _uploadImage(user.id);
      }

      await Supabase.instance.client.from('Found_items').insert({
        'item_name': _nameController.text,
        'description': _descriptionController.text,
        'location_found': _locationController.text,
        'date_found': _dateController.text, 
        'image_url': uploadedImageUrl,
        'contact_info': _contactController.text,
        'security_question': _securityQuestionController.text,
        'security_answer': _securityAnswerController.text,
        'reported_by': user.id,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Found item reported successfully!")),
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
        title: const Text("Report Found Item"),
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
                decoration: const InputDecoration(labelText: "Location Found"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "Date Found (YYYY-MM-DD)"),
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
              
              // Image Picker
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

              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: "Contact Info (Phone/Email)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              
              const Text("Security Question", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("The claimant must answer this to see your contact info."),
              const SizedBox(height: 8),
              TextFormField(
                controller: _securityQuestionController,
                decoration: const InputDecoration(
                  labelText: "Question (e.g. What is the wallpaper?)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _securityAnswerController,
                decoration: const InputDecoration(
                  labelText: "Answer",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

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
