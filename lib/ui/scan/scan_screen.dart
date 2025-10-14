import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skincare_app/services/firestore_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _message;
  List<Map<String, dynamic>> _detections = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _message = null;
        _detections = [];
      });

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

      try {
        final json = jsonDecode(responseBody);
        setState(() {
          _message = "Detected ${json['count']} condition(s)";
          _detections = (json['detections'] as List<dynamic>?)
                  ?.map((e) => Map<String, dynamic>.from(e))
                  .toList() ??
              [];
        });

        // Save detections to Firestore
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && _detections.isNotEmpty) {
          // Get existing detection classes
          final existingClasses =
              await FirestoreService().getUserDetectionClasses(uid);

          // Filter out detections that already exist
          final newDetections = _detections
              .where((det) => !existingClasses.contains(det['class']))
              .toList();

          // Save only new detections
          if (newDetections.isNotEmpty) {
            await FirestoreService().saveScanDetections(uid, newDetections);
          }
        }
      } catch (_) {
        setState(() {
          _message = responseBody;
          _detections = [];
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _detections = [];
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
                    Text(
                      _message ?? "Scan Complete!",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_detections.isNotEmpty)
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Detected Conditions",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              ..._detections.map((det) => ListTile(
                                    leading: Icon(Icons.check_circle,
                                        color: Colors.pink),
                                    title: Text(
                                      det['class'] ?? '',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    subtitle: det['bbox'] != null
                                        ? Text(
                                            "Bounding Box: ${det['bbox'].map((v) => v.toStringAsFixed(1)).join(', ')}")
                                        : null,
                                    trailing: Text(
                                      "${det['confidence']?.toStringAsFixed(1) ?? '0'}%",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "No conditions detected.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
