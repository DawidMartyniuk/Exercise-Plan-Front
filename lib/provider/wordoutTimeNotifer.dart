import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
class WordoutTimenotifer extends StateNotifier<int>{
  WordoutTimenotifer() : super(0);

  Timer? _timer;
  bool _isRunning = false;

  int? _startHour;
  int? _startMinute;


  void startTimer(){
    if (_isRunning) return;
    _isRunning = true;
    final nowTime = DateTime.now();
    _startHour = nowTime.hour;
    _startMinute = nowTime.minute;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state++;
    });
  }

  void stopTimer(){
    if(_isRunning){
      _timer?.cancel();
      _isRunning = false;
      state = 0; 
    }
  }
  void resetTimer(){
    stopTimer();
    state = 0;
  }
  bool get isRunning => _isRunning;
  int get currentTime => state;
  
  int? get startHour => _startHour;
  int? get startMinute => _startMinute;

}
final workoutProvider = StateNotifierProvider<WordoutTimenotifer, int>((ref){
  return WordoutTimenotifer();
});
