import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:meta/meta.dart';

part 'camera_state.dart';

class CameraCubit extends Cubit<CameraInstance> {
  CameraCubit() : super(CameraInstance());

  initialize() async {
    final cameras = await availableCameras();
    emit(CameraInstance(cameras.first));
  }
}
