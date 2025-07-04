import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomFile {
  final File file;
  bool isVisible;

  CustomFile({required this.file, this.isVisible = false});
}

class FileSelectionPage extends StatefulWidget {
  final String from;
  final String fileType;
  final List<File> files;
  final bool is_black;

  const FileSelectionPage({
    Key? key,
    required this.from,
    required this.fileType,
    required this.files,
    required this.is_black,
  }) : super(key: key);

  @override
  State<FileSelectionPage> createState() => _FileSelectionPageState();
}

class _FileSelectionPageState extends State<FileSelectionPage> {
  List<CustomFile> allFiles = [];
  Set<CustomFile> selectedFiles = Set();

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    select_files();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    Directory? directory;
    if (widget.from == 'Internal Storage') {
      final internalDir = await getExternalStorageDirectory();
      if (internalDir != null) {
        directory = Directory(removeAndroid(internalDir.path));
      }
    } else if (widget.from == 'SD Card') {
      directory = await getExternalSdCardPath();
    }

    if (directory != null) {
      await _listFiles(directory);
      setState(() {});
    }
  }

  Future<Directory> getExternalSdCardPath() async {
    List<Directory>? extDirectories = await getExternalStorageDirectories();

    List<String>? dirs = extDirectories?[1].toString().split('/');
    String rebuiltPath = '/' + dirs![1] + '/' + dirs[2] + '/';

    print("rebuilt path: " + rebuiltPath);
    return Directory(rebuiltPath);
  }

  Future<void> _listFiles(Directory dir) async {
    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        if (entity.path.contains('/Android')) {
          continue;
        } else {
          await _listFiles(entity);
        }
      } else if (entity is File) {
        final extension = entity.path.split('.').last.toLowerCase();
        if (_matchesFileType(extension, widget.fileType)) {
          setState(() {
            final customFile = CustomFile(file: entity);
            allFiles.add(customFile);
            selectedFiles.add(customFile);
          });
        }
      }
    }
  }

  bool _matchesFileType(String extension, String fileType) {
    switch (fileType) {
      case 'Videos':
        return extension == 'mp4' || extension == 'avi' || extension == 'mov';
      case 'Images':
        return extension == 'jpg' || extension == 'png' || extension == 'jpeg';
      case 'Audio':
        return extension == 'mp3' || extension == 'wav';
      case 'Pdf':
        return extension == 'pdf';
      case 'Apk':
        return extension == 'apk';
      default:
        return false;
    }
  }

  String removeAndroid(String path) {
    return path.split("Android").first;
  }

  Future<void> select_files() async {
    List<File> selectedFilePaths = selectedFiles.map((customFile) => customFile.file).toList();
    Navigator.pop(context, selectedFilePaths);
  }

  @override
  Widget build(BuildContext context) {
    double screenwith = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    bool is_black2 = widget.is_black;
    return WillPopScope(
      onWillPop: () async {
        await select_files();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.fileType} Files",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedFiles.length == allFiles.length) {
                    selectedFiles.clear();
                  } else {
                    selectedFiles.addAll(allFiles);
                  }
                });
              },
              child: Text(
                selectedFiles.length == allFiles.length
                    ? "Deselect All"
                    : "Select All",
                style: TextStyle(color: is_black2 ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: allFiles.length,
          itemBuilder: (context, index) {
            final customFile = allFiles[index];
            final file = customFile.file;
            final extension = file.path.split('.').last.toLowerCase();
            bool isSelected = selectedFiles.contains(customFile);

            return ListTile(
              leading: VisibilityDetector(
                key: Key(file.path),
                onVisibilityChanged: (info) {
                  setState(() {
                    customFile.isVisible = info.visibleFraction > 0;
                  });
                },
                child: customFile.isVisible
                    ? _getFileIcon(extension, screenwith, screenheight, true, customFile.file)
                    : _getFileIcon(extension, screenwith, screenheight, false, customFile.file),
              ),
              title: Text(file.path.split('/').last),
              trailing: IconButton(
                icon: Icon(Icons.check_box,
                    color: isSelected ? Colors.green : Colors.white),
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      selectedFiles.remove(customFile);
                    } else {
                      selectedFiles.add(customFile);
                    }
                  });
                },
              ),
            );
          },
        ),

      ),
    );
  }

  Widget _getFileIcon(String extension, double sc_w, double sc_h, bool isVisible, File file) {
    switch (extension) {
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icon(Icons.play_circle, color: Colors.tealAccent);
      case 'png':
      case 'jpg':
      case 'jpeg':
        if (isVisible) {
          return Container(
              padding: EdgeInsets.only(top: 3, bottom: 3),
              child: Image.file(file, width: sc_w * 0.2, height: sc_h * 0.2)
          );
        } else {
          return Icon(Icons.image, color: Colors.lightBlueAccent);
        }
        break;
      case 'mp3':
      case 'wav':
        return Icon(Icons.music_note, color: Colors.pinkAccent);
      case 'pdf':
        return isVisible
            ? Container(
          width: sc_w * 0.2,
          height: sc_h * 0.2,
          child: Image.asset("local_image/pdf_logo.png"),
        )
            : Icon(Icons.picture_as_pdf, color: Colors.redAccent);
      case 'apk':
        return Icon(Icons.android, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file);
    }
  }
}