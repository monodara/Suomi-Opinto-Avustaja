import 'package:flutter/material.dart';

class AuroraGradient {
  // 极光渐变色 (更暗的色调)
  static const List<Color> auroraColors = [
    Color(0xFF0A2463), // 深蓝色
    Color(0xFF3E0A65), // 深紫色
    Color(0xFF2E8B57), // 深绿色
    Color(0xFF006400), // 深绿色
    Color(0xFF8B008B), // 深紫色
  ];

  // 创建极光渐变
  static LinearGradient createAuroraGradient() {
    return LinearGradient(
      begin: Alignment(-1.0, -1.0), // 从左上角开始
      end: Alignment(1.0, 1.0),    // 到右下角结束
      colors: auroraColors,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );
  }

  // 创建极光渐变的AppBar
  static PreferredSizeWidget createAuroraAppBar({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: createAuroraGradient(),
        ),
      ),
      actions: actions,
    );
  }
}