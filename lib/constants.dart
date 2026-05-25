abstract interface class AppConstants {
  double get lowLimit;
  double get highLimit;
  double get activityLowLimit;
  double get activityHighLimit;
  int get pollingIntervalMinutes;

  double getLowLimit(bool isActivityInProgress);
  double getHighLimit(bool isActivityInProgress);
}
