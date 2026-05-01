import 'package:mycgmapp/Models/login_response.dart';

class GraphResponse {
  final int status;
  final GraphData data;
  final AuthTicket ticket;

  GraphResponse({required this.status, required this.data, required this.ticket});

  factory GraphResponse.fromJson(Map<String, dynamic> json) {
    return GraphResponse(
      status: json['status'],
      data: GraphData.fromJson(json['data']),
      ticket: AuthTicket.fromJson(json['ticket']),
    );
  }
}

class GraphData {
  final Connection connection;
  final List<GraphPoint> graphData;

  GraphData({required this.connection, required this.graphData});

  factory GraphData.fromJson(Map<String, dynamic> json) {
    var graphDataList = json['graphData'] as List;
    List<GraphPoint> graphPoints = graphDataList.map((i) => GraphPoint.fromJson(i)).toList();

    return GraphData(
      connection: Connection.fromJson(json['connection']),
      graphData: graphPoints,
    );
  }
}

class Connection {
  final String id;
  final GlucoseMeasurement glucoseMeasurement;

  Connection({required this.id, required this.glucoseMeasurement});

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      glucoseMeasurement: GlucoseMeasurement.fromJson(json['glucoseMeasurement']),
    );
  }
}

class GlucoseMeasurement {
  final String timestamp;
  final int valueInMgPerDl;
  final int trendArrow;
  final double value;

  GlucoseMeasurement({
    required this.timestamp,
    required this.valueInMgPerDl,
    required this.trendArrow,
    required this.value,
  });

  factory GlucoseMeasurement.fromJson(Map<String, dynamic> json) {
    final value = json['Value'];
    return GlucoseMeasurement(
      timestamp: json['Timestamp'],
      valueInMgPerDl: json['ValueInMgPerDl'],
      trendArrow: json['TrendArrow'],
      value: value is int ? value.toDouble() : value,
    );
  }
}

class GraphPoint {
  final String timestamp;
  final int valueInMgPerDl;
  final double value;

  GraphPoint({
    required this.timestamp,
    required this.valueInMgPerDl,
    required this.value,
  });

  factory GraphPoint.fromJson(Map<String, dynamic> json) {
    final value = json['Value'];
    return GraphPoint(
      timestamp: json['Timestamp'],
      valueInMgPerDl: json['ValueInMgPerDl'],
      value: value is int ? value.toDouble() : value,
    );
  }
}
