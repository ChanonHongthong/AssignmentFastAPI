import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Assignmentpm extends StatefulWidget {
  const Assignmentpm({super.key});

  @override
  State<Assignmentpm> createState() => _AQIHomePageState();
}

class _AQIHomePageState extends State<Assignmentpm> {
  bool loading = false;
  String? error;
  Map<String, dynamic>? data;
  String province = "";

  @override
  void initState() {
    super.initState();
    fetchAQI();
  }

  Future<void> fetchAQI() async {
    setState(() {
      loading = true;
      error = null;
      data = null;
      province = "Unknown";
    });

    try {
      final url = Uri.parse("https://api.waqi.info/feed/A477652/?token=a6a7e70c565ca4aa3e3b176188bca35b841e5bec");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json["status"] == "ok") {
          final stationData = json["data"];
          setState(() => data = stationData);

          final geo = stationData["city"]?["geo"];
          if (geo != null && geo.length == 2) {
            final lat = geo[0];
            final lon = geo[1];
            final prov = await getProvinceFromGeo(lat, lon);
            setState(() => province = prov ?? "Unknown");
          }
        } else {
          setState(() => error = "API Error: ${json['data']}");
        }
      } else {
        setState(() => error = "HTTP Error: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<String?> getProvinceFromGeo(double lat, double lon) async {
    final url = Uri.parse("https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=th");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      final state = jsonData['address']?['state'] ?? jsonData['address']?['county'];
      if (state != null) {
        return state.replaceAll("จังหวัด", "").trim();
      }
    }
    return null;
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("sky.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        buildResult(),
      ],
    ),
  );
}

  String getWeekday(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEEE').format(dt);
    } catch (e) {
      return "-";
    }
  }

  String getTimeOnly(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat.Hm().format(dt);
    } catch (e) {
      return "-";
    }
  }

  String getAQIImage(int aqi) {
    if (aqi <= 50) {
      return 'https://waqi.info/images/emoticons/aqi-label-1.svg';
    } else if (aqi <= 100) {
      return 'https://waqi.info/images/emoticons/aqi-label-2.svg';
    } else if (aqi <= 150) {
      return 'https://waqi.info/images/emoticons/aqi-label-3.svg';
    } else if (aqi <= 200) {
      return 'https://waqi.info/images/emoticons/aqi-label-4.svg';
    } else if (aqi <= 300) {
      return 'https://waqi.info/images/emoticons/aqi-label-5.svg';
    } else {
      return 'https://waqi.info/images/emoticons/aqi-label-6.svg';
    }
  }

  Color getAQIBackgroundColor(int aqi) {
    if (aqi <= 50) {
      return const Color.fromARGB(255, 0, 153, 102);
    } else if (aqi <= 100) {
      return const Color.fromARGB(255, 255, 222, 51);
    } else if (aqi <= 150) {
      return const Color.fromARGB(255, 255, 153, 51);
    } else if (aqi <= 200) {
      return const Color.fromARGB(255, 204, 0, 51);
    } else if (aqi <= 300) {
      return const Color.fromARGB(255, 102, 0, 153);
    } else {
      return const Color.fromARGB(255, 126, 0, 35);
    }
  }

  Widget buildResult() {
    final aqi = data?["aqi"] ?? 0;
    final iaqi = data?["iaqi"] ?? {};
    final timeData = data?["time"] ?? {};
    final timesA = timeData["s"] ?? "-";
    final times = timesA != "-" ? getTimeOnly(timesA) : "-";
    final weekday = timesA != "-" ? getWeekday(timesA) : "-";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          " $province",
          style: const TextStyle(
            fontSize: 26,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        Text(
          "(Update On, $weekday $times)",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1.5, 1.5),
                blurRadius: 3.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: getAQIBackgroundColor(aqi).withOpacity(0.8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SvgPicture.network(
                    getAQIImage(aqi),
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$aqi",
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    getAQIStatus(aqi),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              buildInfoCard(
                  Icons.water_drop, "Humidity", "${iaqi["h"]?["v"] ?? "-"} %"),
              buildInfoCard(Icons.thermostat, "Temperature",
                  "${iaqi["t"]?["v"] ?? "-"} °C"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: fetchAQI,
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh"),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: Colors.black),
        ),
      ],
    );
  }

  Widget buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getAQIStatus(int aqi) {
    if (aqi <= 50) return "Good";
    if (aqi <= 100) return "Moderate";
    if (aqi <= 150) return "Unhealthy for Sensitive Groups";
    if (aqi <= 200) return "Unhealthy";
    if (aqi <= 300) return "Very Unhealthy";
    return "Hazardous";
  }
}
