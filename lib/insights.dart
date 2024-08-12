import 'dart:convert';
import 'package:edu_learn/new-home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_charts/charts.dart';

class InsightsPage extends StatefulWidget {
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  List<dynamic>? examScores;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/scripts/scores.json');
    final data = json.decode(response);
    setState(() {
      examScores = data['exam_scores'];
    });
    print('Data loaded: $data');
  }

  Widget _buildScoreChart() {
    if (examScores == null) {
      return Center(child: CircularProgressIndicator());
    }

    List<ChartData> chartData = examScores!.map<ChartData>((data) {
      return ChartData(data['subject'], data['score'].toDouble());
    }).toList();

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.subject,
          yValueMapper: (ChartData data, _) => data.score,
          color: Colors.blue,
          width: 2,
          markerSettings: MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    if (examScores == null) {
      return Center(child: CircularProgressIndicator());
    }

    Map<String, double> subjectAverages = {};
    for (var item in examScores!) {
      String subject = item['subject'];
      double score = item['score'].toDouble();
      subjectAverages[subject] = score;
    }

    List<PieChartData> pieData = subjectAverages.entries.map((e) {
      return PieChartData(e.key, e.value);
    }).toList();

    return SfCircularChart(
      series: <PieSeries<PieChartData, String>>[
        PieSeries<PieChartData, String>(
          dataSource: pieData,
          xValueMapper: (PieChartData data, _) => data.subject,
          yValueMapper: (PieChartData data, _) => data.score,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Use Flexible to adjust the space usag
            SizedBox(height: 20),
            Flexible(flex: 3, child: _buildScoreChart()),
            SizedBox(height: 20),
            Flexible(flex: 2, child: _buildPieChart()),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.subject, this.score);

  final String subject;
  final double score;
}

class PieChartData {
  PieChartData(this.subject, this.score);

  final String subject;
  final double score;
}
