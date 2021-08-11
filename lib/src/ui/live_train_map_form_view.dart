import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tw_train_live_map/src/blocs/live_train_map_bloc/live_train_map_bloc.dart';
import 'package:tw_train_live_map/src/blocs/live_train_map_bloc/live_train_map_event.dart';
import 'package:tw_train_live_map/src/blocs/live_train_map_bloc/train_map_state.dart';
import 'package:tw_train_live_map/src/ui/live_train_map_form_status.dart';

class LiveTrainMapView extends StatefulWidget {
  @override
  _LiveTrainMapViewState createState() => _LiveTrainMapViewState();
}

// What is state<MapView>?
class _LiveTrainMapViewState extends State<LiveTrainMapView> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // override function
  @override
  void initState() {

    LiveTrainMapBloc liveTrainMapBloc = BlocProvider.of<LiveTrainMapBloc>(context);
    liveTrainMapBloc.add(InitLiveTrainMap());

    asyncMethod();

    super.initState();
  }

  void asyncMethod() async {    
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {

    // Get height and width
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
        height: height,
        width: width,
        child: _mapForm(),
    );
  }
    
  Widget _mapForm() {
    return Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              _googleMapForm(),
              _curLocationButtonFrom(),
            ],
          )
        );
  }
  
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  Map<PolylineId, Polyline> polylines = {};

  Widget _googleMapForm() {

    return BlocBuilder<LiveTrainMapBloc, TrainMapState>(builder: (context, state){
      
      if (state.liveTrainMapFormStatus is InitLiveTrainMapFormSucceed){
        
        _formInit(context, state);
      }
      
      
      if (state.liveTrainMapFormStatus is RefreshLiveTrainMapFormSucceed){
        _formUpdate(context, state);
      }

      developer.log("triggered: " + state.liveTrainMapFormStatus.toString());

      return GoogleMap(
                markers: Set<Marker>.of(markers.values),
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) async {
                  mapController = controller;
                },
              );
    
    });
  }

  late Position _currentPosition;
  // Init current address
  String _currentAddress = '';
  String _startAddress = '';
  // Address controller
  final startAddressController = TextEditingController();

  Widget _curLocationButtonFrom() {
    return BlocBuilder<LiveTrainMapBloc, TrainMapState>(builder: (context, state) {
      return SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(28.0), side: BorderSide(color: Colors.black45)),
                      color: Colors.white, // button color
                      child: InkWell(
                        splashColor: Colors.blue.shade50, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          context.read<LiveTrainMapBloc>().add(RefreshLiveTrainMap());
                          _getCurrentLocation();
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 13.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  _formInit(context, state) async {
    await _createTrainLine(state);
    await _changeStationMarkers(state);

    LiveTrainMapBloc liveTrainMapBloc = BlocProvider.of<LiveTrainMapBloc>(context);
    liveTrainMapBloc.add(InitLiveTrainMapComplete());
  }

  _formUpdate(context, state) async {
    await _changeStationMarkers(state);

    LiveTrainMapBloc liveTrainMapBloc = BlocProvider.of<LiveTrainMapBloc>(context);
    liveTrainMapBloc.add(RefreshLiveTrainMapComplete());
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 13.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _createTrainLine(state) async {
    
    // List init LatLng is element
    for (var key in state.trainLineCoordinates.keys) { 

      String lineID = key;

      List<LatLng> polylineCoordinates = [];

      if (state.trainLineCoordinates[lineID].isNotEmpty){
        state.trainLineCoordinates[lineID].forEach((List<double> coordinate) {
          double lat = coordinate[0];
          double lon = coordinate[1];
          polylineCoordinates.add(LatLng(lat, lon));
        });
      }

      Polyline polyline = Polyline(
        polylineId: PolylineId(lineID),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
      );

      polylines[PolylineId(lineID)] = polyline;
    }
  }

  _changeStationMarkers(state) async{
    Map<String, Map<int, Map<String, int>>> liveTrainCountAtStation = state.liveTrainCountAtStation;
    Map<String, Map<String, dynamic>> stationLocation = state.trainStationData;
    await _createStationItems(stationLocation, liveTrainCountAtStation);
  }

  _createStationItems(Map<String, Map<String, dynamic>> stationLocation, Map<String, Map<int, Map<String, int>>> liveTrainCountAtStation) async{

    Map<MarkerId, Marker> stationMarkers = {};
    
    for (var stationID in stationLocation.keys){

      String stationName = stationLocation[stationID]!["StationName"]!;
      double positionLat = stationLocation[stationID]!["PositionLat"]!;
      double positionLon = stationLocation[stationID]!["PositionLon"]!;
      // Start Location stationID
      // await _getLiveTrain();
      // ['1: 太魯閣', '2: 普悠瑪', '3: 自強', '4: 莒光', '5: 復興', '6: 區間', '7: 普快', '10: 區間快']
      int clockwise_taipu_total_train = 0;
      int clockwise_tsi_ju_train = 0;
      int clockwise_fu_chi_train = 0;

      int counterClockwise_taipu_total_train = 0;
      int counterClockwise_tsi_ju_train = 0;
      int counterClockwise_fu_chi_train = 0;
      if (liveTrainCountAtStation.containsKey(stationID)){
        Map<int, Map<String, int>>? stationElement = liveTrainCountAtStation[stationID];
        stationElement!.forEach((key, value) { 
          if (key == 0) {

            value.forEach((subkey, subvalue) { 

              if (subkey == '1') {
                clockwise_taipu_total_train += subvalue;
              } else if (subkey == '2'){
                clockwise_taipu_total_train += subvalue;
              } else if (subkey == '3'){
                clockwise_tsi_ju_train += subvalue; 
              } else if (subkey == '4'){
                clockwise_tsi_ju_train += subvalue; 
              } else if (subkey == '5'){
                clockwise_fu_chi_train += subvalue; 
              } else if (subkey == '6'){
                clockwise_fu_chi_train += subvalue; 
              } else if (subkey == '7'){
                clockwise_fu_chi_train += subvalue; 
              } else if (subkey == '10'){
                clockwise_fu_chi_train += subvalue; 
              }

            });

          } else {

            value.forEach((subkey, subvalue) { 
              if (subkey == '1') {
                counterClockwise_taipu_total_train += subvalue;
              } else if (subkey == '2'){
                counterClockwise_taipu_total_train += subvalue;
              } else if (subkey == '3'){
                counterClockwise_tsi_ju_train += subvalue; 
              } else if (subkey == '4'){
                counterClockwise_tsi_ju_train += subvalue; 
              } else if (subkey == '5'){
                counterClockwise_fu_chi_train += subvalue; 
              } else if (subkey == '6'){
                counterClockwise_fu_chi_train += subvalue; 
              } else if (subkey == '7'){
                counterClockwise_fu_chi_train += subvalue; 
              } else if (subkey == '10'){
                counterClockwise_fu_chi_train += subvalue; 
              }

            });

          }
        });
      }
      BitmapDescriptor pinIcon = await _getMarkerIcon("assets/train_data/train_station.png", Size(150.0, 150.0), stationName,
            clockwise_taipu_total_train, clockwise_tsi_ju_train, clockwise_fu_chi_train, counterClockwise_taipu_total_train, counterClockwise_tsi_ju_train, counterClockwise_fu_chi_train);
      
      final Marker stationMarker = Marker(
        markerId: MarkerId(stationID),
        position: LatLng(positionLat, positionLon),
        icon: pinIcon,
      );
      // adding a new marker to map
        stationMarkers[MarkerId(stationID)] = stationMarker;
    }

    setState((){
      markers = stationMarkers;
    });
    
  }

  Future<BitmapDescriptor> _getMarkerIcon(String imagePath, Size size, String stationName, int clockwise_taipu_total_train, int clockwise_tsi_ju_train, int clockwise_fu_chi_train, int counterClockwise_taipu_total_train, int counterClockwise_tsi_ju_train, int counterClockwise_fu_chi_train) async {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      final Radius radius = Radius.circular(size.width / 2);

      final Paint tagPaint = Paint()..color = Colors.blue;
      final Paint counterClockwisePaint = Paint()..color = Colors.lightBlueAccent;
      final double textLineHeight = size.height/16;

      final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
      final double shadowWidth = 15.0;

      final Paint borderPaint = Paint()..color = Colors.white;
      final double borderWidth = 3.0;

      final double imageOffset = shadowWidth + borderWidth;

      canvas.drawRect(Offset(
              0.0,
              0.0
          ) & Size(size.width + 50, size.height), counterClockwisePaint);

      canvas.drawRect(Offset(
              size.width + 50,
              0.0
          ) & Size(size.width + 50, size.height), tagPaint);
      
      

      // Add shadow circle
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
                size.width/2 + 50,
                0.0,
                size.width,
                size.height
            ),
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
          shadowPaint);

      // Add border circle
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
                size.width/2 + 50 + shadowWidth,
                shadowWidth,
                size.width - (shadowWidth * 2),
                size.height - (shadowWidth * 2)
            ),
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          ),
          borderPaint);
      
      // Add tag text
      TextPainter counterTextPainteraa = TextPainter(textDirection: TextDirection.ltr);
      counterTextPainteraa.text = TextSpan(
        text: '逆',
        style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold),
      );

      counterTextPainteraa.layout();
      counterTextPainteraa.paint(
          canvas,
          Offset(
              size.width - 20,
              textLineHeight / 4
          )
      );

      // Add tag text
      TextPainter counterTextPainter = TextPainter(textDirection: TextDirection.ltr);
      counterTextPainter.text = TextSpan(
        text: '太,普: ' + counterClockwise_taipu_total_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.red[900], fontWeight: FontWeight.bold),
      );

      counterTextPainter.layout();
      counterTextPainter.paint(
          canvas,
          Offset(
              15,
              textLineHeight / 2
          )
      );

      // Add tag text2
      TextPainter counterTextPainter2 = TextPainter(textDirection: TextDirection.ltr);
      counterTextPainter2.text = TextSpan(
        text: '自,莒: ' + counterClockwise_tsi_ju_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.yellow[700], fontWeight: FontWeight.bold),
      );

      counterTextPainter2.layout();
      counterTextPainter2.paint(
          canvas,
          Offset(
              15,
              10 * textLineHeight / 2 
          )
      );

      // Add tag text3
      TextPainter counterTextPainter3 = TextPainter(textDirection: TextDirection.ltr);
      counterTextPainter3.text = TextSpan(
        text: '復,區: ' + counterClockwise_fu_chi_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.greenAccent, fontWeight: FontWeight.bold),
      );

      counterTextPainter3.layout();
      counterTextPainter3.paint(
          canvas,
          Offset(
              15,
              19 * textLineHeight / 2
          )
      );
      
      // Add tag text
      TextPainter textPainteraa = TextPainter(textDirection: TextDirection.ltr);
      textPainteraa.text = TextSpan(
        text: '順',
        style: TextStyle(fontSize: 25.0, color: Colors.white, fontWeight: FontWeight.bold),
      );

      textPainteraa.layout();
      textPainteraa.paint(
          canvas,
          Offset(
              50 + size.width + 40,
              textLineHeight / 4
          )
      );

      // Add tag text
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: '太,普: ' + clockwise_taipu_total_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.red[900], fontWeight: FontWeight.bold),
      );

      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              size.width/2 + 50 + size.width,
              textLineHeight / 2
          )
      );

      // Add tag text2
      TextPainter textPainter2 = TextPainter(textDirection: TextDirection.ltr);
      textPainter2.text = TextSpan(
        text: '自,莒: ' + clockwise_tsi_ju_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.yellow[700], fontWeight: FontWeight.bold),
      );

      textPainter2.layout();
      textPainter2.paint(
          canvas,
          Offset(
              size.width/2 + 50 + size.width,
              10 * textLineHeight / 2 
          )
      );

      // Add tag text3
      TextPainter textPainter3 = TextPainter(textDirection: TextDirection.ltr);
      textPainter3.text = TextSpan(
        text: '復,區: ' + clockwise_fu_chi_train.toString(),
        style: TextStyle(fontSize: 30.0, color: Colors.greenAccent, fontWeight: FontWeight.bold),
      );

      textPainter3.layout();
      textPainter3.paint(
          canvas,
          Offset(
              size.width/2 + 50 + size.width,
              19 * textLineHeight / 2
          )
      );

      // Oval for the image
      Rect oval = Rect.fromLTWH(
          size.width/2 + 50 +  imageOffset,
          imageOffset,
          size.width - (imageOffset * 2),
          size.height - (imageOffset * 2)
      );

      // Add station name text
      TextPainter counterTextPainterStationName = TextPainter(textDirection: TextDirection.ltr);
      counterTextPainterStationName.text = TextSpan(
        text: stationName,
        style: TextStyle(fontSize: 25.0, color: Colors.black, fontWeight: FontWeight.bold),
      );

      counterTextPainterStationName.layout();
      counterTextPainterStationName.paint(
          canvas,
          Offset(
              50 + size.width -25,
              size.width - 35
          )
      );

      // Add path for oval image
      canvas.clipPath(Path()
        ..addOval(oval));

      // Add image
      ui.Image image = await _getImageFromPath(imagePath); // Alternatively use your own method to get the image

      

      paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

      

      // Convert canvas to image
      final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
          (3*size.width).toInt()+100,
          size.height.toInt()
      );

      // Convert image to bytes
      final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8List = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(uint8List);
  }

  Future<ui.Image> _getImageFromPath(String imagePath) async {

    ByteData assetImageByteData  = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(assetImageByteData.buffer.asUint8List(), targetWidth: 150);
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    return frameInfo.image;
  }

}