import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FileExplorer extends StatefulWidget {
  final String fileType;

  FileExplorer({required this.fileType});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<File> files = []; // Changed to List<File>
  List<File> selectedFiles = [];
  String rootPath = '';
  bool isSelectionMode = false;
  bool selectAll = false; // Track whether all files are selected

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadFiles();
  }

  Future<void> _checkPermissionsAndLoadFiles() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    await _loadFiles();
  }

  Future<void> _loadFiles() async {
    final directory = await getExternalStorageDirectory();
    final dcimPath = removeAndroid(directory!.path);
    if (await Directory(dcimPath).exists()) {
      await _listFiles(Directory(dcimPath));
    }
    setState(() {});
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
        if (_isFileType(extension, widget.fileType)) {
          files.add(entity); // Change to files.add(entity as File);
        }
      }
    }
  }

  bool _isFileType(String extension, String fileType) {
    switch (fileType) {
      case 'Image':
        return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
      case 'Video':
        return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
      case 'Audio':
        return ['mp3', 'wav', 'aac'].contains(extension);
      case 'Pdf':
        return ['pdf'].contains(extension);
      case 'Apk':
        return ['apk'].contains(extension);
      default:
        return false;
    }
  }

  void _openFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewer(file: file),
        ),
      );
    } else {
      OpenFile.open(file.path);
    }
  }



  void _renameFile(File file) async {
    final TextEditingController controller =
        TextEditingController(text: file.path.split('/').last);
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(controller: controller),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Rename'),
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      String newPath = file.path.replaceFirst(RegExp(r'[^/]+$'), newName);
      await file.rename(newPath);
      setState(() {
        files.remove(file);
        files.add(File(newPath));
      });
    }
  }

  void _showFileDetails(File file) {
    String fileSize = _formatFileSize(file.lengthSync());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Details'),
          content: Text('Path: ${file.path}\nSize: $fileSize'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes bytes';
    } else if (sizeInBytes < 1024 * 1024) {
      double sizeInKB = sizeInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      double sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else {
      double sizeInGB = sizeInBytes / (1024 * 1024 * 1024);
      return '${sizeInGB.toStringAsFixed(2)} GB';
    }
  }

  String removeAndroid(String path) {
    return path.split("Android").first;
  }

  Widget _buildFileTile(File file,BuildContext context) {
    final bool isSelected = selectedFiles.contains(file);
    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          _buildFileIcon(file,context),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.8),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
      title: Text(file.path.split('/').last),
      onTap: () {
        if (isSelectionMode) {
          _toggleSelection(file);
        } else {
          _openFile(file);
        }
      },
      onLongPress: () {
        if (!isSelectionMode) {
          _toggleSelection(file);
        }
      },
    );
  }

  Widget _buildFileIcon(File file,BuildContext context) {
    double sc_w=MediaQuery.of(context).size.width;
    double sc_h=MediaQuery.of(context).size.height;
    final extension = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return Image.file(file, width: 50, height: 50);
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return Icon(Icons.play_circle,color: Colors.tealAccent,);
    } else if (['mp3', 'wav', 'aac'].contains(extension)) {
      return Icon(Icons.music_note,color:Colors.pinkAccent,);
    } else if (['pdf'].contains(extension)) {
      return Container(
        width: sc_w*0.09,
        height:sc_h*0.1,
        child: Image.asset("local_image/pdf_logo.png"),
      );
    } else if (['apk'].contains(extension)) {
      return Icon(Icons.android,color: Colors.green,);
    } else {
      return Icon(Icons.insert_drive_file, size: 50);
    }
  }

  void _toggleSelection(File file) {
    setState(() {
      if (selectedFiles.contains(file)) {
        selectedFiles.remove(file);
      } else {
        selectedFiles.add(file);
      }
      isSelectionMode = selectedFiles.isNotEmpty;
    });
  }

  void _selectAllFiles() {
    setState(() {
      if (!selectAll) {
        selectedFiles.addAll(files);
      } else {
        selectedFiles.clear();
      }
      selectAll = !selectAll;
      isSelectionMode = selectedFiles.isNotEmpty;
    });
  }

  void _performDeleteAction() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Do you want to delete these files?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      for (var file in selectedFiles) {
        file.delete();
        files.remove(file);
      }
      setState(() {
        selectedFiles.clear();
        isSelectionMode = false;
        selectAll = false; // Reset selectAll flag after deletion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Explorer (${widget.fileType})'),
        actions: <Widget>[
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _performDeleteAction,
            ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isSelectionMode)
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          onTap: () {
                            Navigator.pop(context);
                            _performDeleteAction();
                          },
                        ),
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Rename'),
                        onTap: () {
                          Navigator.pop(context);
                          _renameFile(selectedFiles
                              .first); // Rename only the first selected file
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('Details'),
                        onTap: () {
                          Navigator.pop(context);
                          _showFileDetails(selectedFiles
                              .first); // Show details of the first selected file
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (isSelectionMode)
            TextButton(
              onPressed: _selectAllFiles,
              child: Text(
                selectAll ? 'Deselect All' : 'Select All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          File file = files[index];
          return _buildFileTile(file,context);
        },
      ),
    );
  }
}

class PDFViewer extends StatelessWidget {
  final File file;

  PDFViewer({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Container(
        child: PDFView(
          filePath: file.path,
        ),
      ),
    );
  }
}
