import 'package:datapets/page/home_page.dart';
import 'package:datapets/widget/pet_zone.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

class PlayPage extends StatelessWidget {
  Future<CameraDescription> _getCameraDescriptionFuture() async {
    final cameras = await availableCameras();
    return cameras.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('PlayPage'),
          leading: IconButton(
              icon: Icon(Icons.backup),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext _context) =>
                      MyHomePage(title: 'HomePage')))),
        ),
        body: FutureBuilder<void>(
            future: _getCameraDescriptionFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final _camera = snapshot.data as CameraDescription;
                return PetZone(camera: _camera);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
