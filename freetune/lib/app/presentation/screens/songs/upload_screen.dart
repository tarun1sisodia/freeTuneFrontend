import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/songs_controller.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../widgets/common/basic_app_button.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;

  final SongController _songController = Get.find<SongController>();

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
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
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Selection Area
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _selectedFilePath != null
                          ? Colors.green
                          : Colors.grey[800]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedFilePath != null
                            ? Icons.audio_file
                            : Icons.cloud_upload_outlined,
                        size: 48,
                        color: _selectedFilePath != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFileName ?? 'Tap to select audio file',
                        style: TextStyle(
                            color: _selectedFileName != null
                                ? Colors.white
                                : Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Song Title',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
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
              const SizedBox(height: 16),

              // Artist Input
              TextFormField(
                controller: _artistController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Artist Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.all(20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
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
              const SizedBox(height: 48),

              // Upload Button
              Obx(() => BasicAppButton(
                    onPressed: _songController.isUploading.value
                        ? () {}
                        : _upload, // Disable logic handled inside BasicAppButton usually, or pass callback.
                    // BasicAppButton doesn't support disabled styling transparently if we don't pass null.
                    // Let's modify logic: if uploading pass null to onPressed?
                    // BasicAppButton signature: VoidCallback onPressed.
                    // If I pass a function that does nothing, it's still clickable visually.
                    // I should probably handle loading state inside BasicAppButton or just use logic here.
                    // For now, I'll pass logic.
                    title: _songController.isUploading.value
                        ? 'Uploading...'
                        : 'Upload',
                    // weight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
