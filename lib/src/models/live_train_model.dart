import 'dart:developer' as developer;

class LiveTrainModel {

  late List<_Result> _results = [];

  LiveTrainModel.fromJson(List<dynamic> parsedJson) {
    List<_Result> temp = [];
    for (int i = 0; i < parsedJson.length; i++) {
      _Result result = _Result(parsedJson[i]);
      temp.add(result);
    }
    _results = temp;
  }

  List<_Result> get results => _results;
}

class _Result {

  late String _stationID;
  late Map<String, String> _stationName;
  late String _trainNo;
  late int _direction;
  late String _trainTypeID;
  late String _trainTypeCode;
  late Map<String, String> _trainTypeName;
  late int _tripLine;
  late String _endingStationID;
  late Map<String, String> _endingStationName; 
  late String _scheduledArrivalTime;
  late String  _scheduledDepartureTime;
  late int  _delayTime;
  late String  _srcUpdateTime;
  late String  _updateTime;

  _Result(result) {

    _stationID = result['StationID'];
    
    _stationName = {};
    for (String key in result['StationName'].keys){
      _stationName[key] = result['StationName'][key];
    }

    _trainNo = result['TrainNo'];
    _direction = result['Direction'];
    _trainTypeID = result['TrainTypeID'];
    _trainTypeCode = result['TrainTypeCode'];

    _trainTypeName = {};
    for (String key in result['TrainTypeName'].keys){
      _trainTypeName[key] = result['TrainTypeName'][key];
    }

    _tripLine = result['TripLine'];
    _endingStationID = result['EndingStationID'];

    _endingStationName = {};
    for (String key in result['EndingStationName'].keys){
      _endingStationName[key] = result['EndingStationName'][key];
    }

    _scheduledArrivalTime = result['ScheduledArrivalTime'];
    _scheduledDepartureTime = result['ScheduledDepartureTime'];
    _delayTime = result['DelayTime']; // mins
    _srcUpdateTime = result['SrcUpdateTime'];
    _updateTime = result['UpdateTime'];
   
  }

  String get stationID => _stationID;

  Map<String, String> get stationName => _stationName;
  String get trainNo => _trainNo;
  int get direction => _direction;
  String get trainTypeID => _trainTypeID;
  String get trainTypeCode => _trainTypeCode;
  Map<String, String> get trainTypeName => _trainTypeName;
  int get tripLine => _tripLine;
  String get endingStationID => _endingStationID;
  Map<String, String> get endingStationName => _endingStationName; 
  String get scheduledArrivalTime => _scheduledArrivalTime;
  String get scheduledDepartureTime => _scheduledDepartureTime;
  int get  delayTime => _delayTime;
  String get srcUpdateTime => _srcUpdateTime;
  String get updateTime => _updateTime;
}