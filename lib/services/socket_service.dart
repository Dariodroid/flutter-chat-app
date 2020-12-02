import 'package:chat/global/enviroment.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

//estas son propiedades publicas
  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this.socket.emit;

  void connect() async {
    final token = await AuthService.getToken();

    this._socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoconnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': token}
    });
    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    //socket.on('nuevo-mensaje', (payload) {
    //  print('nuevo-mensaje: ');
    //  print('nombre:' + payload['nombre']);
    //  print('mensaje:' + payload['mensaje']);
    //});
  }

  void disconnect() {
    this._socket.disconnect();
  }
}
