// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fish_earn/main.dart';

void main() {
// 1️⃣ 将字符串转为 UTF8 字节数组
  final bytes = utf8.encode("MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAMYl4KczbxQYcRCOgSH0lzRtfuI/jffXOXpHUXRVm3CRiyNL4M5U0Vy3qC+HO64/a1ZZ2FFcKLG69oOvUkCuMr0CAwEAAQ==");

// 2️⃣ 对每个字节进行 XOR 运算
  List<int> xorList = [];
  for (int i = 0; i < bytes.length; i++) {
    xorList.add(bytes[i] ^ 116);
  }
  var key = base64.encode(xorList);
  print("main:$key");
}

