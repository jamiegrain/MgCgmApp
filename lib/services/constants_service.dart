import '../constants.dart';

class ConstantsService implements AppConstants {
  static final ConstantsService _instance = ConstantsService._internal();
  
  factory ConstantsService() {
    return _instance;
  }

  ConstantsService._internal();

  @override
  double get highLimit => 11.6;

  @override
  double get lowLimit => 4.0;

  @override
  double get activityHighLimit => 15.0;

  @override
  double get activityLowLimit => 6.0;

  @override
  int get pollingIntervalMinutes => 5;

  @override
  double getHighLimit(bool isActivityInProgress) => 
      isActivityInProgress ? activityHighLimit : highLimit;

  @override
  double getLowLimit(bool isActivityInProgress) => 
      isActivityInProgress ? activityLowLimit : lowLimit;
}
