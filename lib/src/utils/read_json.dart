import 'package:flutter/services.dart';
import 'dart:convert';


Future<dynamic> readJson(String path) async {
    final String fileContents = await rootBundle.loadString(path);
    final data = await json.decode(fileContents);
    return data;
  }