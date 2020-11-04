library an101d_decoder;

import 'dart:convert';

import 'dart:typed_data';

class AN101D {
  String base64_data;

  final _FRAME = {
    'CALIBRATION': 0x07 << 4,
    'HEARTBEAT': 0x08 << 4,
    'STATUS': 0x0a << 4,
    'ERROR': 0x09 << 4,
  };

  var data = {};

  AN101D(this.base64_data) {
// String encoded = stringToBase64.encode(credentials);      // dXNlcm5hbWU6cGFzc3dvcmQ=
    try {
      final frames = base64.decode(base64_data);
      _check(frames);
    } on FormatException {
      _set_error(
          'Base64 format error', 'The string is not base64 ascii formated');
    }
  }

  bool _is_frame(int compareA, int compareB) {
    return (compareA & 0xF0) == compareB;
  }

  void _check(Uint8List frames) {
    if (_is_frame(_FRAME['CALIBRATION'], frames[0])) {
      print('Calibration Frame');
      _calibration(frames);
      // this._calibration(frames);
    } else if (_is_frame(_FRAME['HEARTBEAT'], frames[0])) {
      print('Heartbeat Frame');
      _heart_beat(frames);
      // this._calibration(frames);
    } else if (_is_frame(_FRAME['STATUS'], frames[0])) {
      print('Status Frame');
      _status_change(frames);
      // this._calibration(frames);
    } else if (_is_frame(_FRAME['ERROR'], frames[0])) {
      print('Error Frame');
      _error(frames);
      // this._calibration(frames);
    } else {
      this._set_error(
          'Type error', 'Data is not recognizable for Parking sensor AN101D');
    }
  }

  void _calibration(frames) {
    this.data['type'] = _get_frame_type(frames);

    this.data['tx_direction'] = _get_transmission_direction(frames);

    final x_axis = _to_float16(frames[1], frames[2]);
    this.data['x_axis'] = x_axis;

    final y_axis = _to_float16(frames[3], frames[4]);
    this.data['y_axis'] = y_axis;
    ;

    final z_axis = _to_float16(frames[5], frames[6]);
    this.data['z_axis'] = z_axis;
    ;
  }

  void _heart_beat(frames) {
    _status_frame(frames);
  }

  void _status_change(Uint8List frame) {
    _status_frame(frame);
  }

  void _error(Uint8List frame) {
    this.data['type'] = _get_frame_type(frame);
    this.data['tx_direction'] = _get_transmission_direction(frame);
    this.data['error_type'] = _get_error_type(frame);
  }

  void _status_frame(Uint8List frames) {
    this.data['type'] = _get_frame_type(frames);

    this.data['tx_direction'] = _get_transmission_direction(frames);

    final x_axis = _to_float16(frames[1], frames[2]);
    this.data['x_axis'] = x_axis;

    final y_axis = _to_float16(frames[3], frames[4]);
    this.data['y_axis'] = y_axis;
    ;

    final z_axis = _to_float16(frames[5], frames[6]);
    this.data['z_axis'] = z_axis;
    ;

    final temperature = _to_int16(frames[7], frames[8]) / 100;
    this.data['temperature'] = temperature;

    final parking_flag = frames[9] & 0x80 != 0;
    this.data['is_parked'] = parking_flag;

    final battery_voltage = (frames[9] & 0x7F) / 10;
    this.data['battery_voltage'] = battery_voltage;
  }

  void _set_error(String type, String message) {
    this.data = {'type': type, 'message': message};
  }

  String _get_frame_type(frame) {
    String name = 'Unknown';
    _FRAME.forEach((key, value) {
      if (frame[0] & 0xF0 == value) {
        name = key;
      }
    });
    return name;
  }

  String _get_transmission_direction(frame) {
    return (frame[0] & 1) == 1 ? 'Uplink' : 'Downlink';
  }

  String _to_float16(int frame0, int frame1) {
    List<int> byte_list = [frame0, frame1, 0, 0];
    ByteBuffer buffer = new Int8List.fromList(byte_list).buffer;
    ByteData byteData = new ByteData.view(buffer);
    double x = byteData.getFloat32(0);
    if (x.isNaN) {
      return 'NaN';
    }
    return x.toStringAsPrecision(2);
  }

  int _to_int16(int frame0, int frame1) {
    List<int> byte_list = [frame0, frame1];
    ByteBuffer buffer = new Int8List.fromList(byte_list).buffer;
    ByteData byteData = new ByteData.view(buffer);
    return byteData.getInt16(0);
  }

  String _get_error_type(Uint8List frame) {
    if (frame[1] == 0) {
      return 'Sensor detected';
    }
    return 'Unknown';
  }
}
