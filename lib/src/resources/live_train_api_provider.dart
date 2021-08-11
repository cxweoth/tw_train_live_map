import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:tw_train_live_map/src/models/live_train_model.dart';
import 'package:tw_train_live_map/src/.secrets/secrets.dart';

import 'package:intl/intl.dart' as intl;
import 'package:crypto/crypto.dart';

import 'dart:developer' as developer;


class LiveTrainAPIProvider {
  
  HttpClient httpClient = new HttpClient();
  String appID = Secrets.PTX_APP_ID;
  String appKey = Secrets.PTX_APP_KEY;
  String url = "https://ptx.transportdata.tw/MOTC/v2/Rail/TRA/LiveBoard?\$format=JSON";

  Future<LiveTrainModel> fetchLiveTrainData() async {
    
    // Prepare auth header
    final String time = readTimestamp(DateTime.now().millisecondsSinceEpoch);
    final signDate = "x-date: $time";

    var key = utf8.encode(appKey);
    var hmacSha1 = new Hmac(sha1, key);
    var hmac = hmacSha1.convert(utf8.encode(signDate));
    var base64HmacString = Base64Encoder().convert(hmac.bytes);

    // Do request
    var request = await httpClient.getUrl(Uri.parse(url));
    request.headers.add("x-date", time);
    request.headers.add("Authorization", '"hmac username="$appID", algorithm="hmac-sha1", headers="x-date", signature="$base64HmacString"');
    var response = await request.close();
    
    developer.log(response.statusCode.toString());
    if (response.statusCode == HttpStatus.ok) {
      var jsonString = await response.transform(utf8.decoder).join();
      final data = await json.decode(jsonString);
      return LiveTrainModel.fromJson(data);
    } else {
      throw Exception('Failed to load live train data');
    }
  }

  String readTimestamp(int timestamp){
    var format = new intl.DateFormat("EEE, dd MMM yyyy HH:mm:ss");
    var time = format.format(DateTime.now().toUtc()) + " GMT";

    return time.toString();
  }

}