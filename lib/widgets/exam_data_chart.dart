import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/exam_data.dart';
import '../models/exam_data_series.dart';

class ExamDataChart extends StatelessWidget {
  final List<ExamData> examDataList;

  ExamDataChart({required this.examDataList});

  @override
  Widget build(BuildContext context) {
    final seriesList = _createChartData(examDataList);

    return Container(
      height: 300,
      child: charts.TimeSeriesChart(
        seriesList,
        animate: true,
        dateTimeFactory: charts.LocalDateTimeFactory(),
        // Optionally add more chart configurations here
      ),
    );
  }

  List<charts.Series<ExamDataSeries, DateTime>> _createChartData(
      List<ExamData> examDataList) {
    final data = examDataList
        .map(
            (data) => ExamDataSeries(DateTime.parse(data.examDate), data.marks))
        .toList();

    return [
      charts.Series<ExamDataSeries, DateTime>(
        id: 'Marks',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ExamDataSeries series, _) => series.date,
        measureFn: (ExamDataSeries series, _) => series.marks,
        data: data,
        // Optionally add more chart configurations here
      )
    ];
  }
}
