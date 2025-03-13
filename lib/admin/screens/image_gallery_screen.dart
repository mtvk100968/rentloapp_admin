import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageGalleryScreen extends StatelessWidget {
  final List<String> images;

  ImageGalleryScreen({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Gallery"),
      ),
      body: CarouselSlider(
        items: images
            .map((imageUrl) => ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
          ),
        ))
            .toList(),
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: true,
          viewportFraction: 1.0,
        ),
      ),
    );
  }
}
