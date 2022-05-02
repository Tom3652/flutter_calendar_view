// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'calendar_event_data.dart';
import 'typedefs.dart';

class EventController<T> extends ChangeNotifier {
  /// This method will provide list of events on particular date.
  ///
  /// This method is use full when you have recurring events.
  /// As of now this library does not support recurring events.
  /// You can implement same behaviour in this function.
  /// This function will overwrite default behaviour of [getEventsOnDay]
  /// function which will be used to display events on given day in
  /// [MonthView], [DayView] and [WeekView].
  ///
  final EventFilter<T>? eventFilter;

  /// Calendar controller to control all the events related operations like,
  /// adding event, removing event, etc.
  EventController({
    this.eventFilter,
  });

  // Stores events that occurs only once in a tree type structure.
  final _events = <_YearEvent<T>>[];

  // Stores all the events in a list.
  final _eventList = <CalendarEventData<T>>[];

  // Stores all the ranging events in a list.
  final _rangingEventList = <CalendarEventData<T>>[];

  //final Map<int, CalendarEventData<T>> _eventsMap = {};

  /// Returns list of [CalendarEventData<T>] stored in this controller.
  List<CalendarEventData<T>> get events => _eventList.toList(growable: false);

  String localization = "en";

  /// Add all the events in the list
  /// If there is an event with same date then
  void addAll(List<CalendarEventData<T>> events) {
    for (final event in events) {
      _addEvent(event);
    }

    notifyListeners();
  }

  /// Adds a single event in [_events]
  void add(CalendarEventData<T> event) {
    _addEvent(event);

    notifyListeners();
  }

  String getLocalizedDayForEvent() {
    if (localization == "fr") {
      return "Journée entière";
    }
    return "Entire day";
  }

  /// Removes all events
  void removeAllEvents() {
    _rangingEventList.clear();
    _events.clear();
    notifyListeners();
  }

  /// Removes [event] from this controller.
  void remove(CalendarEventData<T> event) {
    _eventList.removeWhere((element) => element.uid == event.uid);
    _events.forEach((element) {
      element.removeEvent(event);
    });
    _rangingEventList.removeWhere((element) => element.uid == event.uid);
    /*
    for (final e in _events) {
      if (e.year == event.date.year) {
        if (e.removeEvent(event) && _eventList.remove(event)) {
          notifyListeners();
          return;
        }

        break;
      }
    }

    for (final e in _rangingEventList) {
      if (e == event) {
        if (_rangingEventList.remove(event) && _eventList.remove(event)) {
          notifyListeners();
          return;
        }
        break;
      }
    }

     */
    notifyListeners();
  }

  void _addEvent(CalendarEventData<T> event) {
    assert(event.endDate.difference(event.date).inDays >= 0,
        'The end date must be greater or equal to the start date');

    if (event.endDate.difference(event.date).inDays > 0) {
      _rangingEventList.add(event);
      _eventList.add(event);
    } else {
      for (final e in _events) {
        if (e.year == event.date.year && e.addEvent(event)) {
          _eventList.add(event);
          notifyListeners();

          return;
        }
      }

      final newEvent = _YearEvent<T>(year: event.date.year);
      if (newEvent.addEvent(event)) {
        _events.add(newEvent);
        _eventList.add(event);
      }
    }

    notifyListeners();
  }

  /// Returns events on given day.
  ///
  /// To overwrite default behaviour of this function,
  /// provide [eventFilter] argument in [EventController] constructor.
  List<CalendarEventData<T>> getEventsOnDay(DateTime date) {
    if (eventFilter != null) return eventFilter!.call(date, this.events);

    final events = <CalendarEventData<T>>[];

    for (var i = 0; i < _events.length; i++) {
      events.addAll(_events[i]
          .getAllEvents()
          .where((ele) => ele.everyYear || ele.everyMonth || ele.everyWeek));
      if (_events[i].year == date.year) {
        final monthEvents = _events[i]._months;

        for (var j = 0; j < monthEvents.length; j++) {
          if (monthEvents[j].month == date.month) {
            final calendarEvents = monthEvents[j]._events;

            for (var k = 0; k < calendarEvents.length; k++) {
              if (calendarEvents[k].date.day == date.day)
                events.add(calendarEvents[k]);
            }
          }
        }
      }
    }

    //print("ranging events : $_rangingEventList");
    //print("get event in controller for date : $date");

    final daysFromRange = <DateTime>[];
    for (final rangingEvent in _rangingEventList) {
      //print("ranging event : $rangingEvent");
      for (var i = 0;
          i <= rangingEvent.endDate.difference(rangingEvent.date).inDays;
          i++) {
        daysFromRange.add(rangingEvent.date.add(Duration(days: i)));
      }
      //print("days from range : $daysFromRange");
      if (rangingEvent.date.isBefore(rangingEvent.endDate)) {
        for (final eventDay in daysFromRange) {
          //print("event day : $eventDay");

          //   print("event day : ${eventDay.day}");
          //  print("date day : ${date.day}");

          if (isToday(eventDay, date)) {
            events.add(rangingEvent);
          } else if (isInDayRangeForRecursive(rangingEvent, date)) {
            //print("Is recursive event");
            events.add(rangingEvent);
          }
        }
      }
    }

    //print("events :$events");
    events.removeWhere((element) => !isEventInRange(element, date));

    //print("events after :$events");

    final uniqueEvents = <CalendarEventData<T>>{}..addAll(events);

    //print("unique events : $uniqueEvents");

    return uniqueEvents.toList();
  }

  bool isToday(DateTime eventDay, DateTime date) {
    return eventDay.year == date.year &&
        eventDay.month == date.month &&
        eventDay.day == date.day;
  }

  bool isInDayRangeForRecursive(CalendarEventData eventData, DateTime date) {
    final firstDate = eventData.date;
    final lastDate = eventData.endDate;
    final isAfter = date.isAfter(firstDate);
    if (eventData.everyMonth) {
      final inMonth =
          date.day >= firstDate.day && date.day <= lastDate.day && isAfter;
      if (inMonth) {
        return true;
      }
    }
    if (eventData.everyYear) {
      final inYear =
          (date.month == firstDate.month || date.month == lastDate.month) &&
              date.year >= firstDate.year &&
              date.day >= firstDate.day &&
              date.day <= lastDate.day &&
              isAfter;
      if (inYear) {
        return true;
      }
    }
    if (eventData.everyWeek) {
      final weekDayStart = firstDate.weekday;
      final weekDayEnd = lastDate.weekday;
      final days = <int>[];

      var inWeek = ((date.weekday >= firstDate.weekday &&
          date.weekday <= lastDate.weekday)) && isAfter;
      if (weekDayEnd <= weekDayStart) {
        print("Week day end : $weekDayEnd and start : $weekDayStart");
        for (var i = weekDayStart; i < 7 + weekDayEnd; i++) {
          days.add(i % 7);
        }
        print("Days are : $days");
        inWeek = days.contains(date.weekday) && isAfter;
        print("Event ${eventData.title} in week : $inWeek");
      }

      if (inWeek) {
        return true;
      }
    }
    return false;
  }

  bool isEventInRange(
      CalendarEventData<T> calendarEventData, DateTime selectedDate) {
    //print("Selected date : ${selectedDate.toIso8601String()}");
    final start = calendarEventData.date;
    final end = calendarEventData.endDate;

    if ((isInDayRangeForRecursive(calendarEventData, selectedDate) ||
            isInDayRangeForRecursive(calendarEventData, selectedDate)) &&
        (calendarEventData.everyMonth ||
            calendarEventData.everyYear ||
            calendarEventData.everyWeek)) {
      return true;
    }
    //print("Event start date : ${start.toIso8601String()}");
    //print("Event end date : ${end.toIso8601String()}");
    if (isToday(start, selectedDate) || isToday(end, selectedDate)) {
      //print("is today return true : event in range");
      return true;
    }
    final differenceStart = selectedDate.millisecondsSinceEpoch -
        start
            .millisecondsSinceEpoch; //selectedDate.difference(start).inMilliseconds;
    final differenceEnd = end.millisecondsSinceEpoch -
        selectedDate
            .millisecondsSinceEpoch; // end.difference(selectedDate).inMilliseconds;
    //print("Difference start : $differenceStart");
    //print("Difference end : $differenceEnd");
    if (differenceStart >= 0 &&
        (differenceEnd >= 0 ||
            (differenceEnd < 0 && isToday(end, selectedDate)))) {
      //print("Start is before selected AND end is after selected so we don't remove");
      return true;
    }
    return false;
  }
}

class _YearEvent<T> {
  int year;
  final _months = <_MonthEvent<T>>[];

  List<_MonthEvent<T>> get months => _months.toList(growable: false);

  _YearEvent({required this.year});

  int hasMonth(int month) {
    for (var i = 0; i < _months.length; i++) {
      if (_months[i].month == month) return i;
    }
    return -1;
  }

  bool addEvent(CalendarEventData<T> event) {
    for (var i = 0; i < _months.length; i++) {
      if (_months[i].month == event.date.month) {
        return _months[i].addEvent(event);
      }
    }
    final newEvent = _MonthEvent<T>(month: event.date.month)..addEvent(event);
    _months.add(newEvent);
    return true;
  }

  List<CalendarEventData<T>> getAllEvents() {
    final totalEvents = <CalendarEventData<T>>[];
    for (var i = 0; i < _months.length; i++) {
      totalEvents.addAll(_months[i].events);
    }
    return totalEvents;
  }

  bool removeEvent(CalendarEventData<T> event) {
    for (final e in _months) {
      if (e.month == event.date.month) {
        return e.removeEvent(event);
      }
    }
    return false;
  }
}

class _MonthEvent<T> {
  int month;
  final _events = <CalendarEventData<T>>[];

  List<CalendarEventData<T>> get events => _events.toList(growable: false);

  _MonthEvent({required this.month});

  int hasDay(int day) {
    for (var i = 0; i < _events.length; i++) {
      if (_events[i].date.day == day) return i;
    }
    return -1;
  }

  bool addEvent(CalendarEventData<T> event) {
    if (!_events.contains(event)) {
      _events.add(event);
      return true;
    }
    return false;
  }

  bool removeEvent(CalendarEventData<T> event) {
    final index = _events.indexWhere((element) => element == event);
    if (index == -1) {
      return false;
    } else {
      _events.removeAt(index);
      return true;
    }
  }
}
