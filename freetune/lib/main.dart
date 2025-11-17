import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Change this to your server base URL
  static const String baseUrl = 'http://localhost:3000';

  const MyApp(
      {super.key}); // Android emulator; use local IP or ngrok for real device

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'R2 Song Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // ignore: library_private_types_in_public_api
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _health = 'unknown';
  String? _uploadedUrl;
  final player = AudioPlayer();
  bool uploading = false;

  Future<void> checkHealth() async {
    try {
      final r = await http.get(Uri.parse('${MyApp.baseUrl}/health'));
      setState(() =>
          _health = r.statusCode == 200 ? r.body : 'error: ${r.statusCode}');
    } catch (e) {
      setState(() => _health = 'error: $e');
    }
  }

  Future<void> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return;
    final file = File(result.files.single.path!);

    setState(() => uploading = true);
    try {
      final uri = Uri.parse('${MyApp.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('song', file.path));
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        setState(() {
          _uploadedUrl = (resp.body.contains('"url"'))
              ? RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(resp.body)!.group(1)
              : null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${resp.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<void> playUploaded() async {
    if (_uploadedUrl == null) return;
    try {
      await player.setUrl(_uploadedUrl!); // await is important
      await player.play();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Play error: $e')));
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text('R2 Song Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton(
              onPressed: checkHealth, child: Text('Check server health')),
          SizedBox(height: 8),
          Text('Health: $_health'),
          Divider(),
          ElevatedButton(
            onPressed: uploading ? null : pickAndUpload,
            child: Text(uploading ? 'Uploading...' : 'Pick & Upload Song'),
          ),
          const SizedBox(height: 8),
          if (_uploadedUrl != null)
            SelectableText('Uploaded URL:\n$_uploadedUrl'),
          Row(children: [
            ElevatedButton(
                onPressed: _uploadedUrl == null ? null : playUploaded,
                child: const Text('Play uploaded')),
            const SizedBox(width: 8),
            ElevatedButton(
                onPressed: () => player.stop(), child: const Text('Stop')),
          ])
        ]),
      ),
    );
  }
}
