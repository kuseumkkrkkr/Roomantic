import '../models/profile.dart';

Map<String, double> calculatePersonaScores(Profile p) {
  final Map<String, double> scores = {};

  double s1 = 0;
  if (p.studyInRoom == 1) s1 += 3;
  if (p.noiseSensitivity >= 4) s1 += 2;
  if (p.speakerUse == 0) s1 += 1;
  if (p.gamingHoursPerWeek <= 5) s1 += 1;
  if (p.bedtime >= 22 || p.bedtime <= 1) s1 += 1;
  if (p.friendInvite == 0) s1 += 1;
  if (p.desiredIntimacy <= 2) s1 += 1;
  scores['학습집중형'] = (s1 / 10.0) * 100;

  double s2 = 0;
  if (p.indoorScentSensitivity >= 4) s2 += 2;
  if (p.indoorEating == 1) s2 += 1;
  if (p.fridgeUse == 1) s2 += 1;
  if (p.toiletPaperShare == 1) s2 += 1;
  if (p.ventilation >= 3) s2 += 1;
  if (p.temperaturePref != 3) s2 += 1;
  if (p.cleaningCycle <= 7) s2 += 1;
  scores['섬세감성형'] = (s2 / 8.0) * 100;

  double s3 = 0;
  if (p.gamingHoursPerWeek >= 15) s3 += 3;
  if (p.bedtime >= 1 && p.bedtime <= 5) s3 += 2;
  if (p.alarmStrength >= 4) s3 += 1;
  if (p.speakerUse == 1) s3 += 1;
  if (p.homeVisitCycle <= 1) s3 += 1;
  scores['야행성게이머형'] = (s3 / 8.0) * 100;

  double s4 = 0;
  if (p.cleaningCycle <= 3) s4 += 2;
  if (p.showerCycle <= 1) s4 += 2;
  if (p.laundryCycle <= 3) s4 += 1;
  if (p.hairdryerInBathroom == 1) s4 += 1;
  if (p.desiredIntimacy >= 3) s4 += 1;
  if (p.showerDuration <= 15) s4 += 1;
  scores['FM관리형'] = (s4 / 8.0) * 100;

  double s5 = 0;
  if (p.cleaningCycle >= 14) s5 += 2;
  if (p.showerCycle >= 3) s5 += 2;
  if (p.fridgeUse == 0) s5 += 1;
  if (p.desiredIntimacy <= 2) s5 += 1;
  if (p.studyInRoom == 0) s5 += 1;
  if (p.noiseSensitivity <= 2) s5 += 1;
  scores['생존형'] = (s5 / 8.0) * 100;

  double s6 = 0;
  if (p.desiredIntimacy >= 4) s6 += 2;
  if (p.mealTogether >= 2) s6 += 1;
  if (p.exerciseTogether >= 2) s6 += 1;
  if (p.friendInvite == 2) {
    s6 += 2;
  } else if (p.friendInvite == 1) {
    s6 += 1;
  }
  scores['공동체형'] = (s6 / 6.0) * 100;

  double s7 = 0;
  if (p.desiredIntimacy <= 2) s7 += 2;
  if (p.toiletPaperShare == 0) s7 += 1;
  if (p.indoorCall == 0) s7 += 1;
  if (p.friendInvite == 0) s7 += 1;
  if (p.mealTogether <= 1) s7 += 1;
  scores['생활분리형'] = (s7 / 6.0) * 100;

  double s8 = 0;
  if (p.sleepSensitivity >= 4) s8 += 3;
  if (p.sleepLight == 1) s8 += 1;
  if (p.bedtime >= 22 || p.bedtime <= 1) s8 += 1;
  if (p.snoring == 0) s8 += 1;
  if (p.noiseSensitivity >= 4) s8 += 1;
  scores['수면민감형'] = (s8 / 7.0) * 100;

  return Map<String, double>.fromEntries(
    scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
}

String calculateTopPersona(Profile p) {
  final scores = calculatePersonaScores(p);
  return scores.isEmpty ? '' : scores.keys.first;
}
