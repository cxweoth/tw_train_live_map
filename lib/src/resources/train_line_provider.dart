import 'dart:async';

import 'package:tw_train_live_map/src/models/train_line_model.dart';
import 'package:tw_train_live_map/src/utils/read_json.dart';

import 'dart:developer' as developer;


class TrainLineProvider {

  Future<TrainLineModel> fetchTrainLineData() async {

    try {
      var data = await readJson('assets/train_data/train_line.json');
      return TrainLineModel.fromJson(data);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

}