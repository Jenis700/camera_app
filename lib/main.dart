import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _selectedFile;
  bool _inProcess = false;

  _asyncFileUpload(String text, File file) async {
    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.29.78:3002/admin/slider"));
    //add text fields
    request.fields["SLIDER_NAME"] = text;
    request.fields["DESCRIPTION"] = text;

    //create multipart using filepath, string or bytes
    var pic =
        await http.MultipartFile.fromPath("FILEUPLOAD", _selectedFile.path);
    //add multipart to request
    request.files.add(pic);
    var response = await request.send();
    print("request :: $request");
    //Get the response from the server
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    // print(responseString);
    return responseString.toString();
  }

  Widget getBodyImage() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 250,
        height: 350,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/default.jpg",
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  getImageOnButton(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ],
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarTitle: "Crop Image",
          statusBarColor: Colors.deepOrange.shade900,
          backgroundColor: Colors.white,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      );

      this.setState(() {
        _selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getBodyImage(),
              SizedBox(height: 5),
              MaterialButton(
                color: Colors.green,
                child: Text(
                  "Camera",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  getImageOnButton(ImageSource.camera);
                },
              ),
              SizedBox(height: 5),
              MaterialButton(
                color: Colors.deepOrange,
                child: Text(
                  "Device",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  getImageOnButton(ImageSource.gallery);
                },
              ),
              SizedBox(height: 5),
              MaterialButton(
                color: Colors.deepOrange,
                child: Text(
                  "Save Image",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_selectedFile != null) {
                    String path = _selectedFile.path;
                    GallerySaver.saveImage(path, albumName: "Jenis Radadiya")
                        .then(
                      (bool success) {
                        setState(
                          () {
                            Fluttertoast.showToast(
                              msg: "Image is saved to gallery",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                        );
                      },
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Sorry, Can't find image",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
              MaterialButton(
                color: Colors.deepOrange,
                child: Text(
                  "Save Api",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  var data =
                      await _asyncFileUpload("Jenis Radadiya", _selectedFile);
                  var nData = json.decode(data);

                  if (nData["status"]) {
                    print("Sucssess");
                    Fluttertoast.showToast(
                      msg: "Image uploded succssesfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    print("sorry you are fail");
                    Fluttertoast.showToast(
                      msg: "Sorry, Can't upload image",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ],
          ),
          _inProcess
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center()
        ],
      ),
    );
  }
}




// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Save image to gallery',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   GlobalKey _globalKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();

//     _requestPermission();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Save image to gallery"),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               RepaintBoundary(
//                 key: _globalKey,
//                 child: Container(
//                   width: 200,
//                   height: 200,
//                   color: Colors.red,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.only(top: 15),
//                 child: RaisedButton(
//                   onPressed: _saveScreen,
//                   child: Text("Save Local Image"),
//                 ),
//                 width: 200,
//                 height: 44,
//               ),
//               Container(
//                 padding: EdgeInsets.only(top: 15),
//                 child: RaisedButton(
//                   onPressed: _getHttp,
//                   child: Text("Save network image"),
//                 ),
//                 width: 200,
//                 height: 44,
//               ),
//             ],
//           ),
//         ));
//   }

//   _requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//     ].request();

//     final info = statuses[Permission.storage].toString();
//     print(info);
//     _toastInfo(info);
//   }

//   _saveScreen() async {
//    
//   }

//   _getHttp() async {
//     var response = await Dio().get(
//         "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg",
//         options: Options(responseType: ResponseType.bytes));
//     final result = await ImageGallerySaver.saveImage(
//         Uint8List.fromList(response.data),
//         quality: 60,
//         name: "hello");
//     print(result);
//     _toastInfo("$result");
//   }

//   _toastInfo(String info) {
//     Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
//   }
// }
