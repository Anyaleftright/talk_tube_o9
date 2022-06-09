import 'package:flutter/material.dart';
import 'package:talk_tube_o9/config/setting.dart';

import '../widgets/widget.dart';

class ExtendImage extends StatelessWidget {
  final String imageUrl;

  const ExtendImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: imageUrl == null
            ? const isLoading()
            : InteractiveViewer(child: Image.network(imageUrl)),
      ),
    );
  }
}
