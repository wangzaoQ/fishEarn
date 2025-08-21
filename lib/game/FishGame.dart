import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';

import 'FishComponent.dart';

class FishGame extends FlameGame with TapCallbacks {
  late final FishComponent fish;

  @override
  Color backgroundColor() => const Color(0xFF0D2338);

  @override
  Future<void> onLoad() async {
    await images.load('ic_game2_large.webp');

    fish = FishComponent(
      spriteImage: images.fromCache('ic_game2_large.webp'),
    );
    await add(fish);

    add(FpsTextComponent(
      position: Vector2(8, 8),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(color: Color(0x99FFFFFF)),
      ),
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    fish.dashTo(event.canvasPosition);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = FishGame();
  runApp(GameWidget(game: game));
}