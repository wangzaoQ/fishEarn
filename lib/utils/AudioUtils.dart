import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fish_earn/config/LocalCacheConfig.dart';
import 'package:fish_earn/utils/LocalCacheUtils.dart';

import '../utils/LogUtils.dart';

class AudioUtils {
  // 单例实例
  static final AudioUtils _instance = AudioUtils._internal();

  factory AudioUtils() => _instance;

  AudioUtils._internal();

  // 背景音乐播放器
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // 音效播放器池，避免音效重叠被打断
  final List<AudioPlayer> playerQueue = [];
  final int _maxSfxPlayers = 1;

  bool _bgmPlaying = false;

  Future<void> initTempQueue() async {
    // 初始化音效播放器池
    if (playerQueue.isEmpty) {
      for (int i = 0; i < _maxSfxPlayers; i++) {
        var audioPlayer = AudioPlayer();
        await audioPlayer.setPlayerMode(PlayerMode.lowLatency);
        await audioPlayer.setReleaseMode(ReleaseMode.stop);
        audioPlayer.setAudioContext(
            AudioContext(
              android: AudioContextAndroid(
                isSpeakerphoneOn: true,
                stayAwake: false,
                contentType: AndroidContentType.music,
                usageType: AndroidUsageType.game, // 或 media
                audioFocus: AndroidAudioFocus.none, // ✅ 不抢焦点
              )
            ));
        playerQueue.add(audioPlayer);
      }
    }
  }

  /// 播放背景音乐，循环播放
  Future<void> playBGM(String assetPath, {double volume = 1.0}) async {
    if(_bgmPlayer.state == PlayerState.stopped){
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(volume);
      await _bgmPlayer.play(AssetSource(assetPath));
    }else if(_bgmPlayer.state == PlayerState.paused){
      await _bgmPlayer.resume();
    }
    _bgmPlaying = true;
  }

  /// 暂停背景音乐
  Future<void> pauseBGM() async {
    if (_bgmPlaying) {
      await _bgmPlayer.pause();
      _bgmPlaying = false;
    }
  }

  /// 恢复背景音乐
  Future<void> resumeBGM() async {
    if (!_bgmPlaying) {
      await _bgmPlayer.resume();
      _bgmPlaying = true;
    }
  }

  /// 停止背景音乐
  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
    _bgmPlaying = false;
  }

  Future<void> playClickAudio()async{
    playTempAudio("audio/click.mp3");
  }

  /// 播放音效，自动寻找空闲播放器（带错误处理）
  Future<void> playTempAudio(String assetPath, {double volume = 1.0}) async {
    var allowTempAudioKey = LocalCacheUtils.getBool(
      LocalCacheConfig.allowTempAudioKey,
      defaultValue: true,
    );
    if (!allowTempAudioKey) return;

    try {
      for (final player in playerQueue) {
        if (player.state != PlayerState.playing) {
          try {
            await player.setVolume(volume);
            await player.play(AssetSource(assetPath));
          } catch (e, st) {
            //播放音效失败(空闲 player)
            LogUtils.logE("play error (空闲 player)：$e\n$st");
          }
          return;
        }
      }

      // 如果都在播放，强制复用第一个
      try {
        await playerQueue.first.stop();
      } catch (e, st) {
        //停止旧音效失败
        LogUtils.logE("stop error：$e\n$st");
      }

      try {
        await playerQueue.first.setVolume(volume);
        await playerQueue.first.play(AssetSource(assetPath));
      } catch (e, st) {
        //播放音效失败(复用第一个)
        LogUtils.logE("play error(start first)：$e\n$st");
      }
    } catch (e, st) {
      //playSFX 未知错误
      LogUtils.logE(" playSFX error：$e\n$st");
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    for (final player in playerQueue) {
      await player.dispose();
    }
  }
  /// 释放资源
  Future<void> disposeBgm() async {
    await _bgmPlayer.dispose();
  }
}
