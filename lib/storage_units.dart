import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_to_sd/display_files/display_files.dart';
import 'package:phone_to_sd/transer_files_folder/transfer_files.dart';

Widget generate_icons(String iconName,BuildContext context) {
  double sc_h=MediaQuery.of(context).size.height;
  double sc_w=MediaQuery.of(context).size.width;
  switch (iconName) {
    case "Image":
      return IconButton(icon:Icon(Icons.image,color: Colors.lightBlueAccent[100],),onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => FileExplorer(fileType: "Image"),));
      },);
    case "Video":
      return IconButton(icon:Icon(Icons.play_circle,color: Colors.tealAccent,),onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => FileExplorer(fileType: "Video"),));
      },);
    case "Audio":
      return IconButton(icon:Icon(Icons.music_note,color:Colors.pinkAccent,),onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => FileExplorer(fileType: "Audio"),));
      },);
    case 'Pdf':
      return TextButton(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (context) => FileExplorer(fileType: "Pdf"),));
        },
        child: Container(
          width: sc_w*0.07,
          height:sc_h*0.04,
          child: Image.asset("local_image/pdf_logo.png"),
        ),
      );
    case 'Apk':
      return IconButton(icon:Icon(Icons.android,color: Colors.green,),onPressed: () {
        Navigator.push(context,MaterialPageRoute(builder: (context) => FileExplorer(fileType: "Apk"),));
      },);
    default:
      return IconButton(onPressed: () => print(""), icon: Icon(Icons.check_box_outline_blank_outlined));
  }
}

int ex_in(String input) {
  final List<String> words;
  if (input.contains(".")) {
    words = input.split('.');
  } else {
    words = input.split(' ');
  }

  for (final word in words) {
    final int? parsedInt = int.tryParse(word);
    if (parsedInt != null) {
      print(parsedInt);
      return parsedInt;
    }
  }

  return 0;
}

Widget storage_units(String storage_type, String storage_used, String capacity, String available,bool is_black) {
  if(capacity.isEmpty||available.isEmpty){
    return Container(child: Expanded(child: Text("please inseart the sd card")),);
  }
  return Expanded(
    child: Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        color:is_black? Colors.grey[850]:Color.fromRGBO(192, 192, 192, 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storage_type,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: is_black?Colors.white:Colors.black,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: calculateSizeRatio(storage_used, capacity),
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$storage_used/$capacity",
                style: TextStyle(color:is_black? Colors.white:Colors.black, fontSize: 10),
              ),
              Flexible(
                child: Text(
                  available,
                  style: TextStyle(color:is_black? Colors.white:Colors.black, fontSize: 10),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
void showNotification(BuildContext context, String message) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context)!.insert(overlayEntry);

  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}


Widget transfer_file(double screenHeight, double screenWidth,BuildContext context,String capacity,bool is_black) {


  return Container(

    decoration: BoxDecoration(
        color:is_black? Color.fromRGBO(198, 198, 198, 0.2):Color.fromRGBO(192, 192, 192, 0.3),
        borderRadius: BorderRadius.circular(20),
      gradient:is_black?null: LinearGradient(
        colors: [Colors.blue, Colors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
              child: image_con(screenWidth, screenHeight, "local_image/phone_to_sd.jpeg"),
            onPressed: (){
                String from= "Internal Storage";
                String to ="SD Card";

                if(capacity.isNotEmpty){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      TransferFiles(from: from,to: to,is_black:is_black),));
                }
                else{
                  showNotification(context, "Please Inseart Sd Card");
                }

            },
          ),

          TextButton(
              child: image_con(screenWidth, screenHeight, "local_image/sd_to_phone.jpeg"),
            onPressed: (){

              String to= "Internal Storage";
              String from ="SD Card";

              if(capacity.isNotEmpty){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    TransferFiles(from: from,to: to,is_black:is_black),));
              }
              else{
                showNotification(context, "Please Inseart Sd Card");
              }

            },
          ),
        ],
      ),
    ),
  );
}

Container image_con(double screenWidth,double screenHeight,String path){
  return Container(
    width: screenWidth * 0.38,
    height: screenHeight * 0.2,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Image.asset(path),
    ),
  );
}

Widget storage_items(String type, int items,BuildContext context) {
  double sc_h=MediaQuery.of(context).size.height;


  return Container(

    margin: EdgeInsets.only(top: sc_h*0.008, bottom: sc_h*0.025),
    child: Column(
      children: [
        generate_icons(type,context),
        const SizedBox(
          height: 2,
        ),
        Text(type),
       const  SizedBox(
          height: 2,
        ),
        Text(
          "$items items",
          style: TextStyle(fontSize: 11,),
        )
      ],
    ),
  );
}

double calculateSizeRatio(String value1, String value2) {
  double size1 = parseFileSize(value1);
  double size2 = parseFileSize(value2);

  if (size2 != 0) {
    return size1 / size2;
  } else {
    throw Exception("Division by zero error: value2 cannot be zero.");
  }
}

double parseFileSize(String fileSize) {
  String size = fileSize.replaceAll(RegExp(r'[^\d\.]'), ''); // Remove non-numeric characters except dot (.)
  double value = double.parse(size);

  if (fileSize.contains('KB')) {
    return value * 1024; // Convert KB to bytes
  } else if (fileSize.contains('MB')) {
    return value * 1024 * 1024; // Convert MB to bytes
  } else if (fileSize.contains('GB')) {
    return value * 1024 * 1024 * 1024; // Convert GB to bytes
  } else if (fileSize.contains('TB')) {
    return value * 1024 * 1024 * 1024 * 1024; // Convert TB to bytes
  } else {
    return value; // Assume it's already in bytes or an unsupported format
  }
}

