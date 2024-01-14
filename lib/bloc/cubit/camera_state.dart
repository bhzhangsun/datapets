part of 'camera_cubit.dart';

@immutable
sealed class CameraState {}

final class CameraInstance extends CameraState {
  final CameraDescription? camera;

  CameraInstance([this.camera]);
}
