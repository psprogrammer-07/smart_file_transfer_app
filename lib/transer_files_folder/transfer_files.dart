import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'file_select_page.dart';

class TransferFiles extends StatefulWidget {
  final String from;
  final String to;
  final bool is_black;

  const TransferFiles({super.key, required this.from, required this.to,required this.is_black});

  @override
  State<TransferFiles> createState() => _TransferFilesState();
}

class _TransferFilesState extends State<TransferFiles> {
  List<File> files = [];

  List<File> videos_files=[];
  List<File> images_files=[];
  List<File> audios_files=[];
  List<File> pdf_files=[];
  List<File> apk_files=[];


  int videoCount = 0;
  int imageCount = 0;
  int audioCount = 0;
  int pdfCount = 0;
  int apkCount = 0;

  bool isloading =true;

  bool isOn = true;

  bool isdelete=false;



  void toggleButton() {
    setState(() {
      isOn = !isOn;
    });
    if(isOn) {
      print("in deleted mode");

    }
  }


  @override
  void initState() {
    super.initState();
    _loadFileCounts();
  }

  Future<void> _loadFileCounts() async {
    videoCount = await _countFiles(widget.from, 'Videos');
    imageCount = await _countFiles(widget.from, 'Images');
    audioCount = await _countFiles(widget.from, 'Audio');
    pdfCount = await _countFiles(widget.from, 'Pdf');
    apkCount = await _countFiles(widget.from, 'Apk');
    setState(() {
      isloading=false;
    });
  }

  Future<int> _countFiles(String from, String fileType) async {
    Directory? directory;

    if (from == 'Internal Storage') {
      final internalDir = await getExternalStorageDirectory();
      print("dirrrrrrrrrr:${internalDir?.path}");
      if (internalDir != null) {
        directory = Directory(removeAndroid(internalDir.path));
        print("dirrrrrrrrrr:${directory.path}");
      }
    } else if (from == 'SD Card') {
      // Replace with the actual path to your SD card
      directory=await getExternalSdCardPath();
    }

    if (directory != null) {
      int count = 0;
      count = await _listFiles(directory, fileType);
      return count;
    }

    return 0;
  }

  Future<int> _listFiles(Directory dir, String fileType) async {
    int count = 0;
    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (entity.path.contains('/Android')) {
        continue;
      }
      if (entity is Directory) {
        if (entity.path.contains('/Android')) {
          continue;
        } else {
          count += await _listFiles(entity, fileType);
        }
      } else if (entity is File) {
        final extension = entity.path.split('.').last.toLowerCase();
        if (_matchesFileType(extension, fileType,entity)) {


          count++;
        }
      }
    }
    return count;
  }

  bool _matchesFileType(String extension, String fileType,File file) {
    switch (fileType.toLowerCase()) {
      case 'videos':
        if( extension == 'mp4' || extension == 'avi' || extension == 'mov'){
          videos_files.add(file);
          return true;
        }
        return false;
      case 'images':
        if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
          images_files.add(file);
          return true;
        }
        return false;
      case 'audio':
        if (extension == 'mp3' || extension == 'wav') {
          audios_files.add(file);
          return true;
        }
        return false;
      case 'pdf':
        if(extension == 'pdf') {
          pdf_files.add(file);
          return true;
        }
        return false;
      case 'apk':
        if (extension == 'apk') {
          apk_files.add(file);
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  String removeAndroid(String path) {
    return path.split("Android").first;
  }

  String removeAndroid_for_sd(String path) {
    return path.split("Android").first+"SDCARD";
  }

  Future<Directory> getExternalSdCardPath() async {
    List<Directory>? extDirectories = await getExternalStorageDirectories();

    List<String>? dirs = extDirectories?[1].toString().split('/');
    String rebuiltPath = '/' + dirs![1] + '/' + dirs[2] + '/';

    print("rebuilt path: " + rebuiltPath);
    return new Directory(rebuiltPath);
  }

  @override
  Widget build(BuildContext context) {
    double screenwith =MediaQuery.of(context).size.width;
    double screenheight=MediaQuery.of(context).size.height;
    bool is_black2=widget.is_black;
    return Scaffold(
      backgroundColor:is_black2?Colors.black:Colors.transparent,
     appBar:  AppBar(
       title: Text(widget.from ,style: TextStyle(color: Colors.white),),
        backgroundColor:is_black2?Colors.black:Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient:is_black2?null: LinearGradient(
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
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient:is_black2?null: LinearGradient(
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
                color:is_black2? Color.fromRGBO(198, 198, 198, 0.2):Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(60,),topRight: Radius.circular(60)),
        
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: screenheight*0.012,),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient:is_black2?null: LinearGradient(
                        colors: [
                         Colors.grey.shade200,
                          Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      "Transfer data from ${widget.from} to ${widget.to}",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenheight*0.005),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    fileTypesWidget("Videos", videoCount, screenheight,screenwith,is_black2),
                    fileTypesWidget("Images", imageCount, screenheight, screenwith,is_black2),
                    fileTypesWidget("Audio", audioCount, screenheight, screenwith,is_black2),
                    fileTypesWidget("Pdf", pdfCount, screenheight, screenwith,is_black2),
                    fileTypesWidget("Apk", apkCount, screenheight, screenwith,is_black2),
                  ],
                ),
              ),
            ),
                SizedBox(height: screenheight*0.009,),
        
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
        
                    children: [
                      Expanded(child: Text("You Want Delete Selected Files In ${widget.from} After Trasfered the Files in to ${widget.to}",style: TextStyle(fontSize: screenheight*0.018),)),
        
                      on_off_button(screenwith,screenheight),
                    ],
                  ),
                ),
        
        
                SizedBox(height: screenheight*0.009,),
                Container(
                  decoration: BoxDecoration(
                    color:is_black2? Color.fromRGBO(198, 198, 198, 0.1):Color.fromRGBO(192, 192, 192, 0.3),
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(102, 255, 178, 1),
                        Color.fromRGBO(153, 153, 255, 1),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                    ),
                  ),
                  child: mainButton(context,'delete',true),
                ),
                SizedBox(height: screenheight*0.01,),
                Container(
                  decoration: BoxDecoration(
                    color:is_black2? Color.fromRGBO(198, 198, 198, 0.1):Color.fromRGBO(192, 192, 192, 0.3),
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(102, 255, 178, 1),
                        Color.fromRGBO(153, 153, 255, 1),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                    ),
                  ),
                  child: mainButton(context,'no_delete',false),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget fileTypesWidget(String fileType, int itemCount,double screenheight,double screenwidth,bool is_black) {
    // Calculate total size of selected files
    int totalSize = 0;
    switch (fileType) {
      case 'Videos':
        for (var file in videos_files) {
          totalSize += file.lengthSync();
        }
        break;
      case 'Images':
        for (var file in images_files) {
          totalSize += file.lengthSync();
        }
        break;
      case 'Audio':
        for (var file in audios_files) {
          totalSize += file.lengthSync();
        }
        break;
      case 'Pdf':
        for (var file in pdf_files) {
          totalSize += file.lengthSync();
        }
        break;
      case 'Apk':
        for (var file in apk_files) {
          totalSize += file.lengthSync();
        }
        break;
    }

    return Padding(

      padding: EdgeInsets.only(top: screenheight*0.009,bottom: screenheight*0.009),
      child: TextButton(
        onPressed: () async {
          List<File> selectedFiles = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileSelectionPage(
                from: widget.from,
                fileType: fileType,
                files: files,
                is_black: is_black,
              ),
            ),
          );

          if (selectedFiles != null) {
            setState(() {
              switch (fileType) {
                case 'Videos':
                  videoCount = selectedFiles.length;
                  videos_files.clear();
                  videos_files.addAll(selectedFiles);
                  break;
                case 'Images':
                  imageCount = selectedFiles.length;
                  images_files.clear();
                  setState(() {
                    images_files.addAll(selectedFiles);
                  });
                  break;
                case 'Audio':
                  audioCount = selectedFiles.length;
                  audios_files.clear();
                  audios_files.addAll(selectedFiles);
                  break;
                case 'Pdf':
                  pdfCount = selectedFiles.length;
                  pdf_files.clear();
                  pdf_files.addAll(selectedFiles);
                  break;
                case 'Apk':
                  apkCount = selectedFiles.length;
                  apk_files.clear();
                  apk_files.addAll(selectedFiles);
                  break;
              }
            });
          }
        },
        child: Container(
          height:screenheight*0.06,
          child: Row(
            children: [
             generate_icons(fileType,screenwidth,screenheight),
              SizedBox(width: screenwidth*0.065),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileType,
                    style: GoogleFonts.lato(
                      fontSize: 16 ,
                      fontWeight: FontWeight.bold,
                      color:Theme.of(context).textTheme.bodyLarge?.color ,
                    ),
                  ),
                  isloading?Container(
                    constraints: BoxConstraints(
                      maxHeight: screenheight*0.02,
                      maxWidth: screenwidth*0.035,
                    ),
                    child: CircularProgressIndicator(

                      color: Colors.grey,
                      backgroundColor: Colors.white,
                    ),
                  ):
                  Container(
                    child: Row(
                      children: [
                        Text("Items: $itemCount", style: TextStyle(color:Theme.of(context).textTheme.bodyLarge?.color ,)),
                        SizedBox(width: 10),
                        Text(
                          "Total Size: ${_formatBytes(totalSize)}",
                          style: TextStyle(color:Theme.of(context).textTheme.bodyLarge?.color ,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  String _formatBytes(int sizeInBytes) {
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

  Future<void> transferFiles(List<File> files, String to, String type, ValueNotifier<double> progressNotifier, bool is_delete) async {
    print("filessssssssss:${files}");
    var newDirectoryPath;
    if (is_delete) {
      setState(() {
        isOn = true;
      });
    }

    if (files.isNotEmpty) {
      try {
        Directory? directory;
        if (to == "SD Card") {
          directory = await getExternalSdCardPath();
        } else {
          final internalDir = await getExternalStorageDirectory();
          if (internalDir != null) {
            directory = Directory(removeAndroid(internalDir.path));
          }
        }

        if (!is_delete) {
          final now = DateTime.now();
          final formattedDate = "${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}";
          newDirectoryPath = "${directory?.path}/PD_Storage/$type/$formattedDate";
          final newDirectory = Directory(newDirectoryPath);
          if (!await newDirectory.exists()) {
            await newDirectory.create(recursive: true);
          }
        }

        Set<String> existingFileNames = {};

        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          String fileName = file.path.split('/').last;

          // Ensure unique file name
          String uniqueFileName = fileName;
          int counter = 1;
          while (existingFileNames.contains(uniqueFileName)) {
            uniqueFileName = "${fileName.split('.').first}_$counter.${fileName.split('.').last}";
            counter++;
          }
          existingFileNames.add(uniqueFileName);

          if (!is_delete) {
            final newFilePath = "$newDirectoryPath/$uniqueFileName";
            final newFile = await File(newFilePath).create(recursive: true);
            await file.copy(newFile.path);
          }

          if (isOn) {
            await file.delete();
          }

          progressNotifier.value = (i + 1) / files.length;
        }

        print("Files transferred successfully to $newDirectoryPath");
      } catch (e) {
        print("Error transferring files: $e");
        showMessageDialog(context, e.toString());
      }
    }
  }



  void showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Widget generate_icons(String iconName,double sc_w,double sc_h) {
    switch (iconName) {
      case "Images":
        return Icon(Icons.image,color: Colors.lightBlueAccent[100],);
      case "Videos":
        return Icon(Icons.play_circle,color: Colors.tealAccent);
      case "Audio":
        return Icon(Icons.music_note,color:Colors.pinkAccent,);
      case 'Pdf':
        return  Container(
          width: sc_w*0.1,
          height: sc_h*0.1,
          constraints: BoxConstraints(
            maxWidth: sc_w*0.4,
            maxHeight: sc_h*0.4
          ),
            child: Image.asset("local_image/pdf_logo.png"),
        );

      case 'Apk':
        return Icon(Icons.android,color: Colors.green,);
      default:
        return Container();
    }
  }

  Widget mainButton(BuildContext context, String from,bool is_delete) {
    String text_value = "Transfer All Files to ${widget.to}";
    if (from == 'delete') {
      setState(() {

        text_value = "delete";
      });
    }
    return TextButton(
      child: Text(
        text_value,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      onPressed: () async {
        if (from == 'delete') {
          setState(() {
            isdelete = true;
            text_value = "delete";
          });
        }
        else{
          setState(() {
            isdelete=false;
          });
        }
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('You want to ${isdelete ? "delete" : "transfer"} the selected files?'),
              actions: <Widget>[
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          ValueNotifier<double> progressNotifier = ValueNotifier(0.0);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Text('${isdelete?"deleting":"Transferring" } Files'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: progressNotifier,
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            backgroundColor: Colors.grey,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTotalSelectedFilesSize(),
                      ValueListenableBuilder<double>(
                        valueListenable: progressNotifier,
                        builder: (context, value, child) {
                          return Text('${(value * 100).toStringAsFixed(2)}% completed');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );



          try {
            await transferFiles(videos_files, widget.to, "Videos files", progressNotifier, is_delete);
            await transferFiles(images_files, widget.to, "Images files", progressNotifier, is_delete);

            await transferFiles(audios_files, widget.to, "Audios files", progressNotifier, is_delete);
            await transferFiles(pdf_files, widget.to, "Pdf files", progressNotifier, is_delete);
            await transferFiles(apk_files, widget.to, "Apk files", progressNotifier, is_delete);

            Navigator.pop(context);
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Files ${is_delete ? "deleted" : "transferred"} successfully!')),
            );
          } catch (e) {
            Navigator.pop(context); // Close the progress dialog

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error transferring files: $e')),
            );
          }
        }
      },
    );
  }



  Widget _buildTotalSelectedFilesSize() {
    int totalSize = 0;
    for (var file in videos_files) {
      totalSize += file.lengthSync();
    }
    for (var file in images_files) {
      totalSize += file.lengthSync();
    }
    for (var file in audios_files) {
      totalSize += file.lengthSync();
    }
    for (var file in pdf_files) {
      totalSize += file.lengthSync();
    }
    for (var file in apk_files) {
      totalSize += file.lengthSync();
    }

    return Text(
      'Total Selected Files Size: ${_formatBytes(totalSize)}',
      style: TextStyle(color: Colors.white),
    );
  }

  Widget on_off_button(double sc_w,double sc_h){
    return GestureDetector(
      onTap: toggleButton,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: isOn ? Colors.green : Colors.grey,
        ),
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              left: isOn ? 30.0 : 0.0,
              right: isOn ? 0.0 : 30.0,
              child: Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

