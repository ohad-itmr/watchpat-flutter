import 'package:flutter/material.dart';
import '../image_block.dart';
import '../text_block.dart';

enum BlockType { image, text, custom }

class BlockTemplate extends StatelessWidget {
  final BlockType type;
  final String imageName;
  final String title;
  final List<String> content;
  final Widget customChild;
  final Color textColor;
  final bool textTopPadding;
  final Widget additionalTextContent;

  BlockTemplate(
      {this.type,
      this.imageName,
      this.title,
      this.content,
      this.customChild,
      this.textColor,
      this.textTopPadding = false,
      this.additionalTextContent});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case BlockType.image:
        return ImageBlock(
          imageName: imageName,
        );
      case BlockType.text:
        return TextBlock(
          title: title.toUpperCase(),
          content: content,
          textColor: textColor,
          topPadding: textTopPadding,
          additionalContent: additionalTextContent,
        );
      case BlockType.custom:
        return customChild;
      default:
        return Container(height: 0.0, width: 0.0);
    }
  }
}
