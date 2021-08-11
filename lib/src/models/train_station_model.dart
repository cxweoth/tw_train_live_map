class TrainStationModel {

  late String _updatetime;
  late String _srcUpdatetime;

  late List<_Station> _stations = [];

  TrainStationModel.fromJson(Map<String, dynamic> parsedJson) {
    
    _updatetime = parsedJson["UpdateTime"];
    _srcUpdatetime = parsedJson["SrcUpdateTime"];

    List<_Station> temp = [];
    for (int i = 0; i < parsedJson["Stations"].length; i++) {
      _Station station = _Station(parsedJson["Stations"][i]);
      temp.add(station);
    }
    _stations = temp;
  }

  String get updatetime => _updatetime;
  String get srcUpdatetime => _srcUpdatetime;
  List<_Station> get stations => _stations;

}

class _Station {

  late String _stationUID;
  late String _stationID;
  late Map<String, String> _stationName;
  late Map<String, double> _stationPosition;
  late String _stationAddress;
  late String _stationPhone;
  late String _stationClass;
  late String _stationURL;

  _Station(station) {
    
    _stationUID = station["StationUID"];
    _stationID = station["StationID"];

    _stationName = {};
     for (String key in station['StationName'].keys){
      _stationName[key] = station['StationName'][key];
    }

    _stationPosition = {};
     for (String key in station['StationPosition'].keys){
      _stationPosition[key] = station['StationPosition'][key];
    }

    _stationAddress = station["StationAddress"];
    _stationPhone = station["StationPhone"];
    _stationClass = station["StationClass"];
    _stationURL = station["StationURL"];
  }

  String get stationUID => _stationUID;
  String get stationID => _stationID;
  Map<String, String> get stationName => _stationName;
  Map<String, double> get stationPosition => _stationPosition;
  String get stationAddress => _stationAddress;
  String get stationPhone => _stationPhone;
  String get stationClass => _stationClass;
  String get stationURL => _stationURL;

}
