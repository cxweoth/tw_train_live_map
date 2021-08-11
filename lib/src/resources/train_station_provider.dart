import 'dart:async';

import 'package:map_live_train/src/models/train_station_model.dart';
import 'package:map_live_train/src/utils/read_json.dart';

import 'dart:developer' as developer;


class TrainStationProvider {

  Future<TrainStationModel> fetchTrainStationData() async {

    try {
      var data = await readJson('assets/train_data/train_station.json');
      return TrainStationModel.fromJson(data);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}