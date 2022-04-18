// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:calendar_view/src/calendar_event_data.dart';
import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';

/// A single page for week view.
class InternalWeekViewPage<T> extends StatelessWidget {
  /// Width of the page.
  final double width;

  /// Height of the page.
  final double height;

  /// Dates to display on page.
  final List<DateTime> dates;

  /// Builds tile for a single event.
  final EventTileBuilder<T> eventTileBuilder;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T> controller;

  /// A builder to build time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Flag to display live line.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  ///  Height occupied by one minute time span.
  final double heightPerMinute;

  /// Width of timeline.
  final double timeLineWidth;

  /// Offset of timeline.
  final double timeLineOffset;

  /// Height occupied by one hour time span.
  final double hourHeight;

  /// Arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line or not.
  final bool showVerticalLine;

  /// Offset for vertical line offset.
  final double verticalLineOffset;

  /// Builder for week day title.
  final DateWidgetBuilder weekDayBuilder;

  /// Height of week title.
  final double weekTitleHeight;

  /// Width of week title.
  final double weekTitleWidth;

  final ScrollController scrollController;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  final List<WeekDays> weekDays;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// A single page for week view.
  const InternalWeekViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.weekTitleHeight,
    required this.weekDayBuilder,
    required this.width,
    required this.dates,
    required this.eventTileBuilder,
    required this.controller,
    required this.timeLineBuilder,
    required this.hourIndicatorSettings,
    required this.showLiveLine,
    required this.liveTimeIndicatorSettings,
    required this.heightPerMinute,
    required this.timeLineWidth,
    required this.timeLineOffset,
    required this.height,
    required this.hourHeight,
    required this.eventArranger,
    required this.verticalLineOffset,
    required this.weekTitleWidth,
    required this.scrollController,
    required this.onTileTap,
    required this.onDateLongPress,
    required this.weekDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredDates = _filteredDate();
    bool isEventAllDay = false;
    for (DateTime date in filteredDates) {
      isEventAllDay = controller
          .getEventsOnDay(date)
          .where((element) => element.allDay)
          .isNotEmpty;
      if (isEventAllDay) {
        break;
      }
    }
    return Container(
      height: height + weekTitleHeight,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: weekTitleHeight,
                  width: timeLineWidth,
                ),
                ...List.generate(
                  filteredDates.length,
                  (index) => SizedBox(
                    height: weekTitleHeight,
                    width: weekTitleWidth,
                    child: weekDayBuilder(
                      filteredDates[index],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    if (isEventAllDay)
                      Row(
                        children: [
                          Container(
                            child: Text(
                              controller.getLocalizedDayForEvent(),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            width: timeLineWidth,
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                children: List.generate(7, (index) {
                                  final List<CalendarEventData> events =
                                      controller
                                          .getEventsOnDay(filteredDates[index])
                                          .where((element) => element.allDay)
                                          .toList();
                                  return Center(
                                    child: Container(
                                      width: weekTitleWidth,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(events.length,
                                            (index) {
                                          return Container(
                                            width: weekTitleWidth - 4,
                                            padding: EdgeInsets.all(5),
                                            margin: EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                                color: events[index].color,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Center(
                                                child: Text(
                                              events[index].title,
                                              style: TextStyle(fontSize: 10),
                                            )),
                                          );
                                        }),
                                      ),
                                    ),
                                  );
                                }),
                              ))
                        ],
                      ),
                    if (isEventAllDay) SizedBox(height: 15),
                    Stack(
                      children: [
                        CustomPaint(
                          size: Size(width, height),
                          painter: HourLinePainter(
                            lineColor: hourIndicatorSettings.color,
                            lineHeight: hourIndicatorSettings.height,
                            offset:
                                timeLineWidth + hourIndicatorSettings.offset,
                            minuteHeight: heightPerMinute,
                            verticalLineOffset: verticalLineOffset,
                            showVerticalLine: showVerticalLine,
                          ),
                        ),
                        if (showLiveLine &&
                            liveTimeIndicatorSettings.height > 0)
                          LiveTimeIndicator(
                            liveTimeIndicatorSettings:
                                liveTimeIndicatorSettings,
                            width: width,
                            height: height,
                            heightPerMinute: heightPerMinute,
                            timeLineWidth: timeLineWidth,
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: weekTitleWidth * filteredDates.length,
                            height: height,
                            child: Row(
                              children: [
                                ...List.generate(
                                  filteredDates.length,
                                  (index) => Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: hourIndicatorSettings.color,
                                          width: hourIndicatorSettings.height,
                                        ),
                                      ),
                                    ),
                                    height: height,
                                    width: weekTitleWidth,
                                    child: Stack(
                                      children: [
                                        PressDetector(
                                          width: weekTitleWidth,
                                          height: height,
                                          hourHeight: hourHeight,
                                          date: dates[index],
                                          onDateLongPress: onDateLongPress,
                                        ),
                                        EventGenerator<T>(
                                          height: height,
                                          date: filteredDates[index],
                                          onTileTap: onTileTap,
                                          width: weekTitleWidth,
                                          eventArranger: eventArranger,
                                          eventTileBuilder: eventTileBuilder,
                                          events: controller.getEventsOnDay(
                                              filteredDates[index]),
                                          heightPerMinute: heightPerMinute,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        TimeLine(
                          timeLineWidth: timeLineWidth,
                          hourHeight: hourHeight,
                          height: height,
                          timeLineOffset: timeLineOffset,
                          timeLineBuilder: timeLineBuilder,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _filteredDate() {
    final output = <DateTime>[];

    final weekDays = this.weekDays.toList()
      ..sort((d1, d2) => d1.index - d2.index);

    var weekDayIndex = 0;
    var dateCounter = 0;

    while (weekDayIndex < weekDays.length && dateCounter < dates.length) {
      if (dates[dateCounter].weekday == weekDays[weekDayIndex].index + 1) {
        output.add(dates[dateCounter]);
        weekDayIndex++;
      }
      dateCounter++;
    }

    return output;
  }
}
