import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_to_sd/sidebar.dart';
import 'storage_units.dart';

class FileManagerHome extends StatefulWidget {
  final String? internal_fullspace;
  final String? internal_usedspace;
  final String? internal_available;
  final String? external_fullspace;
  final String? external_usedspace;
  final String? external_available;
  final List<String> video;

  final void Function(bool) toggleTheme;

  const FileManagerHome({
    Key? key,
    required this.external_fullspace,
    required this.internal_fullspace,
    required this.internal_usedspace,
    required this.external_usedspace,
    required this.external_available,
    required this.internal_available,
    required this.video,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _FileManagerHomeState createState() => _FileManagerHomeState();
}

class _FileManagerHomeState extends State<FileManagerHome> {
  int imageCount = 0;
  int videoCount = 0;
  int audioCount = 0;
  int pdfCount = 0;
  int apkCount = 0;



  @override
  void initState() {

    super.initState();
    _checkPermissionsAndLoadFiles();


  }




  Future<void> _checkPermissionsAndLoadFiles() async {

      await countMediaFiles();

  }
  void createSubfolders(String folderPath) {
    final List<String> subfolders = ['Images files', 'Videos files', 'Pdf files', 'Audios files', 'Apk files'];

    for (var subfolder in subfolders) {
      final Directory subfolderDir = Directory('$folderPath/$subfolder');
      if (!subfolderDir.existsSync()) {
        subfolderDir.createSync(recursive: true);
        print('Created: $folderPath/$subfolder');
      } else {
        print('Already exists: $folderPath/$subfolder');
      }
    }
  }
  Future<String> getExternalSdCardPath() async {
    List<Directory>? extDirectories = await getExternalStorageDirectories();

    List<String>? dirs = extDirectories?[1].toString().split('/');
    String rebuiltPath = '/' + dirs![1] + '/' + dirs[2];

    print("rebuilt path: " + rebuiltPath);
    return rebuiltPath;
  }


  Future<bool> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else {
        print('Manage External Storage permission denied');
        return false;
      }
    } else {
      print('Storage permission denied');
      return false;
    }
  }

  Future<int> countMediaFiles() async {
    final directory = await getExternalStorageDirectory();
    final dcimPath = removeAndroid(directory!.path);


     createSubfolders(dcimPath+"PD_Storage");
      createSubfolders(await getExternalSdCardPath());
    if (await Directory(dcimPath).exists()) {
      print("Scanning directory: $dcimPath");
      await _countFilesInDirectory(Directory(dcimPath), (int vCount, int iCount, int aCount,int pCount,int apCount) {
        videoCount += vCount;
        imageCount += iCount;
        audioCount += aCount;
         pdfCount += pCount;
         apkCount += apCount;
      });

      setState(() {});

      print("video: $videoCount");
      print("photo: $imageCount");
      print("audio: $audioCount");
    }

    return videoCount + imageCount + audioCount;
  }


  Future<void> _countFilesInDirectory(Directory dir, Function(int, int, int, int, int) callback) async {
    int videoCount = 0;
    int imageCount = 0;
    int audioCount = 0;
    int pdfCount = 0;
    int apkCount = 0;

    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        print("folder:${entity.path}");
        if (entity.path.contains('/Android')) {
          print("Skipping Android directory: ${entity.path}");
          continue;
        } else {
          await _countFilesInDirectory(entity, (int vCount, int iCount, int aCount, int pCount, int apCount) {
            videoCount += vCount;
            imageCount += iCount;
            audioCount += aCount;
            pdfCount += pCount;
            apkCount += apCount;
          });
        }
      } else if (entity is File) {
        final extension = entity.path.split('.').last.toLowerCase();
        switch (extension) {
          case 'mp4':
            videoCount++;
            break;
          case 'jpg':
          case 'png':
          case 'jpeg':

            imageCount++;
            break;
          case 'mp3':
            audioCount++;
            break;
          case 'pdf':
            pdfCount++;
            break;
          case 'apk':
            apkCount++;
            break;
          default:

            break;
        }
      } else {
        print("Unknown entity: ${entity.path}");
      }
    }

    callback(videoCount, imageCount, audioCount, pdfCount, apkCount);
  }


  String removeAndroid(String path) {
    return path.split("Android").first;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: sidebar(context, widget.toggleTheme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace:isDarkTheme?Container(
          color: Colors.black,
        ): Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(102, 255, 178, 1),
                Color.fromRGBO(153, 153, 255, 1),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
      body: Container(
        decoration:isDarkTheme?BoxDecoration(color: Colors.black) :BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(102, 255, 178, 1),
              Color.fromRGBO(153, 153, 255, 1),
            ],
            begin: Alignment.topRight,
            end: Alignment.topLeft,
          ),
        ),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            color: isDarkTheme ? Colors.black : Colors.white,
          ),
          padding: EdgeInsets.all(screenWidth * 0.009),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.03, top: screenHeight * 0.009),
                child: Text(
                  'Storage',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.03, top: screenHeight * 0.003),
                child: Text(
                  'It does not include system files',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  storage_units(
                    "Internal Storage",
                    widget.internal_usedspace ?? "",
                    widget.internal_fullspace ?? "",
                    widget.internal_available ?? "",
                    isDarkTheme,
                  ),
                  storage_units(
                    "SD Card",
                    widget.external_usedspace ?? "",
                    widget.external_fullspace ?? "",
                    widget.external_available ?? "",
                    isDarkTheme,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.009),
              transfer_file(screenHeight, screenWidth, context,
                  widget.external_fullspace ?? "", isDarkTheme),
              SizedBox(height: screenHeight * 0.025),
              Container(
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? Color.fromRGBO(198, 198, 198, 0.2)
                      : Color.fromRGBO(192, 192, 192, 0.3),
                  borderRadius: BorderRadius.circular(20),
                  gradient:isDarkTheme?null: LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent,
                      Colors.greenAccent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.0, 0.7],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    storage_items("Image", imageCount, context),
                    storage_items("Video", videoCount, context),
                    storage_items("Audio", audioCount, context),
                    storage_items("Pdf", pdfCount, context),
                    storage_items("Apk", apkCount, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
