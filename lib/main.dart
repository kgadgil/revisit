import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _pickedFileName;
  File? _pickedFile;

  Future<void> _pickRandomFile() async {
    print("Requesting storage permission");
    // Check and request storage permission
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      print("Storage permission granted");
      // Get the downloads directory
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      List<FileSystemEntity> files = downloadsDirectory.listSync();

      // Filter PDF files
      List<File> pdfFiles = files
          .where((file) => file.path.endsWith('.pdf'))
          .map((file) => File(file.path))
          .toList();

      if (pdfFiles.isNotEmpty) {
        // Pick a random PDF file
        Random random = Random();
        int randomIndex = random.nextInt(pdfFiles.length);
        File randomFile = pdfFiles[randomIndex];

        setState(() {
          _pickedFileName = randomFile.path.split('/').last;
          _pickedFile = randomFile;
        });
      } else {
        setState(() {
          _pickedFileName = null;
          _pickedFile = null;
        });

        // Show a dialog indicating no PDF files found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No PDF Files Found'),
            content: Text('No PDF files found in the downloads folder.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      print("Storage permission denied");
      // Permission not granted, show a dialog to request permission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('This app needs storage permission to access PDF files.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                openAppSettings(); // Open app settings to grant permission
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openFile() async {
    if (_pickedFile != null) {
      OpenFile.open(_pickedFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random PDF Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickRandomFile,
              child: Text('Pick Random File'),
            ),
            SizedBox(height: 20),
            if (_pickedFileName != null)
              Column(
                children: [
                  Text(
                    'Picked File: $_pickedFileName',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _openFile,
                    child: Text('Open File'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
