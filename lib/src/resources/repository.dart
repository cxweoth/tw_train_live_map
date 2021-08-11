import 'dart:async';
import 'package:map_live_train/src/resources/live_train_api_provider.dart';
import 'package:map_live_train/src/resources/train_station_provider.dart';
import 'package:map_live_train/src/resources/train_line_provider.dart';
import 'package:map_live_train/src/models/live_train_model.dart';
import 'package:map_live_train/src/models/train_station_model.dart';
import 'package:map_live_train/src/models/train_line_model.dart';

class Repository {
  final liveTrainAPIProvider = LiveTrainAPIProvider();
  final trainStationProvider = TrainStationProvider();
  final trainLineProvider = TrainLineProvider();

  Future<LiveTrainModel> fetchLiveTrainData() => liveTrainAPIProvider.fetchLiveTrainData();
  Future<TrainStationModel> fetchTrainStationData() => trainStationProvider.fetchTrainStationData();
  Future<TrainLineModel> fetchTrainLineData() => trainLineProvider.fetchTrainLineData();
}