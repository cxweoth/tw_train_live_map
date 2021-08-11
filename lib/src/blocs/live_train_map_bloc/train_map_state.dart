
import 'package:tw_train_live_map/src/models/live_train_model.dart';
import 'package:tw_train_live_map/src/models/train_line_model.dart';
import 'package:tw_train_live_map/src/models/train_station_model.dart';
import 'package:tw_train_live_map/src/ui/live_train_map_form_status.dart';
import 'dart:developer' as developer;

class TrainMapState {

  Map<String, Map<String, dynamic>> _trainStationData = {};
  Map<String, Map<String, dynamic>> get trainStationData => _trainStationData;

  Map<String, List<List<double>>> _trainLineCoordinates = {};
  Map<String, List<List<double>>> get trainLineCoordinates => this._trainLineCoordinates;

  Map<String, Map<int, Map<String, int>>> _liveTrainCountAtStation = {};
  Map<String, Map<int, Map<String, int>>> get liveTrainCountAtStation => this._liveTrainCountAtStation;

  late LiveTrainMapFormStatus _liveTrainMapFormStatus;
  LiveTrainMapFormStatus get liveTrainMapFormStatus => this._liveTrainMapFormStatus;

  TrainMapState() {
    _liveTrainMapFormStatus = InitialLiveTrainMapForm();
  }
  
  formInit() {
    _liveTrainMapFormStatus = InitLiveTrainMapFormInit();
  }

  formInitSucceed(TrainStationModel trainStationModel, TrainLineModel trainLineModel) {
    
    for (var element in trainStationModel.stations) {

      String stationName = element.stationName["Zh_tw"]!;
      String stationID = element.stationID;
      double positionLon = element.stationPosition["PositionLon"]!;
      double positionLat = element.stationPosition["PositionLat"]!;

      _trainStationData[stationID] = {
        "StationName": stationName,
        "PositionLon": positionLon,
        "PositionLat": positionLat,
      };
    }

    for (var element in trainLineModel.shapes) {

      String lineID = element.lineID;
      String trainLineGeo = element.geometry;

      if (!trainLineGeo.contains('MULTILINESTRING')){

        List<List<double>> coordinates = [];

        trainLineGeo = trainLineGeo.replaceAll("LINESTRING ", "");
        trainLineGeo = trainLineGeo.substring(1, trainLineGeo.length-1);

        List<String> trainLineStringAray = trainLineGeo.split(", ");

        if (trainLineStringAray.isNotEmpty) {

          trainLineStringAray.forEach((String position) {

            List<double> coordinate = [];

            List<String> positionArray = position.split(" ");

            var lat = double.parse('${positionArray[1]}');
            var lon = double.parse('${positionArray[0]}');

            coordinate.add(lat);
            coordinate.add(lon);

            coordinates.add(coordinate);
          });

        } 

        _trainLineCoordinates[lineID] = coordinates;

      } else {
        trainLineGeo = trainLineGeo.replaceAll("MULTILINESTRING ", "");
        trainLineGeo = trainLineGeo.substring(1, trainLineGeo.length-2);

        List<String> trainMultiLineArray = trainLineGeo.split("), ");

        if (trainMultiLineArray.isNotEmpty) {

          int multiLineIndex = 0;

          trainMultiLineArray.forEach((String subLine) {
            
            multiLineIndex += 1;

            String subID = lineID + multiLineIndex.toString();
            List<List<double>> coordinates = [];

            subLine = subLine.substring(1, subLine.length);
            List<String>subLineArray = subLine.split(", ");

            if (subLineArray.isNotEmpty) {
                subLineArray.forEach((String position) {
                  List<double> coordinate = [];
                  
                  List<String> positionArray = position.split(" ");
                  
                  var lat = double.parse('${positionArray[1]}');
                  var lon = double.parse('${positionArray[0]}');

                  coordinate.add(lat);
                  coordinate.add(lon);

                  coordinates.add(coordinate);
                });
            }

            _trainLineCoordinates[subID] = coordinates;
          });
        }
      }
    }

    _liveTrainMapFormStatus = InitLiveTrainMapFormSucceed();
  }

  formInitFailed(Exception exception) {
    _liveTrainMapFormStatus = InitLiveTrainMapFormFailed(exception);
  }

  formInitComplete() {
    _liveTrainMapFormStatus = InitLiveTrainMapFormComplete();
  }

  formRefresh() {
    _liveTrainMapFormStatus = RefreshLiveTrainMapFormRefreshing();
  }

  formRefreshSucceed(LiveTrainModel liveTrainModel) {


    // 這邊要改 要改成對的 return 直

    Map<String, Map<int, Map<String, int>>> temp = {};
    if (liveTrainModel.results.isNotEmpty) {
      liveTrainModel.results.forEach((element) {

        var stationID = element.stationID;
        int direction = element.direction;

        if (!temp.containsKey(stationID)) {
          temp[stationID] = {};
        }

        if (!temp.containsKey(direction)) {
          temp[stationID]![direction] = {};
        }

        var trainTypeCode = element.trainTypeCode;

        if (!temp[stationID]![direction]!.containsKey(trainTypeCode)) {
          temp[stationID]![direction]![trainTypeCode] = 0;
        }

        temp[stationID]![direction]![trainTypeCode] = temp[stationID]![direction]![trainTypeCode]! + 1;

      });
    }

    _liveTrainCountAtStation = temp;

    _liveTrainMapFormStatus = RefreshLiveTrainMapFormSucceed();
  }

  formRefreshFailed(Exception exception) {
    _liveTrainMapFormStatus = RefreshLiveTrainMapFormFailed(exception);
  }

  formRefreshComplete() {
    _liveTrainMapFormStatus = RefreshLiveTrainMapFormComplete();
  }
}

