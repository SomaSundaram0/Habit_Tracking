import 'dart:collection';


import 'package:flutter/material.dart';
import 'package:Habit_Tracking/constants.dart';
import 'package:Habit_Tracking/habits/habit.dart';

import 'package:Habit_Tracking/model/habit_data.dart';
import 'package:Habit_Tracking/model/Habit_Tracking_model.dart';
import 'package:Habit_Tracking/notifications.dart';
import 'package:Habit_Tracking/statistics/statistics.dart';

class HabitsManager extends ChangeNotifier {
  final Habit_TrackingModel _Habit_TrackingModel = Habit_TrackingModel();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late List<Habit> allHabits = [];
  bool _isInitialized = false;

  Habit? deletedHabit;
  Queue<Habit> toDelete = Queue();

  void initialize() async {
    await initModel();
    await Future.delayed(const Duration(seconds: 5));
    notifyListeners();
  }

  resetHabitsNotifications() {
    resetNotifications(allHabits);
  }

  initModel() async {
    await _Habit_TrackingModel.initDatabase();
    allHabits = await _Habit_TrackingModel.getAllHabits();
    _isInitialized = true;
    notifyListeners();
  }

  GlobalKey<ScaffoldMessengerState> get getScaffoldKey {
    return _scaffoldKey;
  }

  void hideSnackBar() {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
  }

  resetNotifications(List<Habit> habits) {
    for (var element in habits) {
      if (element.habitData.notification) {
        var data = element.habitData;
        setHabitNotification(data.id!, data.notTime, 'Habit_Tracking', data.title);
      }
    }
  }

  removeNotifications(List<Habit> habits) {
    for (var element in habits) {
      disableHabitNotification(element.habitData.id!);
    }
  }

  showErrorMessage(String message) {
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Habit_TrackingColors.red,
      ),
    );
  }

  List<Habit> get getAllHabits {
    return allHabits;
  }

  bool get isInitialized {
    return _isInitialized;
  }

  reorderList(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    Habit moved = allHabits.removeAt(oldIndex);
    allHabits.insert(newIndex, moved);
    updateOrder();
    _Habit_TrackingModel.updateOrder(allHabits);
    notifyListeners();
  }

  addEvent(int id, DateTime dateTime, List event) {
    _Habit_TrackingModel.insertEvent(id, dateTime, event);
  }

  deleteEvent(int id, DateTime dateTime) {
    _Habit_TrackingModel.deleteEvent(id, dateTime);
  }

  addHabit(
      String title,
      bool twoDayRule,
      String cue,
      String routine,
      String reward,
      bool showReward,
      bool advanced,
      bool notification,
      TimeOfDay notTime,
      String sanction,
      bool showSanction,
      String accountant) {
    Habit newHabit = Habit(
      habitData: HabitData(
        position: allHabits.length,
        title: title,
        twoDayRule: twoDayRule,
        cue: cue,
        routine: routine,
        reward: reward,
        showReward: showReward,
        advanced: advanced,
        events: SplayTreeMap<DateTime, List>(),
        notification: notification,
        notTime: notTime,
        sanction: sanction,
        showSanction: showSanction,
        accountant: accountant,
      ),
    );
    _Habit_TrackingModel.insertHabit(newHabit).then(
      (id) {
        newHabit.setId = id;
        allHabits.add(newHabit);
        if (notification) {
          setHabitNotification(id, notTime, 'Habit_Tracking', title);
        } else {
          disableHabitNotification(id);
        }
        notifyListeners();
      },
    );
    updateOrder();
  }

  editHabit(HabitData habitData) {
    Habit? hab = findHabitById(habitData.id!);
    if (hab == null) return;
    hab.habitData.title = habitData.title;
    hab.habitData.twoDayRule = habitData.twoDayRule;
    hab.habitData.cue = habitData.cue;
    hab.habitData.routine = habitData.routine;
    hab.habitData.reward = habitData.reward;
    hab.habitData.showReward = habitData.showReward;
    hab.habitData.advanced = habitData.advanced;
    hab.habitData.notification = habitData.notification;
    hab.habitData.notTime = habitData.notTime;
    hab.habitData.sanction = habitData.sanction;
    hab.habitData.showSanction = habitData.showSanction;
    hab.habitData.accountant = habitData.accountant;
    _Habit_TrackingModel.editHabit(hab);
    if (habitData.notification) {
      setHabitNotification(
          habitData.id!, habitData.notTime, 'Habit_Tracking', habitData.title);
    } else {
      disableHabitNotification(habitData.id!);
    }
    notifyListeners();
  }

  String getNameOfHabit(int id) {
    Habit? hab = findHabitById(id);
    return (hab != null) ? hab.habitData.title : "";
  }

  Habit? findHabitById(int id) {
    Habit? result;
    for (var hab in allHabits) {
      if (hab.habitData.id == id) {
        result = hab;
      }
    }
    return result;
  }

  deleteHabit(int id) {
    deletedHabit = findHabitById(id);
    allHabits.remove(deletedHabit);
    toDelete.addLast(deletedHabit!);
    Future.delayed(const Duration(seconds: 4), () => deleteFromDB());
    _scaffoldKey.currentState!.hideCurrentSnackBar();
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text("Habit deleted."),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoDeleteHabit(deletedHabit!);
          },
        ),
      ),
    );
    updateOrder();
    notifyListeners();
  }

  undoDeleteHabit(Habit del) {
    toDelete.remove(del);
    if (deletedHabit != null) {
      if (deletedHabit!.habitData.position < allHabits.length) {
        allHabits.insert(deletedHabit!.habitData.position, deletedHabit!);
      } else {
        allHabits.add(deletedHabit!);
      }
    }

    updateOrder();
    notifyListeners();
  }

  Future<void> deleteFromDB() async {
    if (toDelete.isNotEmpty) {
      disableHabitNotification(toDelete.first.habitData.id!);
      _Habit_TrackingModel.deleteHabit(toDelete.first.habitData.id!);
      toDelete.removeFirst();
    }
    if (toDelete.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () => deleteFromDB());
    }
  }

  updateOrder() {
    int iterator = 0;
    for (var habit in allHabits) {
      habit.habitData.position = iterator++;
    }
  }

  Future<AllStatistics> getFutureStatsData() async {
    return await Statistics.calculateStatistics(allHabits);
  }
}
