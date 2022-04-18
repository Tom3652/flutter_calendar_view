// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'extensions.dart';

/// Stores all the events on [date]
@immutable
class CalendarEventData<T> {
  /// Specifies date on which all these events are.
  final DateTime date;

  /// Defines the start time of the event.
  /// [endTime] and [startTime] will defines time on same day.
  /// This is required when you are using [CalendarEventData] for [DayView]
  final DateTime? startTime;

  /// Defines the end time of the event.
  /// [endTime] and [startTime] defines time on same day.
  /// This is required when you are using [CalendarEventData] for [DayView]
  final DateTime? endTime;

  /// Title of the event.
  final String title;

  /// Description of the event.
  final String description;

  /// Defines color of event.
  /// This color will be used in default widgets provided by plugin.
  final Color color;

  /// Event on [date].
  final T? event;

  final DateTime? _endDate;

  final String uid;

  /// Stores all the events on [date]
  const CalendarEventData({
    required this.title,
    this.description = "",
    this.event,
    this.color = Colors.blue,
    this.startTime,
    this.endTime,
    DateTime? endDate,
    required this.date,
    required this.uid,
  }) : _endDate = endDate;

  DateTime get endDate => _endDate ?? date;

  factory CalendarEventData.fromJson(Map<String, dynamic> json) {
    return CalendarEventData(
      title: json["title"],
      date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
      uid: json["uid"],
      startTime: json["startTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["startTime"])
          : null,
      endDate: json["endDate"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["endDate"])
          : null,
      endTime: json["endTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["endTime"])
          : null,
      //event: json["event"],
      color: Color(json["color"]),
      description: json["description"],
    );
  }

  Map<String, dynamic> toJson() => {
        "date": date.millisecondsSinceEpoch,
        "startTime": startTime?.millisecondsSinceEpoch,
        "endTime": endTime?.millisecondsSinceEpoch,
        //"event": event,
        "title": title,
        "uid": uid,
        "color": color.value,
        "description": description,
        "endDate": endDate.millisecondsSinceEpoch,
      };

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) {
    return other is CalendarEventData<T> &&
        date.compareWithoutTime(other.date) &&
        endDate.compareWithoutTime(other.endDate) &&
        event == other.event &&
        title == other.title &&
        uid == other.uid &&
        description == other.description;
  }

  @override
  int get hashCode => super.hashCode;
}
