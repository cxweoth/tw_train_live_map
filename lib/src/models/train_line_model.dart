class TrainLineModel {

  late String _updatetime;
  late String _srcUpdatetime;

  late List<_Shape> _shapes = [];

  TrainLineModel.fromJson(Map<String, dynamic> parsedJson) {
    
    _updatetime = parsedJson["UpdateTime"];
    _srcUpdatetime = parsedJson["SrcUpdateTime"];

    List<_Shape> temp = [];
    for (int i = 0; i < parsedJson["Shapes"].length; i++) {
      _Shape shape = _Shape(parsedJson["Shapes"][i]);
      temp.add(shape);
    }
    _shapes = temp;
  }

  String get updatetime => _updatetime;
  String get srcUpdatetime => _srcUpdatetime;
  List<_Shape> get shapes => _shapes;

}

class _Shape {

  late String _lineNo;
  late String _lineID;
  late Map<String, String> _lineName;
  late String _geometry;
  late String _updatetime;

  _Shape(shape) {
    
    _lineNo = shape["LineNo"];
    _lineID = shape["LineID"];

    _lineName = {};
     for (String key in shape['LineName'].keys){
      _lineName[key] = shape['LineName'][key];
    }

    _geometry = shape["Geometry"];
    _updatetime = shape["UpdateTime"];
  }

  String get lineNo => _lineNo;
  String get lineID => _lineID;
  Map<String, String> get lineName => _lineName;
  String get geometry => _geometry;
  String get updatetime => _updatetime;

}
