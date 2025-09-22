import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage(ImageSource source, bool isSelfie) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
    // Ajoute ici ton traitement (upload, validation, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérification du profil')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ajoute une photo pour authentifier ton profil'),
          const SizedBox(height: 20),
          _selectedImage != null
              ? Image.network(_selectedImage!.path, height: 150)
              : Icon(Icons.account_circle, size: 120),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.photo_camera),
                label: Text('Prendre une photo'),
                onPressed: () => _pickImage(ImageSource.camera, true),
              ),
              SizedBox(width: 15),
              ElevatedButton.icon(
                icon: Icon(Icons.photo_library),
                label: Text('Choisir dans la galerie'),
                onPressed: () => _pickImage(ImageSource.gallery, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
