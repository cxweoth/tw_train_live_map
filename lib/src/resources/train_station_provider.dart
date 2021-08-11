import 'dart:async';

import 'package:tw_train_live_map/src/models/train_station_model.dart';
import 'package:tw_train_live_map/src/utils/read_json.dart';

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