import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _resultText;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _resultText = null;
      });

      // Send image to API
      await _sendImageToApi(_selectedImage!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendImageToApi(File imageFile) async {
    final url = Uri.parse('http://192.168.29.189:8000/detect/');
    var request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      // Try to parse JSON
      String displayText;
      try {
        final json = jsonDecode(responseBody);
        displayText = json.toString(); // Or extract specific fields
      } catch (_) {
        displayText = responseBody;
      }

      setState(() {
        _resultText = displayText;
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Scan",
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Processing your image...",
                        style: TextStyle(fontSize: 18)),
                  ],
                )
              else if (_selectedImage != null)
                Column(
                  children: [
                    Image.file(_selectedImage!, height: 300),
                    const SizedBox(height: 10),
                    const Text("Scan Complete!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (_resultText != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_resultText!,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                  ],
                )
              else
                const Icon(Icons.image, size: 120, color: Colors.grey),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  "Take Photo",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: Text(
                  "Upload from Gallery",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
