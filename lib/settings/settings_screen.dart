import 'package:flutter/material.dart';
import 'package:Habit_Tracking/constants.dart';
import 'package:Habit_Tracking/navigation/app_state_manager.dart';
import 'package:Habit_Tracking/navigation/routes.dart';
import 'package:Habit_Tracking/notifications.dart';
import 'package:Habit_Tracking/settings/color_icon.dart';
import 'package:Habit_Tracking/settings/settings_manager.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.settingsPath,
      key: ValueKey(Routes.settingsPath),
      child: const SettingsScreen(),
    );
  }

  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  Future<void> testTime(context) async {
    TimeOfDay? selectedTime;
    TimeOfDay initialTime =
        Provider.of<SettingsManager>(context, listen: false).getDailyNot;
    selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      Provider.of<SettingsManager>(context, listen: false).setDailyNot =
          selectedTime;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (
        context,
        appStateManager,
        child,
      ) {
        return LoaderOverlay(
          useDefaultLoading: false,
          overlayWidget: const Center(
            child: CircularProgressIndicator(
              color: Habit_TrackingColors.primary,
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Settings',
              ),
              backgroundColor: Colors.transparent,
              iconTheme: Theme.of(context).iconTheme,
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text("Theme"),
                      trailing: DropdownButton<String>(
                        items: Provider.of<SettingsManager>(context)
                            .getThemeList
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                        value: Provider.of<SettingsManager>(context)
                            .getThemeString,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setTheme = value!;
                        },
                      ),
                    ),
                    ListTile(
                      title: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("First day of the week"),
                          SizedBox(width: 5),
                        ],
                      ),
                      trailing: DropdownButton<String>(
                        alignment: Alignment.center,
                        items: Provider.of<SettingsManager>(context)
                            .getWeekStartList
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            alignment: Alignment.center,
                            value: value,
                            child: Text(
                              value,
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                        value:
                            Provider.of<SettingsManager>(context).getWeekStart,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setWeekStart = value!;
                        },
                      ),
                    ),
                    if (platformSupportsNotifications())
                      ListTile(
                        title: const Text("Notifications"),
                        trailing: Switch(
                          value: Provider.of<SettingsManager>(context)
                              .getShowDailyNot,
                          onChanged: (value) async {
                            Provider.of<SettingsManager>(context, listen: false)
                                .setShowDailyNot = value;
                          },
                        ),
                      ),
                    if (platformSupportsNotifications())
                      ListTile(
                        enabled: Provider.of<SettingsManager>(context)
                            .getShowDailyNot,
                        title: const Text("Notification time"),
                        trailing: InkWell(
                          onTap: () {
                            if (Provider.of<SettingsManager>(context,
                                    listen: false)
                                .getShowDailyNot) {
                              testTime(context);
                            }
                          },
                          child: Text(
                            "${Provider.of<SettingsManager>(context).getDailyNot.hour.toString().padLeft(2, '0')}"
                            ":"
                            "${Provider.of<SettingsManager>(context).getDailyNot.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                                color: (Provider.of<SettingsManager>(context)
                                        .getShowDailyNot)
                                    ? null
                                    : Theme.of(context).disabledColor),
                          ),
                        ),
                      ),
                    ListTile(
                      title: const Text("Sound effects"),
                      trailing: Switch(
                        value: Provider.of<SettingsManager>(context)
                            .getSoundEffects,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setSoundEffects = value;
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text("Show month name"),
                      trailing: Switch(
                        value: Provider.of<SettingsManager>(context)
                            .getShowMonthName,
                        onChanged: (value) {
                          Provider.of<SettingsManager>(context, listen: false)
                              .setShowMonthName = value;
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text("Set colors"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColorIcon(
                            color: Provider.of<SettingsManager>(context,
                                    listen: false)
                                .checkColor,
                            icon: Icons.check,
                            defaultColor: Habit_TrackingColors.primary,
                            onPicked: (value) {
                              Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .checkColor = value;
                            },
                          ),
                          ColorIcon(
                            color: Provider.of<SettingsManager>(context,
                                    listen: false)
                                .failColor,
                            icon: Icons.close,
                            defaultColor: Habit_TrackingColors.red,
                            onPicked: (value) {
                              Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .failColor = value;
                            },
                          ),
                          ColorIcon(
                            color: Provider.of<SettingsManager>(context,
                                    listen: false)
                                .skipColor,
                            icon: Icons.last_page,
                            defaultColor: Habit_TrackingColors.skip,
                            onPicked: (value) {
                              Provider.of<SettingsManager>(context,
                                      listen: false)
                                  .skipColor = value;
                            },
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text("Onboarding"),
                      onTap: () {
                        // navigateToOnboarding(context);
                        Provider.of<AppStateManager>(context, listen: false)
                            .goOnboarding(true);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
