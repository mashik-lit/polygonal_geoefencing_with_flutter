import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key key,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // The GoogleMap widget takes polygons and markes as Sets
  // We will initialise them in the initState method
  Set<Polygon> _polygons;
  Set<Marker> _markers;

  //List of LatLng of the predefined Polygonal Geofence
  List<LatLng> _polygonLatLngs = [
    LatLng(11.322563198326742, 76.06662310424302),
    LatLng(11.202174997355202, 76.75233714253355),
    LatLng(11.691330136452075, 76.83315187467097),
    LatLng(11.807468550291839, 76.29067848883614),
    LatLng(11.89612240675035, 75.95148613519409),
  ];

  // String to display inside/outside
  String _message = '';

  // LatLng of the initial marker on the map
  final _firstPoint = LatLng(
    11.254193,
    75.838601,
  );

  @override
  void initState() {
    super.initState();

    _polygons.add(
      Polygon(
        polygonId: PolygonId('SCV754S'),
        points: _polygonLatLngs,
        strokeWidth: 2,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.5),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('GS74AGH'),
        position: _firstPoint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _firstPoint,
              zoom: 8.0,
            ),
            mapType: MapType.hybrid,
            polygons: _polygons,
            markers: _markers,
            onTap: (tap) {
              _updateMarker(tap);
              _checkIfInsideOrOutside(tap);
            },
          ),
          if (_message.isNotEmpty)
            Positioned(
              top: 50.0,
              left: 10.0,
              child: Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Text(
                  _message.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.redAccent,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _updateMarker(LatLng tap) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId('GS74AGH'),
        position: tap,
      ),
    );
  }

  ///https://stackoverflow.com/questions/61943711/google-maps-flutter-check-if-a-point-inside-a-polygon
  ///https://www.geeksforgeeks.org/how-to-check-if-a-given-point-lies-inside-a-polygon/#
  ///http://www.dcs.gla.ac.uk/~pat/52233/slides/Geometry1x1.pdf
  void _checkIfInsideOrOutside(LatLng tap) {
    int intersectCount = 0;
    for (int j = 0; j < _polygonLatLngs.length - 1; j++) {
      if (rayCastIntersect(tap, _polygonLatLngs[j], _polygonLatLngs[j + 1])) {
        intersectCount++;
      }
    }

    _message = (intersectCount % 2) == 1 ? 'inside' : 'outside';

    setState(() {});
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }
}

// LatLng(12.259681350568833, 75.57215753202676),
// LatLng(12.964006766932682, 75.9604558331788),
// LatLng(13.185867347822871, 76.48108214723081),
// LatLng(11.602623667013253, 75.88474628317219),
