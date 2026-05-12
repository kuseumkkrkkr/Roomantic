import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'survey_screen.dart';
import 'persona_detail_screen.dart';
import 'notices_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();
    final user = auth.user.value;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '내 프로필',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Get.to(() => const NoticesScreen()),
                      icon: const Icon(Icons.campaign_outlined, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar + name
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (user?.name ?? 'U').substring(0, 1),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '사용자',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user?.schoolName ?? '학교 미지정'} · ${user?.studentId ?? ''}',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              profileCtrl.persona.value.isNotEmpty ? profileCtrl.persona.value : '유형 분석 필요',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Account info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: const Text(
                  '계정 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      _infoTile(Icons.person_outline, '로그인 ID', user?.loginId ?? '-'),
                      _divider(),
                      _infoTile(Icons.school_outlined, '학적 상태', user?.isEnrolled == true ? '재학 중' : '휴학 / 외부인'),
                      _divider(),
                      _infoTile(Icons.location_on_outlined, '거주 지역', user?.regionName ?? '-'),
                    ],
                  ),
                ),
              ),
            ),

            // 나의 유형 상세보기
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '나의 유형',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (profileCtrl.isLoading.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  if (profileCtrl.profile.value == null) {
                    return _surveyAlertCard();
                  }
                  return GestureDetector(
                    onTap: () {
                      final profile = profileCtrl.profile.value;
                      if (profile != null) {
                        Get.to(() => PersonaDetailScreen(profile: profile));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: const Color(0xFFEEEFFB), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('유형 상세보기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('8가지 유형과 나의 답변을 비교해보세요', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 매칭 이력 및 통계
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '매칭 이력 및 통계',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _statCard(
                      icon: Icons.favorite_outline,
                      title: '나를 선호하는 사람 유형',
                      subtitle: '실시간으로 업데이트되는 매칭 통계 데이터',
                      color: const Color(0xFFEC4899),
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      icon: Icons.send_outlined,
                      title: '내가 자주 매칭을 보낸 사람 유형',
                      subtitle: '나의 매칭 패턴을 분석한 결과',
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ),

            // 내가 받은 후기
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '내가 받은 후기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 12),
                      const Text('아직 받은 후기가 없어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text('매칭이 완료되면 상대방의 후기를 확인할 수 있어요', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),
            ),

            // 설문 상태
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '설문 상태',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (profileCtrl.isLoading.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  if (profileCtrl.profile.value == null) {
                    return _surveyAlertCard();
                  }
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 28),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('설문조사 완료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF065F46))),
                              SizedBox(height: 4),
                              Text('클릭하여 설문 내용을 수정할 수 있어요', style: TextStyle(fontSize: 13, color: Color(0xFF047857))),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const SurveyScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(12)),
                            child: const Text('수정', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade100, height: 1);
  }

  Widget _surveyAlertCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const SurveyScreen()),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions_rounded, color: Color(0xFFD97706), size: 28),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('설문지를 아직 작성하지 않으셨어요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                  SizedBox(height: 4),
                  Text('클릭하여 지금 작성해보세요', style: TextStyle(fontSize: 13, color: Color(0xFFB45309))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD97706)),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
