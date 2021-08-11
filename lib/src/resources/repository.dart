import 'dart:async';
import 'package:tw_train_live_map/src/resources/live_train_api_provider.dart';
import 'package:tw_train_live_map/src/resources/train_station_provider.dart';
import 'package:tw_train_live_map/src/resources/train_line_provider.dart';
import 'package:tw_train_live_map/src/models/live_train_model.dart';
import 'package:tw_train_live_map/src/models/train_station_model.dart';
import 'package:tw_train_live_map/src/models/train_line_model.dart';

class Repository {
  final liveTrainAPIProvider = LiveTrainAPIProvider();
  final trainStationProvider = TrainStationProvider();
  final trainLineProvider = TrainLineProvider();

  Future<LiveTrainModel> fetchLiveTrainData() => liveTrainAPIProvider.fetchLiveTrainData();
  Future<TrainStationModel> fetchTrainStationData() => trainStationProvider.fetchTrainStationData();
  Future<TrainLineModel> fetchTrainLineData() => trainLineProvider.fetchTrainLineData();
}