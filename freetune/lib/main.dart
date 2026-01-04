import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';

// FFI signature for setlocale
typedef SetLocaleC = Pointer<Utf8> Function(
    Int32 category, Pointer<Utf8> locale);
typedef SetLocaleDart = Pointer<Utf8> Function(
    int category, Pointer<Utf8> locale);

void main() async {
  // Initialize FFI for Linux locale if needed
  if (Platform.isLinux) {
    try {
      // libmpv/ffmpeg requirements on Linux often need LC_NUMERIC to be "C"
      final dylib = DynamicLibrary.open('libc.so.6');
      final setLocale =
          dylib.lookupFunction<SetLocaleC, SetLocaleDart>('setlocale');

      // LC_NUMERIC = 1 on Linux
      setLocale(1, 'C'.toNativeUtf8());
      debugPrint('Locale set to C for LC_NUMERIC');
    } catch (e) {
      debugPrint('Failed to set locale: $e');
    }

    try {
      MediaKit.ensureInitialized(libmpv: '/usr/lib/x86_64-linux-gnu/libmpv.so');
    } catch (e) {
      debugPrint('MediaKit initialization warning: $e');
    }
    JustAudioMediaKit.ensureInitialized();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings()
      .dependencies(); // Initialize core services before app runs
  runApp(const FreeTuneApp());
}

class FreeTuneApp extends StatelessWidget {
  const FreeTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FreeTune',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
