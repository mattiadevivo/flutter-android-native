import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermo_module/widget_files/utils.dart';
import 'network_exceptions.dart';

/// Converts the [hexString] into a binary string.
String _hexToBinary(String hexString) {
  String binaryString = '';
  for (int i = 0; i < hexString.length; i++) {
// Extracts string of binary digits corresponding to the hex digit.
    String binaryDigits = int.parse(hexString[i], radix: 16).toRadixString(2);
    if (binaryDigits.length < 4) {
// Adds zeros to the start of the string to obtain 4-digits binary string.
      for (int zeroToAdd = 4 - binaryDigits.length;
      zeroToAdd > 0;
      zeroToAdd--) {
        binaryDigits = '0' + binaryDigits;
      }
    }
    binaryString += binaryDigits;
  }
  return binaryString;
}

/// Converts the [binaryString] into a hex string.
String _binaryToHex(String binaryString) {
  String hexString = '';
  for (int i = 0; i <= binaryString.length - 4; i += 4) {
    String hexDigit = int.parse(binaryString.substring(i, i + 4), radix: 2)
        .toRadixString(16)
        .toUpperCase();
    hexString += hexDigit;
  }
  return hexString;
}

List<int> _getTimes(String binaryString){
  Map<String, int> t3Section = Map();
  Map<String, int> t3Section2 = Map();
  Map<String, int> t2Section = Map();
  Map<String, int> t1Section = Map();

  for(int i = 0; i <= binaryString.length - 2; i += 2){
    String quarter = binaryString.substring(i, i + 2);
    switch(quarter){
      case '11':
        if(t3Section['start'] == null || t3Section['finish'] == null){
          //
          if(t3Section['start'] == null){
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t3Section['start'] = j ~/ 2;
            } else{
              t3Section['start'] = i ~/ 2;
            }
          }
          if(t3Section['finish'] == null) {
            if (i + 2 <= (binaryString.length - 2) &&
                binaryString.substring(i + 2, i + 4) != quarter) {
              t3Section['finish'] = i ~/ 2;
            } else if (i + 2 > (binaryString.length - 2)) {
              t3Section['finish'] = (binaryString.length - 2) ~/ 2;
            }
          }
        } else {
          if(t3Section2['start'] == null){
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t3Section2['start'] = j ~/ 2;
            } else{
              t3Section2['start'] = i ~/ 2;
            }
          }
          if(t3Section2['finish'] == null) {
            if (i + 2 <= (binaryString.length - 2) &&
                binaryString.substring(i + 2, i + 4) != quarter) {
              t3Section2['finish'] = i ~/ 2;
            } else if (i + 2 > (binaryString.length - 2)) {
              t3Section2['finish'] = (binaryString.length - 2) ~/ 2;
            }
          }
        }
        break;
      case '10':
        if(t2Section['start'] == null) {
          if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
            int j = binaryString.length - 2;
            while(binaryString.substring(j - 2,j) == quarter){
              j -= 2;
            }
            t2Section['start'] = j ~/ 2;
          } else{
            t2Section['start'] = i ~/ 2;
          }
        }
        if(t2Section['finish'] == null) {
          if (i + 2 <= (binaryString.length - 2) &&
              binaryString.substring(i + 2, i + 4) != quarter) {
            t2Section['finish'] = i ~/ 2;
          } else if (i + 2 > (binaryString.length - 2)) {
            t2Section['finish'] = (binaryString.length - 2) ~/ 2;
          }
        }
        break;
      case '01':
        if(t1Section['start'] == null) {
          if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
            int j = binaryString.length - 2;
            while(binaryString.substring(j - 2,j) == quarter){
              j -= 2;
            }
            t1Section['start'] = j ~/ 2;
          } else{
            t1Section['start'] = i ~/ 2;
          }
          t1Section['start'] = i ~/ 2;
        }
        if(t1Section['finish'] == null) {
          if (i + 2 <= (binaryString.length - 2) &&
              binaryString.substring(i + 2, i + 4) != quarter) {
            t1Section['finish'] = i ~/ 2;
          } else if (i + 2 > (binaryString.length - 2)) {
            t1Section['finish'] = (binaryString.length - 2) ~/ 2;
          }
        }
        break;
    }
  }
  print('t3 section: ${t3Section.toString()}');
  print('t3 section: ${t3Section2.toString()}');
  print('t2 section: ${t2Section.toString()}');
  print('t1 section: ${t1Section.toString()}');
  int firstTime, secondTime, thirdTime, fourthTime;
  if((t3Section['finish'] + 1) % 96 == t2Section['start']) {
    firstTime = t3Section['start'];
    thirdTime = t3Section2['start'];
  } else {
    firstTime = t3Section2['start'];
    thirdTime = t3Section['start'];
  }
  secondTime = t2Section['start'];
  fourthTime = t1Section['start'];
  return [firstTime, secondTime, thirdTime, fourthTime];
}

class RestApiHelper {
  /// Shared preferences instance used for storing and retrieving toke info.
  static SharedPreferences sharedPref;

  /// Url to be used in GET token request.
  static const String tokenUrl =
      'https://devapi2.cameconnect.net/api/oauth/token';

  /// Url of the thermo Rest API
  static const String thermoApiUrl =
      'https://thermo-sandbox.cameconnect.net:8443';
  static const String getDevicesUrl = 'devices';
  static const String postDayConfigUrl = 'control';

  /// Returns JWT.
  ///
  /// It checks if a valid JWT is stored in shared preferences, if not it
  /// ask a new one from the server.
  static Future<String> _getToken() async {
    sharedPref = sharedPref ?? await SharedPreferences.getInstance();
    if (sharedPref.getString('token') != null &&
        sharedPref.getString('expiry_date') != null) {
      DateTime expiryDate = DateTime.parse(sharedPref.getString('expiry_date'));
      if (expiryDate.isAfter(DateTime.now())) {
        print("Shared preference token used");
        return sharedPref.getString('token');
      }
    }
    // There is not a valid token, so we need to request it.
    try {
      var httpResponse = await http.post(tokenUrl, headers: {
        'Authorization':
        'Basic ZmUyYjgwZmI1NTA5OTYxNDgwNTBmMDJmZGZjZTg0MTc6OGRjMTA3Zjc5NWQzNTRhODczYzdjOTlmYzVjZDc0ZDQ4ZmQ0NjhjMzU5MTM0ZGI1ZTg1MTk5YTg4ZGRjM2MzZmIwN2U4MmFhN2ZhY2U3NjhlOTc5MmMzMzU4YTQwMjBiMGM1YWI4MGQ1ZDZjNjViMTQ4MGMzNWJkMWJlN2JhYmFiMTFkZjhmODE0M2I0MTg2NmQ2ZmE5YWFmMjdkMTAxZjg5NmEzMmRhZTFjOTY2YWJhYWJlOGE0Mzk0NTYzZDFhOTc2NzRhYzI2OGNkOTA5ZmIzOGRkMGUxODE5NTBjNzJhNWJlMmE2N2FkODA0MWZkYjgwNjJiMmFmN2Y3MWE1Mg==',
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        'username': 'user.cameconnect',
        'password': 'cameRD2019',
        'grant_type': 'password',
      });
      Map<String, dynamic> jsonMap = _returnResponse(httpResponse);
      // Stores token and its expiry_date into Shared Preferences
      sharedPref.setString('token', jsonMap['access_token']);
      sharedPref.setString(
          'expiry_date',
          DateTime.now()
              .add(new Duration(seconds: jsonMap['expires_in']))
              .toString());
      // Returns the received token.
      print('New token used');
      return jsonMap['access_token'] as String;
    } on SocketException {
      throw FetchDataException('No internet connection');
    }
  }

  /// Returns the device keycode.
  static Future<String> _getKeyCode() async {
    // Gets the list of available devices for the user.
    List<dynamic> devicesList = await getDevices();
    // Information about first available device.
    Map<String, dynamic> firstDevInfo = devicesList.first['items'].first;
    return firstDevInfo['keycode'] as String;
  }

  /// Checks http response status code to manage various exceptions.
  static dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      // OK.
      //print(json.decode(response.body));
        return json.decode(response.body);
      case 400:
      // Bad Request.
        throw BadRequestException(response.body);
      case 401:
      case 403:
      // No authorization.
        throw UnauthorisedException(response.body);
      case 500:
      // Server error.
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  /// Returns the list of available devices for the user.
  static Future<List<dynamic>> getDevices() async {
    String token = await _getToken();
    try {
      var httpResponse =
      await http.get('$thermoApiUrl/$getDevicesUrl', headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      // Extract json body from the response.
      List<dynamic> jsonList = _returnResponse(httpResponse);
      return jsonList;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// Sends the temperature configuration [binaryDay] for day [dayNumber] in
  /// mode [season] to the server.
  ///
  /// The temperature configuration [binaryDay] is converted into hexadecimal
  /// string before the sending.
  static Future<bool> sendDayConfig(
      String binaryDay, int dayNumber, String season) async {
    // Converts the configuration into hexadecimal string.
    String hexDay = _binaryToHex(binaryDay);
    print('Sending day: $hexDay');
    // Gets token and keycode.
    String token = await _getToken();
    String keycode = await _getKeyCode();
    try {
      var httpResponse = await http
          .post('$thermoApiUrl/$postDayConfigUrl/$keycode/$keycode', headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }, body: jsonEncode({
        '$season.day$dayNumber': hexDay,
      }));
      Map<String, dynamic> bodyResponse = _returnResponse(httpResponse);
      print('${DateTime.now().toString()} ${bodyResponse['ok']}');
      return bodyResponse['ok'] as bool;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// Returns the temperature configuration for the desired [dayNumber] in
  /// binary format in [season].
  static Future<List<int>> getDayConfig(int dayNumber, String season) async {
    List<dynamic> devicesList = await getDevices();
    Map<String, dynamic> firstDevInfo = devicesList.first['items'].first;
    Map<String, dynamic> weekConf = firstDevInfo[season];
    // TODO: eliminare dopo testing.
    print('Day received: ${weekConf['day$dayNumber'] as String}');
    print('Day received: ${_hexToBinary(weekConf['day$dayNumber'] as String)}');
    List<int> expectedPositions = _getTimes(_hexToBinary(weekConf['day$dayNumber'] as String));
    print('#1: ${formatTime(expectedPositions[0])}\n#2: ${formatTime(expectedPositions[1])}\n#3: ${formatTime(expectedPositions[2])}\n#4_ ${formatTime(expectedPositions[3])},');
    // Converts the configuration into binary and sent back to the caller.
    return _getTimes(_hexToBinary(weekConf['day$dayNumber'] as String));
  }

/*
  --- RISPOSTA Get Token
  {
    "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRVcmkiOiJjYW1lY29ubmVjdC5uZXQ6ZmUyYjgwZmI1NTA5OTYxNDgwNTBmMDJmZGZjZTg0MTciLCJhdWQiOltdLCJleHAiOjE1ODUxMzIyMjIsImlhdCI6MTU4NTEyNTAyMiwiaXNzIjoiQ2FtZV9Db25uZWN0IiwianRpIjoiZDkzODJiNTQtMGExNC00YTUzLTkzOTktMmY5OWU2NzM2ZDExIiwicGVybWlzc2lvbnMiOiJVU0VSIiwic2NwIjpbXSwic3ViIjoidXNlci5jYW1lY29ubmVjdCIsInVzZXJpZCI6MTAxMSwidXNlcm5hbWUiOiJ1c2VyLmNhbWVjb25uZWN0In0.I47GRwBO2KpJCkZsCGTqWHwEpycSid-EivumWAZbGDfus4ZtX2MF74uIVfPDMqRm38Dx7S5Q63PL-fqe9L5Q9vrFJ71yG9mw-nk9RFaWDMg60ka7j0hv9wu3XvFxP81qUK6dWuNEuF4mPCZesM6Wo9JYUimrx7ffvyJqtbCEOfn-0JkSC1CdY3dZoq8YN40WekG_e3bGRerNn4Uz8t_6NDi_ty7HwTjhuqNcMBJ7fqJJCdylsyRsPP8B2im8dPrtj5bgMS_6KnjCoFRWh-Bz_7KZooo7ho4HNTMLvFQQGfsR4xT_tVDy5BJyWI-K6F3-TIlFH810NbcKl1DBkMqpog",
    "expires_in": 7199,
    "scope": "",
    "token_type": "bearer"
}
 ---- RISPOSTA GET  Devices
 [
    {
        "_id": "5e627b640ff7cd0011c6602b",
        "system": true,
        "user": "user.cameconnect",
        "name": "THs",
        "items": [
            {
                "keycode": "67238978E4E70C2C",
                "devcode": "67238978E4E70C2C",
                "cameconnect": {
                    "Keycode": "67238978E4E70C2C",
                    "Description": "TH700WiFi",
                    "ProductTypeId": 20,
                    "ProductTypeName": "TH/700"
                },
                "Description": "TH700WiFi",
                "ProductTypeId": 20,
                "_id": "5e627da3e179beefc50ddcf8",
                "Compile time": "Jul 10 2019 10:06:14",
                "Global FW Version": "1.00.001",
                "Slot": 1052672,
                "WiFi FW Version": "1.00.001",
                "on_line": 0,
                "updatedAt": "2020-03-24T17:24:40.737Z",
                "chunk_rate": 1,
                "chunk_size": 1024,
                "crc32": "E25098DB",
                "error": "None",
                "page_max": 512,
                "page_size": 4096,
                "algo": {
                    "PI_band": 1.7,
                    "T_cycle": 30,
                    "T_off_min": 4,
                    "T_on_min": 4,
                    "n_prog": 4,
                    "t_diff": 0.7,
                    "type": "diff"
                },
                "comfort_state": false,
                "current_season": "summer",
                "hum_loc": 45,
                "manual_temp": 30,
                "mode": "manual",
                "relay_status": 0,
                "st_fw_version": "V1.00.001",
                "temp_loc": 19.2,
                "winter": {
                    "T0": 3.4,
                    "T1": 16.29,
                    "T2": 18.2,
                    "T3": 20.1,
                    "day1": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day2": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day3": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day4": "555555555555FFFF555555FFFFAAAAAAAAFFFFFFFFFF5555",
                    "day5": "555555555555FFFF555555FFFFEAAAAAAAFFFFFFFFFF5555",
                    "day6": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555",
                    "day7": "55555555555555FFFFFFFFFFFFFFAAAAAAFFFFFFFFFF5555"
                },
                "boost_level": 3,
                "boost_rem_minutes": 0,
                "buzzer": true,
                "holiday_days": 3,
                "holiday_rem_days": 0,
                "keyboard_lock": false,
                "set_point_temp": 30,
                "stdby_mode": "proximity",
                "summer": {
                    "T1": 23.9,
                    "T2": 25.9,
                    "T3": 27.9,
                    "day1": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day2": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day3": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day4": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day5": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day6": "FFFFFFFFFFFF55555555555555555555555555555555FFFF",
                    "day7": "FFFFFFFFFFFF55555555555555555555555555555555FFFF"
                },
                "automatic_hour_change": true,
                "light_skin": false,
                "max_temp": 35,
                "min_temp": 3,
                "offset_temp": 0,
                "t_threshold_high": 0,
                "t_threshold_low": 0,
                "alarm_h_low": false,
                "alarm_t_high": false,
                "alarm_t_low": false,
                "h_threshold_enable": false,
                "h_threshold_high": 134260089,
                "h_threshold_low": 134260059,
                "t_threshold_enable": false,
                "alarm_h_high": false
            }
        ],
        "sceneries": [
            {
                "_id": "5e627b640ff7cd0011c6602d",
                "name": "Esco di casa",
                "name_translated": "scenery_1",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            },
            {
                "_id": "5e627b640ff7cd0011c6602f",
                "name": "Sto in casa",
                "name_translated": "scenery_2",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            },
            {
                "_id": "5e627b640ff7cd0011c66031",
                "name": "Vado a letto",
                "name_translated": "scenery_3",
                "actions": [],
                "group_id": "5e627b640ff7cd0011c6602b"
            }
        ]
    }
]
  *
  * */
}
