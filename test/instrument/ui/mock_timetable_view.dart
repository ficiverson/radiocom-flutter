import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/ui/timetable/time_table_router.dart';

enum TimeTableState {
  noConnection,
  onNewData,
  goToEpisode
}

class MockTimetableView implements TimeTableView{
  List<TimeTableState> viewState = [];
  List<dynamic> data = [];

  @override
  onConnectionError() {
    viewState.add(TimeTableState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(TimeTableState.onNewData);
  }
}

class MockTimeTableRouter implements TimeTableRouterContract {
  List<TimeTableState> viewState = [];
  List<dynamic> data = [];
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(TimeTableState.goToEpisode);
    data.add(episode);
  }

}