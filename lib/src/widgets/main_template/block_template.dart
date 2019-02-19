import 'package:flutter/material.dart';
import '../image_block.dart';
import '../text_block.dart';

enum BlockType { image, text, custom }

class BlockModel {
  final BlockType type;
  final String imageName;
  final String title;
  final List<String> content;
  final Widget customChild;

  BlockModel({this.type, this.imageName, this.title, this.content, this.customChild});
}

class BlockTemplate extends StatelessWidget {
  final BlockModel block;

  BlockTemplate({this.block});

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case BlockType.image:
        return ImageBlock(
          imageName: block.imageName,
        );
      case BlockType.text:
        return TextBlock(
          title: block.title,
          content: block.content,
        );
      case BlockType.custom:
        return block.customChild;
      default:
        return null;
    }
  }
}
