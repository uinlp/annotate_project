import 'package:uinlp_annotate/repositories/base.dart';
import 'package:uinlp_annotate/models/user_stats.dart';

final class UserRepository extends BaseRepository {
  UserRepository() : super();

  Future<UserStatsModel> getUserStatsModel() async {
    await Future.delayed(const Duration(seconds: 1));
    return const UserStatsModel(
      tasksCompleted: 142,
      tasksInProgress: 5,
      hoursSpent: 28,
      accuracy: 0.94,
    );
  }
}
