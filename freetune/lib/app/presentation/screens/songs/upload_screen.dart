import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/songs_controller.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../widgets/common/basic_app_button.dart';
import '../../../core/utils/app_sizes.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedImagePath;

  final SongController _songController = Get.find<SongController>();

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
      });
    }
  }

  Future<void> _upload() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedFilePath == null) {
        Get.snackbar(
          'Error',
          'Please select a song file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final success = await _songController.uploadSong(
        _selectedFilePath!,
        _titleController.text,
        _artistController.text,
        _albumController.text,
        _selectedImagePath,
      );

      if (success) {
        Get.back(); // Go back to previous screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const BasicAppBar(
        title: Text('Upload Song'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.w(20.0)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image Selection
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: AppSizes.w(180),
                    width: AppSizes.w(180),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(AppSizes.radius *
                          2), // Larger radius for image placeholder
                      border: Border.all(
                        color: _selectedImagePath != null
                            ? Colors.green
                            : Colors.grey[800]!,
                        width: 2,
                      ),
                      image: _selectedImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(
                                  _selectedImagePath!)), // Using dart:io File
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: AppSizes.w(48),
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: AppSizes.h(8)),
                              Text(
                                'Add Cover Art',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: AppSizes.sp(14),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h(32)),

              // Audio File Selection
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: AppSizes.h(100),
                  padding: EdgeInsets.all(AppSizes.w(16)),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    border: Border.all(
                      color: _selectedFilePath != null
                          ? Colors.green
                          : Colors.grey[800]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFilePath != null
                            ? Icons.audio_file
                            : Icons.cloud_upload_outlined,
                        size: AppSizes.w(40),
                        color: _selectedFilePath != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      SizedBox(width: AppSizes.w(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedFileName ?? 'Select Audio File',
                              style: TextStyle(
                                  color: _selectedFileName != null
                                      ? Colors.white
                                      : Colors.grey[400],
                                  fontSize: AppSizes.sp(16),
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_selectedFileName == null)
                              Text(
                                'Tap to choose song',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: AppSizes.sp(12)),
                              ),
                          ],
                        ),
                      ),
                      if (_selectedFilePath != null)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h(32)),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Song Title',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(AppSizes.w(20)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  prefixIcon:
                      const Icon(Icons.music_note_outlined, color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.h(16)),

              // Artist Input
              TextFormField(
                controller: _artistController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Artist Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(AppSizes.w(20)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  prefixIcon:
                      const Icon(Icons.person_outline, color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an artist name';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.h(16)),

              // Album Input (Optional)
              TextFormField(
                controller: _albumController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Album Name (Optional)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(AppSizes.w(20)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  prefixIcon:
                      const Icon(Icons.album_outlined, color: Colors.grey),
                ),
              ),
              SizedBox(height: AppSizes.h(48)),

              // Upload Button
              Obx(() => BasicAppButton(
                    onPressed:
                        _songController.isUploading.value ? () {} : _upload,
                    title: _songController.isUploading.value
                        ? 'Uploading...'
                        : 'Upload',
                  )),
              SizedBox(height: AppSizes.h(20)),
            ],
          ),
        ),
      ),
    );
  }
}
