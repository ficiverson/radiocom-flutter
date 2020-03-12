import 'dart:async';
import 'package:countdown/countdown.dart';

typedef void CurrentTimerCallback(bool finnish);
typedef void CurrentDurationCallback(Duration time);

abstract class CurrentTimerContract {
  void startTimer(Duration time);
  void stopTimer();
  bool isTimerRunning();
  int currentTime;
  CurrentTimerCallback timerCallback;
  CurrentTimerCallback timerControlsCallback;
  CurrentDurationCallback timeControlsDurationCallback;
}

class CurrentTimer implements CurrentTimerContract {
  bool isStarted = false;
  @override
  CurrentTimerCallback timerCallback;
  @override
  CurrentTimerCallback timerControlsCallback;
  @override
  CurrentDurationCallback timeControlsDurationCallback;
  @override
  int currentTime = 0;
  CountDown countDown;
  StreamSubscription subscription;

  void timerToWait() {}

  @override
  bool isTimerRunning() {
    return isStarted;
  }

  @override
  void startTimer(Duration time) {
    if (currentTime != 0) {
      isStarted = true;
      countDown = CountDown(time);
      subscription = countDown.stream.listen(null);
      subscription.onData((data) {
        if (timeControlsDurationCallback != null) {
          timeControlsDurationCallback(data);
        }
      });
      subscription.onDone(() {
        if (timerCallback != null && currentTime != 0) {
          timerCallback(true);
        }else if (timerControlsCallback != null && currentTime != 0) {
          timerControlsCallback(true);
        }
        stopTimer();
      });
    }
  }

  @override
  void stopTimer() {
    isStarted = false;
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    currentTime = 0;
  }
}
