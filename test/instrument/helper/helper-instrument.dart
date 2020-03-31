import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/notification_subscription_contract.dart';
import 'package:mockito/mockito.dart';

class MockNotifcationSubscription extends Mock implements NotificationSubscriptionContract{}

class MockConnection extends Mock implements ConnectionContract {}

class MockPlayer extends Mock implements CurrentPlayerContract {}

void printMessages(List list) {
  list.forEach((data) {
    print(data.toString());
  });
}
