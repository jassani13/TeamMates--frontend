import 'package:base_code/package/screen_packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  void connect() {
    socket = io.io('http://3.84.37.74:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();
    if (kDebugMode) {
      print(socket.connected);
    }

  }



  void disconnect() {
    socket.disconnect();
  }
}
