library dito_sdk;

import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Event {
  final String eventName;
  final String eventMoment;
  final double? revenue;
  final Map<String, dynamic>? customData;

  Event(
      {required this.eventName,
      required this.eventMoment,
      this.revenue,
      this.customData});

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventMoment': eventMoment,
      'revenue': revenue,
      'customData': customData != null ? json.encode(customData) : null,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventName: map['eventName'],
      eventMoment: map['eventMoment'],
      revenue: map['revenue'],
      customData: map['customData'] != null
          ? Map<String, dynamic>.from(json.decode(map['customData']))
          : null,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'ditoSDK.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY,
        eventName TEXT,
        eventMoment TEXT,
        revenue REAL,
        customData TEXT
      )
    ''');
  }

  Future<void> insertEvent(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (index) {
      return Event.fromMap(maps[index]);
    });
  }

  Future<void> deleteAllEvents() async {
    final db = await database;
    await db.delete('events');
  }
}

class DitoSDK {
  String? _userAgent;
  String? _apiKey;
  String? _secretKey;
  String? _userID;
  String? _name;
  String? _email;
  String? _gender;
  String? _birthday;
  String? _location;
  Map<String, dynamic>? _customData;
  // final List<Event> _untrackedEvents = [];

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  void initialize({required String apiKey, required String secretKey}) {
    _apiKey = apiKey;
    _secretKey = secretKey;
  }

  String _convertToSHA1(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  void identify({
    String? cpf,
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? location,
    Map<String, String>? customData,
  }) {
    if (name != null) {
      _name = name;
    }
    if (email != null) {
      _email = email;
    }
    if (gender != null) {
      _gender = gender;
    }
    if (birthday != null) {
      _birthday = birthday;
    }
    if (location != null) {
      _location = location;
    }
    if (customData != null) {
      _customData = customData;
    }
  }

  void printDB() async {
    final dbHelper = DatabaseHelper.instance;
    final events = await dbHelper.getEvents();

    if (events.isNotEmpty) {
      for (var event in events) {
        print(
            '${event.eventName}, ${event.eventMoment}, ${event.revenue}, ${event.customData!.values},');
      }
    }
  }

  void setUserId(String userId) async {
    _userID = userId;

    final dbHelper = DatabaseHelper.instance;
    final events = await dbHelper.getEvents();

    if (events.isNotEmpty) {
      for (var event in events) {
        trackEvent(
          eventName: event.eventName,
          eventMoment: event.eventMoment,
          revenue: event.revenue,
          customData: event.customData,
        );
      }
      await dbHelper.deleteAllEvents();
    }

    // if (_untrackedEvents.isNotEmpty) {
    //   for (var event in _untrackedEvents) {
    //     trackEvent(
    //         eventName: event.eventName,
    //         eventMoment: event.eventMoment,
    //         revenue: event.revenue,
    //         customData: event.customData);
    //   }
    //   _untrackedEvents.clear();
    // }
  }

  void setUserAgent(String userAgent) {
    _userAgent = userAgent;
  }

  Future<String> _getUserAgent() async {
    final deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String appName = packageInfo.appName;
    String system;
    String model;

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      system = 'iOS ${ios.systemVersion}';
      model = ios.model;
    } else {
      final android = await deviceInfo.androidInfo;
      system = 'Android ${android.version}';
      model = android.model;
    }

    return '$appName/$version ($system; $model)';
  }

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<void> identifyUser() async {
    _checkConfiguration();

    if (_userID == null) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    }

    final signature = _convertToSHA1(_secretKey!);

    final params = {
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'user_data': jsonEncode({
        'name': _name,
        'email': _email,
        'gender': _gender,
        'location': _location,
        'birthday': _birthday,
        'data': json.encode(_customData)
      }),
    };

    final url = Uri.parse(
        "https://login.plataformasocial.com.br/users/portal/$_userID/signup");

    final defaultUserAgent = await _getUserAgent();

    try {
      await http.post(
        url,
        body: params,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': _userAgent ?? defaultUserAgent,
        },
      );
    } catch (e) {
      throw Exception('Requisition failed: $e');
    }
  }

  Future<void> trackEvent({
    required String eventName,
    double? revenue,
    Map<String, dynamic>? customData,
    String? eventMoment,
  }) async {
    _checkConfiguration();

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    if (_userID == null) {
      final dbHelper = DatabaseHelper.instance;
      final untrackedEvent = Event(
        eventName: eventName,
        eventMoment: now,
        revenue: revenue,
        customData: customData,
      );
      await dbHelper.insertEvent(untrackedEvent);
      // _untrackedEvents.add(untrackedEvent);
      return;
    }

    final signature = _convertToSHA1(_secretKey!);

    final params = {
      'id_type': 'id',
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'encoding': 'base64',
      'network_name': 'pt',
      'event': jsonEncode({
        'action': eventName,
        'revenue': revenue,
        'data': customData,
        'created_at': eventMoment ?? now
      })
    };

    final url =
        Uri.parse("http://events.plataformasocial.com.br/users/$_userID");

    final defaultUserAgent = await _getUserAgent();

    try {
      await http.post(
        url,
        body: params,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': _userAgent ?? defaultUserAgent,
        },
      );
    } catch (e) {
      throw Exception('Requisition failed: $e');
    }
  }
}
