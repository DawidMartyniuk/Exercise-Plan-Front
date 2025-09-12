import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:work_plan_front/provider/TrainingSerssionNotifer.dart';
import 'package:work_plan_front/provider/authProvider.dart';
import 'package:work_plan_front/model/TrainingSesions.dart';
import 'package:work_plan_front/screens/home_dashboard/workoutCard/workout_card_compact.dart';
import 'package:work_plan_front/screens/home_dashboard/workout_info/workoutCard_info.dart'; // ✅ IMPORT WorkoutCardInfo

class ProfileCalenderPanel extends ConsumerStatefulWidget {
  const ProfileCalenderPanel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileCalenderState();
}

class _ProfileCalenderState extends ConsumerState<ProfileCalenderPanel> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authResponse = ref.read(authProviderLogin);
      if (authResponse != null) {
        ref.read(trainingSessionAsyncProvider.notifier).fetchSessions();
      }
    });
  }

  /// Zwraca liczbę tygodni pod rząd, w których były wykonywane treningi.
  int _getWorkoutNumberOfConsecutiveWeeks(List<TrainingSession> sessions) {
    if (sessions.isEmpty) return 0;
    // Zbierz unikalne tygodnie (year, weekNumber) z dat treningów
    final weekSet = <String>{};
    for (final session in sessions) {
      final date = session.startedAt;
      // ISO week number
      final dayOfYear = int.parse(DateTime(date.year, date.month, date.day)
          .difference(DateTime(date.year, 1, 1))
          .inDays
          .toString()) + 1;
      final weekNumber = ((dayOfYear - date.weekday + 10) ~/ 7);
      final key = '${date.year}-$weekNumber';
      weekSet.add(key);
    }

    // Zamień na listę i posortuj
    final sortedWeeks = weekSet.toList()
      ..sort((a, b) => a.compareTo(b));

    // Zlicz ile tygodni pod rząd
    int consecutive = 0;
    for (int i = 1; i < sortedWeeks.length; i++) {
      final prev = sortedWeeks[i - 1].split('-').map(int.parse).toList();
      final curr = sortedWeeks[i].split('-').map(int.parse).toList();
      // Jeśli tydzień jest bezpośrednio po poprzednim
      if ((curr[0] == prev[0] && curr[1] == prev[1] + 1) ||
          (curr[0] == prev[0] + 1 && prev[1] == 52 && curr[1] == 1)) {
        consecutive++;
      } else {
        consecutive = 1;
      }
    }
    return consecutive;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ UŻYJ ASYNCVALUE DO OBSŁUGI STANÓW
    final trainingSessionsAsync = ref.watch(trainingSessionAsyncProvider);
    
    return trainingSessionsAsync.when(
      // ✅ KÓŁKO ŁADOWANIA
      loading: () => Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading training sessions...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // ✅ BŁĄD ŁADOWANIA
      error: (error, stackTrace) => Container(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading training sessions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.read(trainingSessionAsyncProvider.notifier).fetchSessions(forceRefresh: true);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // ✅ DANE ZAŁADOWANE
      data: (trainingSessions) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ TYTUŁ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Training Calendar',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Strike weeks: ${_getWorkoutNumberOfConsecutiveWeeks(trainingSessions)}", // ✅ PRZEKAŻ LISTĘ
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // ✅ KALENDARZ
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(50),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: Theme.of(context).colorScheme.primary,
                  weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                  weekdayLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  firstDayOfWeek: 1,
                  controlsHeight: 50,
                  controlsTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  dayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  disabledDayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(75),
                  ),

                  dayBuilder: ({
                    required date,
                    textStyle,
                    decoration,
                    isSelected,
                    isDisabled,
                    isToday,
                  }) {
                    final training = _getTrainingForDate(date, trainingSessions);
                    final hasTraining = training != null;
                    
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: hasTraining 
                          ? Colors.green.withAlpha(178)
                          : ((isSelected != null && isSelected)
                              ? Theme.of(context).colorScheme.primary
                              : ((isToday != null && isToday)
                                  ? Theme.of(context).colorScheme.primary.withAlpha(76)
                                  : Colors.transparent)),
                        borderRadius: BorderRadius.circular(8),
                        border: hasTraining 
                          ? Border.all(color: Colors.green, width: 2)
                          : ((isToday != null && isToday)
                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                              : null),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: textStyle?.copyWith(
                            color: hasTraining || (isSelected ?? false)
                              ? Colors.white
                              : ((isToday != null && isToday)
                                  ? Theme.of(context).colorScheme.primary
                                  : textStyle?.color),
                            fontWeight: hasTraining 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                value: _selectedDates,
                onValueChanged: (dates) {
                  setState(() {
                    _selectedDates = dates;
                  });
                  if (dates.isNotEmpty) {
                    final selectedDate = dates.first!;
                    print("tap");
                    _handleDayTapped(selectedDate, trainingSessions);
                    Future.delayed(Duration.zero, () {
                      setState(() {
                        _selectedDates = [];
                      });
                    });
                  }
                },
              ),
            ),
            
            SizedBox(height: 16),
            
            // ✅ LEGENDA
            Row(
              children: [
                _buildLegendItem(Colors.green, "Training Day", context),
                SizedBox(width: 20),
                _buildLegendItem(Theme.of(context).colorScheme.primary, "Today", context),
              ],
            ),
            
            SizedBox(height: 20),
            
            // ✅ OSTATNIE TRENINGI
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            
            // ✅ LISTA OSTATNICH TRENINGÓW Z OBSŁUGĄ PUSTEJ LISTY
            trainingSessions.isEmpty 
              ? Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(127),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No workouts yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Start your first workout to see it here!',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: trainingSessions
                      .take(5) // ✅ TERAZ DZIAŁA BO trainingSessions TO List<TrainingSession>
                      .map((training) => _buildTrainingCard(training, context))
                      .toList(),
                ),
          ],
        );
      },
    );
  }

  // ✅ ZNAJDŹ TRENING DLA KONKRETNEGO DNIA
  TrainingSession? _getTrainingForDate(DateTime date, List<TrainingSession> sessions) {
    try {
      return sessions.firstWhere(
        (training) => 
          training.startedAt.year == date.year &&
          training.startedAt.month == date.month &&
          training.startedAt.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  // ✅ OBSŁUGA KLIKNIĘCIA W DZIEŃ
  void _handleDayTapped(DateTime date, List<TrainingSession> sessions) {
    final sessionsForDate = sessions.where((session) =>
      session.startedAt.year == date.year &&
      session.startedAt.month == date.month &&
      session.startedAt.day == date.day,
    ).toList();
    
    if (sessionsForDate.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkoutCard(
            allSessionsForDate: sessionsForDate,
            trainingSession: sessionsForDate.first,
            showAsFullScreen: true,  
          ),
        ),
      );
      print("✅ Przechodzę do treningu: ${sessionsForDate.first.exercise_table_name} z dnia ${date.day}/${date.month}/${date.year}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No workout on ${date.day}/${date.month}/${date.year}'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey[700],
        ),
      );
    }
  }

  // ✅ LEGENDA
  Widget _buildLegendItem(Color color, String label, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  //  KARTA TRENINGU
  Widget _buildTrainingCard(TrainingSession training, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: training.completed ? Theme.of(context).colorScheme.primary : Colors.orange,
          child: Icon(
            Icons.fitness_center,
            color: Colors.white,
          ),
        ),
        title: Text(training.exercise_table_name ?? 'Workout'),
        subtitle: Text(
          '${training.exercises.length} exercises • ${training.duration} min\n${training.startedAt.day}/${training.startedAt.month}/${training.startedAt.year}',
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutCardInfo(
                trainingSession: training,
              ),
            ),
          );
        },
      ),
    );
  }
}