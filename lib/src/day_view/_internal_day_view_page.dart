// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../painters.dart';

/// Defines a single day page.
class InternalDayViewPage<T> extends StatelessWidget {
  /// Width of the page
  final double width;

  /// Height of the page.
  final double height;

  /// Date for which we are displaying page.
  final DateTime date;

  /// A builder that returns a widget to show event on screen.
  final EventTileBuilder<T> eventTileBuilder;

  /// Controller for calendar
  final EventController<T> controller;

  /// A builder that builds time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Flag to display live time indicator.
  /// If true then indicator will be displayed else not.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  /// Height occupied by one minute of time span.
  final double heightPerMinute;

  /// Width of time line.
  final double timeLineWidth;

  /// Offset for time line widgets.
  final double timeLineOffset;

  /// Height occupied by one hour of time span.
  final double hourHeight;

  /// event arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line.
  final bool showVerticalLine;

  /// Offset  of vertical line.
  final double verticalLineOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  final Color allDayTextColor;

  final double bottomPadding;

  /// Defines a single day page.
  const InternalDayViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.width,
    required this.date,
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
    required this.onTileTap,
    required this.onDateLongPress,
    required this.allDayTextColor,
    required this.bottomPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = controller.getEventsOnDay(date);
    //print("list 1 : $list");
    final eventsAllDay = list.where((element) => element.allDay).toList();
    final isEventAllDay = eventsAllDay.isNotEmpty;
    //print("is Event all day for DayView : $isEventAllDay");
    //print("all days event : ${eventsAllDay}");
    //print("----------------------------------");
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        if (isEventAllDay)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(bottom: 10, top: 10, left: 10),
              child: Text(controller.getLocalizedDayForEvent(),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    color: allDayTextColor
                  )),
            ),
          ),
        if (isEventAllDay)
          SliverPadding(
            padding: EdgeInsets.only(left: 10, right: 10),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  return GestureDetector(
                    onTap: () {
                      if(onTileTap != null) {
                        onTileTap!(controller
                            .getEventsOnDay(date), eventsAllDay[index].date);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: eventsAllDay[index].color,
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          eventsAllDay[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
                childCount: eventsAllDay.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10),
            ),
          ),
        SliverPadding(padding: EdgeInsets.all(5)),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: HourLinePainter(
                  lineColor: hourIndicatorSettings.color,
                  lineHeight: hourIndicatorSettings.height,
                  offset: timeLineWidth + hourIndicatorSettings.offset,
                  minuteHeight: heightPerMinute,
                  verticalLineOffset: verticalLineOffset,
                  showVerticalLine: showVerticalLine,
                ),
              ),
              if (showLiveLine && liveTimeIndicatorSettings.height > 0)
                LiveTimeIndicator(
                  liveTimeIndicatorSettings: liveTimeIndicatorSettings,
                  width: width,
                  height: height,
                  heightPerMinute: heightPerMinute,
                  timeLineWidth: timeLineWidth,
                ),
              PressDetector(
                width: width,
                height: height,
                hourHeight: hourHeight,
                date: date,
                onDateLongPress: onDateLongPress,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: EventGenerator<T>(
                  height: height,
                  date: date,
                  onTileTap: onTileTap,
                  eventArranger: eventArranger,
                  events: controller
                      .getEventsOnDay(date)
                      .where((element) => !element.allDay)
                      .toList(),
                  heightPerMinute: heightPerMinute,
                  eventTileBuilder: eventTileBuilder,
                  width: width -
                      timeLineWidth -
                      hourIndicatorSettings.offset -
                      verticalLineOffset,
                ),
              ),
              TimeLine(
                height: height,
                hourHeight: hourHeight,
                timeLineBuilder: timeLineBuilder,
                timeLineOffset: timeLineOffset,
                timeLineWidth: timeLineWidth,
                key: ValueKey(heightPerMinute),
              ),
            ],
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding))
      ],
    );
  }
}
