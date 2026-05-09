import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'survey_screen.dart';
import 'match_screen.dart';
import 'login_screen.dart';

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
            // App bar
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
                    IconButton(
                      onPressed: () {
                        _auth.logout();
                        Get.offAll(() => const LoginScreen());
                      },
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),

            // Hero section - User profile card
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
                                  user?.studentId ?? '',
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
                        return _heroButton(
                          icon: Icons.check_circle_rounded,
                          label: '설문조사 완료',
                          subLabel: '내 유형 보기',
                          onTap: () => Get.to(() => const SurveyScreen()),
                          bgColor: Colors.white.withValues(alpha: 0.15),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _quickActionCard(
                        icon: Icons.people_alt_rounded,
                        label: '매칭 결과',
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

            // My Survey Section
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

            // Reviews Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '내가 받은 후기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
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
                      Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text('아직 받은 후기가 없습니다', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      const Text('매칭 후 후기를 남겨보세요', style: TextStyle(fontSize: 13, color: Color(0xFFB0B5BD))),
                    ],
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
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
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFEF3C7)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_circle_outline, color: Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('설문지 추가하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                  const SizedBox(height: 2),
                  Text('나의 생활 습관을 입력하고 매칭을 시작하세요', style: TextStyle(fontSize: 13, color: const Color(0xFFD97706).withValues(alpha: 0.8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFD97706), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _surveyCompletedCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const SurveyScreen()),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('설문조사 완료', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                  const SizedBox(height: 2),
                  const Text('내 유형 보기 / 수정하기', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 14),
          ],
        ),
      ),
    );
  }
}
