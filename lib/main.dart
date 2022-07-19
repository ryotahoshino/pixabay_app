import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {

  List<PixabayImage> pixabayImages = [];

  Future<void> fetchImages(String text) async{
    final Response response = await Dio().get(
        'https://pixabay.com/api/?key=28579411-bb08d4dd51f7fa28a8d7da894&q=$text&image_type=photo&per_page=100'
    );
    final List hits = response.data['hits'];
    pixabayImages = hits.map(
          (e) {
            return PixabayImage.fromMap(e);
          },).toList();
    setState(() {});
  }

  Future<void> shareImage(String url) async{
    final Response response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}' + '/image.png').writeAsBytes(response.data);

    Share.shareFiles([file.path]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('月');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '月',
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text){
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: pixabayImages.length,
          itemBuilder: (context, index){
            final pixabayImage = pixabayImages[index];
            return InkWell(
              onTap: () async{
                shareImage(pixabayImage.webformatURL);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                      pixabayImage.previewURL,
                      fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 14,
                            ),
                            Text('${pixabayImage.likes}'),
                          ],
                        )),
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}

class PixabayImage {
  final String webformatURL;
  final String previewURL;
  final int likes;

  PixabayImage({
    required this.webformatURL,
    required this.previewURL,
    required this.likes,
  });

  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
        webformatURL: map['webformatURL'] ,
        previewURL: map['previewURL'] ,
        likes: map['likes'],
    );
  }
}