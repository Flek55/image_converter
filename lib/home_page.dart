import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<XFile> imageList = [];
  final ImagePicker picker = ImagePicker();
  int imageCount = 0;

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
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                _getImageList(),
              ])),
        ));
  }

  _getImageList() {
    return imageList.isNotEmpty
        ? ListView.builder(
      itemCount: imageList.length,
      shrinkWrap: true,
      //scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return Padding(padding: const EdgeInsets.symmetric(
            vertical: 15, horizontal: 10),
          child: Image.file(
            File(imageList[index].path),
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3 * 2 - 30,
          ),);
      },
    )
        : const SizedBox();
  }

  void clearImageList() {
    imageCount = 0;
    imageList = [];
    setState(() {});
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    ///Проверка на не пустоту файла картинки
    if (img != null) {
      imageList.add(img);
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
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 6,
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
                          top: MediaQuery
                              .of(context)
                              .size
                              .height / 32)),
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
