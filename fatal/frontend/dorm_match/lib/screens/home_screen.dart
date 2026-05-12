import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'survey_screen.dart';
import 'match_screen.dart';
import 'login_screen.dart';
import 'persona_detail_screen.dart';
import 'notices_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = Get.find<AuthController>();
  final _profileCtrl = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _profileCtrl.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.user.value;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user?.name ?? '사용자'}님, 안녕하세요!',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '오늘도 좋은 룸메이트를 찾아보세요',
                          style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.snackbar(
                              '알림',
                              '새로운 알림이 없습니다.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color(0xFFE3F2FD),
                              colorText: const Color(0xFF1565C0),
                              margin: const EdgeInsets.all(16),
                              borderRadius: 16,
                            );
                          },
                          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7280)),
                        ),
                        IconButton(
                          onPressed: () {
                            _auth.logout();
                            Get.offAll(() => const LoginScreen());
                          },
                          icon: const Icon(Icons.logout_rounded, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hero card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0x3F2563EB), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            child: Text(
                              (user?.name ?? 'U').substring(0, 1),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? '사용자',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.isEnrolled == true ? (user?.studentId ?? '') : (user?.regionName ?? ''),
                                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        if (_profileCtrl.isLoading.value) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        }
                        if (_profileCtrl.profile.value == null) {
                          return _heroButton(
                            icon: Icons.warning_amber_rounded,
                            label: '설문조사를 먼저 작성해주세요',
                            subLabel: '클릭하여 설문지 추가하기',
                            onTap: () => Get.to(() => const SurveyScreen()),
                            bgColor: Colors.white.withValues(alpha: 0.15),
                          );
                        }
                        return Column(
                          children: [
                            _heroButton(
                              icon: Icons.check_circle_rounded,
                              label: '설문조사 완료',
                              subLabel: '내 유형 보기',
                              onTap: () {
                                final profile = _profileCtrl.profile.value;
                                if (profile != null) {
                                  Get.to(() => PersonaDetailScreen(profile: profile));
                                }
                              },
                              bgColor: Colors.white.withValues(alpha: 0.15),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Obx(() => Text(
                                _profileCtrl.persona.value.isNotEmpty
                                  ? '나의 유형: ${_profileCtrl.persona.value}'
                                  : '유형 분석 중...',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
                              )),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // 현재 매칭중인 기숙사 찾기 버튼
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: GestureDetector(
                  onTap: () => Get.to(() => const MatchScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0x3F7C3AED), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.apartment, color: Colors.white, size: 24),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '현재 매칭중인 기숙사 찾기',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '나와 꼭 맞는 기숙사 룸메이트를 찾아보세요',
                                style: TextStyle(fontSize: 12, color: Color(0xFFD8B4FE)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.people_alt_rounded,
                        label: '셰어하우스 모드',
                        color: const Color(0xFF2563EB),
                        onTap: () => Get.to(() => const MatchScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.apartment_rounded,
                        label: '자취방 찾기',
                        color: const Color(0xFF059669),
                        onTap: () {
                          Get.snackbar(
                            '준비 중',
                            '자취방 찾기 기능은 곧 업데이트됩니다.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: const Color(0xFFE3F2FD),
                            colorText: const Color(0xFF1565C0),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 16,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 나의 설문지
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: const Text(
                  '나의 설문지',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (_profileCtrl.isLoading.value) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  if (_profileCtrl.profile.value == null) {
                    return _surveyAlertCard();
                  }
                  return _surveyCompletedCard();
                }),
              ),
            ),

            // 내가 받은 후기 → 공지사항으로 이동
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '내가 받은 후기',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const NoticesScreen()),
                      child: const Text('공지사항 보기'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => Get.to(() => const NoticesScreen()),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.campaign_outlined, size: 48, color: Color(0xFF9CA3AF)),
                        SizedBox(height: 12),
                        Text('공지사항 확인하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                        SizedBox(height: 4),
                        Text('앱 업데이트 및 안내사항을 확인하세요', style: TextStyle(fontSize: 13, color: Color(0xFFB0B5BD))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _heroButton({
    required IconData icon,
    required String label,
    required String subLabel,
    required VoidCallback onTap,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(subLabel, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _surveyAlertCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const SurveyScreen()),
      child: Container(
        padding: const EdgeInsets.all(20),
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

  Widget _surveyCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Row(
        children: [
          Icon(Icons.fact_check_rounded, color: Color(0xFF059669), size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('설문조사 완료!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('설문 내용은 언제든 수정할 수 있어요', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Color(0xFF059669), size: 22),
        ],
      ),
    );
  }
}
