
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SimpleAnimGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // 加载所有帧图
    final frames = <Sprite>[];
    for (int i = 0; i < 10; i++) { // 0 ~ 12 共 13 帧
      final fileName = 'fish/Group_152_${i.toString().padLeft(5, '0')}.png';
      final image = await images.load(fileName);
      frames.add(Sprite(image));
    }

    // 用这些帧生成动画
    final animation = SpriteAnimation.spriteList(
      frames,
      stepTime: 0.1, // 每帧 0.1 秒
      loop: true,    // 是否循环播放
    );

    // 显示到屏幕上
    final animComp = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(200),   // 显示大小
      position: size / 2,       // 居中
      anchor: Anchor.center,
    );

    add(animComp);
  }
}