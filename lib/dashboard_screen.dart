import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http;

class DashboardScreen
    extends StatefulWidget {

  final String token;

  const DashboardScreen({
    super.key,
    required this.token,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  List todos = [];

  double temperature = 0;

  int humidity = 0;

  String weather = "";

  @override
  void initState() {
    super.initState();

    fetchTodos();

    fetchWeather();
  }

  Future<void> fetchTodos() async {

    final response = await http.get(

      Uri.parse(
        "http://10.0.2.2:8000/api/tasks/",
      ),

      headers: {
        "Authorization":
            "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {

      setState(() {
        todos = jsonDecode(
          response.body,
        );
      });
    }
  }

  Future<void> fetchWeather() async {

    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=Kochi&appid=${dotenv.env['WEATHER_API_KEY']}&units=metric",
      ),
    );

    final data = jsonDecode(
      response.body,
    );

    setState(() {

      temperature =
          data['main']['temp'];

      humidity =
          data['main']['humidity'];

      weather =
          data['weather'][0]['main'];
    });
  }

  @override
  Widget build(BuildContext context) {

    int totalTasks = todos.length;

    int completedTasks = todos.where((todo) => todo['completed']==true).length;
        

    int pendingTasks =
        totalTasks - completedTasks;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Dashboard",

          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      
      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Productivity Overview",

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(

              crossAxisCount: 2,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              crossAxisSpacing: 14,

              mainAxisSpacing: 14,

              children: [

                metricCard(
                  "Total Tasks",
                  totalTasks.toString(),
                  Icons.task,
                ),

                metricCard(
                  "Completed",
                  completedTasks.toString(),
                  Icons.check_circle,
                ),

                metricCard(
                  "Pending",
                  pendingTasks.toString(),
                  Icons.pending,
                ),

                metricCard(
                  "Productivity",

                  "${totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).toInt()}%",

                  Icons.bar_chart,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Task Analytics",

              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(

              height: 220,

              child: PieChart(

                PieChartData(

                  sections: [

                    PieChartSectionData(
                      value:
                          completedTasks
                              .toDouble(),

                      title: "Done",

                      radius: 70,
                      color: const Color(0xFF6C63FF),

                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        ),
                    ),

                    PieChartSectionData(
                      value:
                          pendingTasks
                              .toDouble(),

                      title: "Pending",

                      radius: 70,
                        color: const Color(0xFFFF8A65),
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(24),

              decoration: BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF8E85FF),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Weather",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${temperature.toStringAsFixed(1)}°C",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    weather,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Humidity: $humidity%",

                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget metricCard(
    String title,
    String value,
    IconData icon,
  ) {

    return Card(

      child: Padding(

        padding:
            const EdgeInsets.all(18),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 32,
              color:
                  const Color(0xFF6C63FF),
            ),

            const SizedBox(height: 14),

            Text(
              value,

              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,

              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}