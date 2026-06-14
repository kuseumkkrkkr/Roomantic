import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:roomantic/controllers/match_controller.dart';
import 'package:roomantic/screens/match_screen.dart';
import 'package:roomantic/utils/match_ui_helper.dart';
import 'package:flutter/material.dart';

class FakeMatchController extends MatchController {
  @override
  void onInit() {}

  @override
  void onClose() {}
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  test('grade mapping follows score thresholds', () {
    expect(MatchUiHelper.gradeFromScore(90).label, '매우 잘 맞음');
    expect(MatchUiHelper.gradeFromScore(80).label, '잘 맞음');
    expect(MatchUiHelper.gradeFromScore(70).label, '조율 필요');
    expect(MatchUiHelper.gradeFromScore(50).label, '신중 검토');
  });

  test('summary fallback is safe when detail is missing', () {
    final summary = MatchUiHelper.summaryFrom({
      'candidate_type': 'individual',
      'score': 72.3,
    });
    expect(summary.subtitle, '일치율 72.3%');
    expect(summary.strengths.isNotEmpty, isTrue);
    expect(summary.cautions.isNotEmpty, isTrue);
  });

  testWidgets('match card exposes profile-first action', (tester) async {
    final ctrl = Get.put<MatchController>(FakeMatchController());
    ctrl.poolCandidates.assignAll([
      {
        'candidate_type': 'individual',
        'score': 81.2,
        'detail': {'sleep': 88, 'clean': 90, 'noise': 63},
        'profile': {'name': '김테현', 'user_uid': 'u-1'},
        'member_names': ['김테현'],
        'member_scores': [81.2],
      },
    ]);

    await tester.pumpWidget(const GetMaterialApp(home: MatchScreen()));
    await tester.pump();

    expect(find.text('프로필 보기'), findsOneWidget);
    expect(find.text('채팅 시작'), findsNothing);
  });
}
