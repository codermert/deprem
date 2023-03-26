import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  runApp(MyApp());

  // Bildirimler için ayarlamalar yapılıyor.
  var initializationSettingsAndroid = AndroidInitializationSettings('@drawable/app_icon');
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // API'yi belirli aralıklarla çağırmak için bir Timer başlatılıyor.
  Timer.periodic(Duration(minutes: 30), (timer) {
    fetchData().then((data) {
      List<dynamic> newData = data;
      if (newData.isNotEmpty) {
        showNotification(newData[0]["title"], newData[0]["mag"].toString());
      }
    });
  });
}

Future<List<dynamic>> fetchData() async {
  var url = "https://api.orhanaydogdu.com.tr/deprem/kandilli/live";
  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> map = json.decode(response.body);
    var data = map['result'];

    return data;
  } else {
    throw Exception('Failed to load data');
  }
}

void showNotification(String title, String magnitude) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id', 'channel_name',
      importance: Importance.max, priority: Priority.high);
  var platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await FlutterLocalNotificationsPlugin().show(
    0,
    'Yeni Bir Deprem Oldu!',
    '$title \nBüyüklük: $magnitude',
    platformChannelSpecifics,
    payload: 'item x',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Son Depremler',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _data = [];

  Future<List<dynamic>> fetchData() async {
    var url = "https://api.orhanaydogdu.com.tr/deprem/kandilli/live";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(response.body);
      var data = map['result'];

      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then((data) {
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Son Depremler'),
    centerTitle: true,
    toolbarHeight: 75,
    toolbarOpacity: 1,
    shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
    bottomRight: Radius.circular(40),
    bottomLeft: Radius.circular(40),
    ),
    ),
    elevation: 10,
    backgroundColor: Colors.purple[200],
    ),
    body: ListView.builder(
    itemCount: _data.length,
    itemBuilder: (BuildContext context, int index) {
    var item = _data[index];
    return GestureDetector(
    onTap: () {
    showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
    return Container(
    height: 200,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Text("Derinlik: ${item["depth"]}\n"),
    Text("Büyüklük: ${item["mag"]}\n"),
    Text(" ${item["title"] ?? 'Belirtilmemiş'}"),
    ],
    ),
    );
    },
    );
    },
    child: Card(
    child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item["title"],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        SizedBox(height: 8.0),
        Text(item["date"]),
      ],
    ),
    ),
    ),
    );
    },
    ),
    );
  }
}

