import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:image_picker/image_picker.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<XFile> imageList = [];
  List<String> imagePathList = [];
  final ImagePicker picker = ImagePicker();
  int imageCount = 0;
  String? codeDialog;
  String? valueText;
  bool fileNameInputted = false;
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("File converter"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                const Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => chooseFilePopUp(),
                        child: const Text("Upload")),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    TextButton(
                        onPressed: () => clearImageList(),
                        child: const Text("Reset")),
                    TextButton(
                        onPressed: () => _generatePDF(),
                        child: const Text("Generate"))
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                _getImageColumn(),
              ])),
        ));
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('FileName'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration:
              const InputDecoration(hintText: "Input"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    fileNameInputted = false;
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    fileNameInputted = true;
                    codeDialog = valueText;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  _getImageColumn() {
    return Column(
      children: [
        for (XFile img in imageList)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Image.file(
              File(img.path),
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3 * 2 - 30,
            ),
          )
      ],
    );
  }

  _generatePDF() async {
    if ((imageList.isNotEmpty) && (await Permission.storage.request().isGranted ||
        await Permission.storage.isGranted) ) {
      List<String>? pdfsPaths;
      pdfsPaths = await PdfManipulator().imagesToPdfs(
          params: ImagesToPDFsParams(
        imagesPaths: imagePathList,
        createSinglePdf: false,
      ));
      String? mergedPdfPath = pdfsPaths?[0];
      if (imageList.length > 1) {
        mergedPdfPath = await PdfManipulator().mergePDFs(
          params: PDFMergerParams(pdfsPaths: pdfsPaths!),
        );
      }
      File tmp = File(mergedPdfPath!);
      await _dialog();
      if (fileNameInputted) await saveFile(tmp);
    }
  }

  _dialog() async{
    await _displayTextInputDialog(context);
  }

  Future<void> saveFile(File file) async {
    if (!await FlutterFileDialog.isPickDirectorySupported()) {
      return;
    }

    final pickedDirectory = await FlutterFileDialog.pickDirectory();

    if (pickedDirectory != null) {
      await FlutterFileDialog.saveFileToDirectory(
        directory: pickedDirectory,
        data: file.readAsBytesSync(),
        mimeType: "image/pdf",
        fileName: "${_textFieldController.text.trim()}.pdf",
        replace: true,
      );
    }
  }

  void clearImageList() {
    imageCount = 0;
    imageList = [];
    imagePathList = [];
    _textFieldController.text = "";
    fileNameInputted = false;
    setState(() {});
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    if (img != null) {
      imageList.add(img);
      imagePathList.add(img.path);
      setState(() {});
    }
  }

  void chooseFilePopUp() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: const Text('Выберите способ ввода'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    ///Из галереи
                    onPressed: () async {
                      Navigator.pop(context);
                      await getImage(ImageSource.gallery);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.image),
                        Text('Из галереи'),
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 32)),
                  ElevatedButton(
                    ///Из камеры
                    onPressed: () async {
                      Navigator.pop(context);
                      await getImage(ImageSource.camera);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.camera),
                        Text('Сделать фото'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
