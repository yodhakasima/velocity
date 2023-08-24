import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:velocity/first_location.dart';
import 'package:velocity/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer();
  LocationService locationService = LocationService();
  FirsLocation firstLocation = FirsLocation();

  double distanceImMeter = 0;
  double latitude = 0;
  double longitude = 0;
  double lat = 0;
  double long = 0;
  double jarak = 0;
  double kecepatan = 0;
  double seconds = 0;
  double waktu = 0;
  double speedometer = 0;

  // Duration duration = Duration();
  // late Timer timer;

  GeolocatorPlatform locator = GeolocatorPlatform.instance;
  late StreamController<double?> _velocityUpdatedStreamController;

  double? _velocity;

  @override
  void dispose() {
    locationService.dispose();
    getLocation();
    _velocityUpdatedStreamController.close();
    super.dispose();
  }

  Future<void> getLocation() async {
    final service = FirsLocation();
    final locationData = await service.getLocation();

    if (locationData != null) {
      setState(() {
        lat = locationData.latitude!;
        long = locationData.longitude!;
      });
      locationService.locationStream.listen((userlocation) {
        setState(() {
          latitude = userlocation.latitude;
          longitude = userlocation.longitude;
        });
        distanceImMeter = Geolocator.distanceBetween(
                locationData.latitude!,
                locationData.longitude!,
                userlocation.latitude,
                userlocation.longitude)
            .roundToDouble();

        // if (distanceImMeter == 0) {
        //   kecepatan == 0;
        // } else {
        //   kecepatan = ((distanceImMeter) / duration.inSeconds).roundToDouble();
        // }
        // jarak = distanceImMeter / 1000;
        // if (jarak == 0) {
        //   waktu == 0;
        // } else {
        //   waktu = duration.inSeconds / 3600;
        // }
        // speedometer = (jarak / waktu).roundToDouble();
        // if (speedometer >= 20) {
        //   player.play(AssetSource('iphone_14.mp3'));
        // } else {
        //   player.pause();
        // }
      });
    }
  }

  // void addTime() {
  //   const addSeconds = 1;
  //   setState(() {
  //     final seconds = duration.inSeconds + addSeconds;
  //     duration = Duration(seconds: seconds);
  //   });
  // }

  // void startTimer() {
  //   timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  // }

  @override
  void initState() {
    super.initState();
    _velocityUpdatedStreamController = StreamController<double?>();
    locator
        .getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        )
        .listen(
          (Position position) => _onAccelerate(position.speed),
        );

    _velocity = 0;
    getLocation();
  }

  void _onAccelerate(double speed) {
    locator.getCurrentPosition().then(
      (Position updatedPosition) {
        _velocity = (speed + updatedPosition.speed) / 2;
        _velocityUpdatedStreamController.add(_velocity);
        kecepatan = _velocity! * 18 / 5;
        if (kecepatan >= 40) {
          player.play(AssetSource('iphone_14.mp3'));
        } else {
          player.pause();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final speedNotifier = ValueNotifier<double>(10);
    final key = GlobalKey<KdGaugeViewState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Speedometer"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
              padding: const EdgeInsets.all(10),
              child: ValueListenableBuilder<double>(
                valueListenable: speedNotifier,
                builder: (context, value, child) {
                  return KdGaugeView(
                    key: key,
                    minSpeed: 0,
                    maxSpeed: 100,
                    speed: kecepatan,
                    animate: false,
                    alertSpeedArray: const [40, 80, 90],
                    alertColorArray: const [
                      Colors.orange,
                      Colors.indigo,
                      Colors.red
                    ],
                  );
                },
              ),
            ),
            Text('$_velocity'),
          ],
        ),
      ),
    );
  }
}
