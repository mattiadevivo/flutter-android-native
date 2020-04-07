import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermo_module/widget/utils.dart';
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

/// Extracts the handlers' values from the [binaryString] representing the day
/// configuration.
///
/// Returns a List<int> where:
/// [0] => handler #1 position
/// [1] => handler #2 position
/// [2] => handler #3 position
/// [3] => handler #4 position.
List<int> _getTimes(String binaryString){
  Map<String, int> t3Section = Map();
  Map<String, int> t3Section2 = Map();
  Map<String, int> t2Section = Map();
  Map<String, int> t1Section = Map();

  for(int i = 0; i <= binaryString.length - 2; i += 2){
    // A quarter of hour is represented by two binary digits.
    // substring() returns a string with the digits from position i to i + 2 - 1.
    String quarter = binaryString.substring(i, i + 2);
    switch(quarter){
      case '11':
        // T3 section.
        if(t3Section['start'] == null || t3Section['finish'] == null){
          // Part of the first T3 section.
          if(t3Section['start'] == null){
            // This is the first part of T3 section we analyze.
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              // This is the first quarter of the day configuration and the section starts before midnight.
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t3Section['start'] = j ~/ 2;
            } else{
              // This is not the first quarter of the day configuration or the section doesn't start
              // before midnight.
              t3Section['start'] = i ~/ 2;
            }
          }
          if(t3Section['finish'] == null) {
            // End of the section is not yet defined.
            if (i + 2 <= (binaryString.length - 2) &&
                binaryString.substring(i + 2, i + 4) != quarter) {
              // If the next quarter is different from this one, this is the end of section.
              t3Section['finish'] = i ~/ 2;
            } else if (i + 2 > (binaryString.length - 2)) {
              // This is the last quarter of day configuration, so it's the end of the section.
              t3Section['finish'] = (binaryString.length - 2) ~/ 2;
            }
          }
        } else {
          // Part of the T3 section #2.
          if(t3Section2['start'] == null){
            // This is the first part of T3 section #2 we analyze.
            if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
              // This is the first quarter of the day configuration and the section starts before midnight.
              int j = binaryString.length - 2;
              while(binaryString.substring(j - 2,j) == quarter){
                j -= 2;
              }
              t3Section2['start'] = j ~/ 2;
            } else{
              // This is not the first quarter of the day configuration or the section doesn't start
              // before midnight.
              t3Section2['start'] = i ~/ 2;
            }
          }
          if(t3Section2['finish'] == null) {
            // End of the section is not yet defined.
            if (i + 2 <= (binaryString.length - 2) &&
                binaryString.substring(i + 2, i + 4) != quarter) {
              // If the next quarter is different from this one, this is the end of section.
              t3Section2['finish'] = i ~/ 2;
            } else if (i + 2 > (binaryString.length - 2)) {
              // This is the last quarter of day configuration, so it's the end of the section.
              t3Section2['finish'] = (binaryString.length - 2) ~/ 2;
            }
          }
        }
        break;
      case '10':
        // Part of T2 section.
        if(t2Section['start'] == null) {
          // This is the first part of T2 section we analyze.
          if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
            // This is the first quarter of the day configuration and the section starts before midnight.
            int j = binaryString.length - 2;
            while(binaryString.substring(j - 2,j) == quarter){
              j -= 2;
            }
            t2Section['start'] = j ~/ 2;
          } else{
            // This is not the first quarter of the day configuration or the section doesn't start
            // before midnight.
            t2Section['start'] = i ~/ 2;
          }
        }
        if(t2Section['finish'] == null) {
          // End of the section is not yet defined.
          if (i + 2 <= (binaryString.length - 2) &&
              binaryString.substring(i + 2, i + 4) != quarter) {
            // If the next quarter is different from this one, this is the end of section.
            t2Section['finish'] = i ~/ 2;
          } else if (i + 2 > (binaryString.length - 2)) {
            // This is the last quarter of day configuration, so it's the end of the section.
            t2Section['finish'] = (binaryString.length - 2) ~/ 2;
          }
        }
        break;
      case '01':
        // Part of T1 section.
        if(t1Section['start'] == null) {
          // This is the first part of T\ section we analyze.
          if(i == 0 && binaryString.substring(binaryString.length - 2,binaryString.length) == quarter){
            // This is the first quarter of the day configuration and the section starts before midnight.
            int j = binaryString.length - 2;
            while(binaryString.substring(j - 2,j) == quarter){
              j -= 2;
            }
            t1Section['start'] = j ~/ 2;
          } else{
            // This is not the first quarter of the day configuration or the section doesn't start
            // before midnight.
            t1Section['start'] = i ~/ 2;
          }
        }
        if(t1Section['finish'] == null) {
          // End of the section is not yet defined.
          if (i + 2 <= (binaryString.length - 2) &&
              binaryString.substring(i + 2, i + 4) != quarter) {
            // If the next quarter is different from this one, this is the end of section.
            t1Section['finish'] = i ~/ 2;
          } else if (i + 2 > (binaryString.length - 2)) {
            // This is the last quarter of day configuration, so it's the end of the section.
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
    // t3Section is the section from handler #1 to handler #2.
    // t3section2 is the section from handler #3 to handler #4.
    firstTime = t3Section['start'];
    thirdTime = t3Section2['start'];
  } else {
    // t3Section2 is the section from handler #1 to handler #2.
    // t3section is the section from handler #3 to handler #4.
    firstTime = t3Section2['start'];
    thirdTime = t3Section['start'];
  }
  // Start of section from handler #2 to handler #3.
  secondTime = t2Section['start'];
  // Start of section from handler #4 to handler #1.
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
}
