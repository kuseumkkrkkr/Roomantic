"""Data models for roommate matching backend."""

from dataclasses import dataclass, field, asdict
from typing import Optional, List
import json
import math
import uuid


@dataclass
class User:
    uid: str = field(default_factory=lambda: str(uuid.uuid4()))
    login_id: str = ""           # 로그인용 ID
    student_id: str = ""         # 학번 (정보용)
    password_hash: str = ""
    name: str = ""
    is_enrolled: int = 1         # 1=재학중(학교설정), 0=재학중아님(지역설정)
    school_name: str = ""        # 학교명
    region_name: str = ""        # 지역명


@dataclass
class RoommateProfile:
    """Logical model for a roommate checklist entry."""

    # Storage metadata
    uid: str = field(default_factory=lambda: str(uuid.uuid4()))
    user_uid: str = ""
    persona: Optional[str] = None

    # 기본 인적 사항 (이름/학번은 User에서 자동 연동)
    name: str = ""
    student_id: str = ""
    birth_year: int = 2005
    college: str = ""
    department: str = ""
    dorm_duration: int = 1

    # 생활 습관 (향/음주/운동/게임 등)
    home_visit_cycle: int = 2       # 귀가 주기 (시간/주)
    perfume: int = 0
    indoor_scent_sensitivity: int = 3
    alcohol_tolerance: float = 2.5
    alcohol_frequency: int = 2      # 음주 빈도 (주 횟수)
    drunk_habit: int = 0
    gaming_hours_per_week: int = 10 # 게임/스크린 (주)
    speaker_use: int = 0
    exercise: int = 0

    # 수면 습관
    bedtime: int = 23               # 취침시간 (0-23, 미정 삭제)
    wake_time: int = 8
    sleep_habit: int = 0
    sleep_sensitivity: int = 3      # 수면 예민도 (잠귀)
    alarm_strength: int = 3         # 알람 잘 들음?
    sleep_light: int = 0            # 수면등
    snoring: int = 0

    # 위생/욕실 사용
    shower_duration: int = 15       # 샤워시간 5분단위: 10,15,20,30,31(30+)
    shower_time: int = 22
    shower_cycle: int = 2           # 0=하루2회이상,1=하루2회,2=하루1회,3=2일1회,4=3일1회미만
    cleaning_cycle: int = 7
    ventilation: float = 1.0
    hairdryer_in_bathroom: int = 1  # 드라이기 실내사용
    toilet_paper_share: int = 1
    indoor_eating: int = 0
    smoking: int = 0

    # 생활 편의
    temperature_pref: int = 3       # 1-5 더위 <-> 추위
    indoor_call: int = 0
    bug_handling: int = 3           # 1-5 잡아 -> 못잡아
    laundry_cycle: int = 7
    drying_rack: int = 1
    fridge_use: int = 1
    study_in_room: int = 0          # 긱사내 공부
    noise_sensitivity: int = 3

    # 친밀도/교류
    desired_intimacy: int = 3       # 향후 룸매와의 친밀도
    meal_together: int = 2
    exercise_together: int = 1
    friend_invite: int = 1          # 0=X, 1=사전허락, 2=항상


def _circular_distance(a: int, b: int, period: int = 24) -> float:
    diff = abs(a - b) % period
    return min(diff, period - diff)


def classify_persona(p: RoommateProfile) -> str:
    """8가지 기숙사 대표 유형 분류."""
    scores = {}

    # 1. 독서실형
    scores["독서실형"] = 0
    if p.study_in_room:
        scores["독서실형"] += 3
    if p.noise_sensitivity >= 4:
        scores["독서실형"] += 2
    if p.speaker_use == 0:
        scores["독서실형"] += 1
    if p.gaming_hours_per_week <= 5:
        scores["독서실형"] += 1
    if 22 <= p.bedtime <= 24 or 0 <= p.bedtime <= 1:
        scores["독서실형"] += 1
    if p.friend_invite == 0:
        scores["독서실형"] += 1
    if p.desired_intimacy <= 2:
        scores["독서실형"] += 1

    # 2. 자취감성형
    scores["자취감성형"] = 0
    if p.indoor_scent_sensitivity >= 4:
        scores["자취감성형"] += 2
    if p.indoor_eating:
        scores["자취감성형"] += 1
    if p.fridge_use:
        scores["자취감성형"] += 1
    if p.toilet_paper_share:
        scores["자취감성형"] += 1
    if p.ventilation >= 3:
        scores["자취감성형"] += 1
    if p.temperature_pref != 3:
        scores["자취감성형"] += 1
    if p.cleaning_cycle <= 7:
        scores["자취감성형"] += 1

    # 3. 야행성게이머형
    scores["야행성게이머형"] = 0
    if p.gaming_hours_per_week >= 15:
        scores["야행성게이머형"] += 3
    if 1 <= p.bedtime <= 5:
        scores["야행성게이머형"] += 2
    if p.alarm_strength >= 4:
        scores["야행성게이머형"] += 1
    if p.speaker_use:
        scores["야행성게이머형"] += 1
    if p.home_visit_cycle <= 1:
        scores["야행성게이머형"] += 1

    # 4. FM군대형
    scores["FM군대형"] = 0
    if p.cleaning_cycle <= 3:
        scores["FM군대형"] += 2
    if p.shower_cycle <= 1:
        scores["FM군대형"] += 2
    if p.laundry_cycle <= 3:
        scores["FM군대형"] += 1
    if p.hairdryer_in_bathroom:
        scores["FM군대형"] += 1
    if p.desired_intimacy >= 3:
        scores["FM군대형"] += 1
    if p.shower_duration <= 15:
        scores["FM군대형"] += 1

    # 5. 생존형
    scores["생존형"] = 0
    if p.cleaning_cycle >= 14:
        scores["생존형"] += 2
    if p.shower_cycle >= 3:
        scores["생존형"] += 2
    if p.fridge_use == 0:
        scores["생존형"] += 1
    if p.desired_intimacy <= 2:
        scores["생존형"] += 1
    if p.study_in_room == 0:
        scores["생존형"] += 1
    if p.noise_sensitivity <= 2:
        scores["생존형"] += 1

    # 6. 공동체형
    scores["공동체형"] = 0
    if p.desired_intimacy >= 4:
        scores["공동체형"] += 2
    if p.meal_together >= 2:
        scores["공동체형"] += 1
    if p.exercise_together >= 2:
        scores["공동체형"] += 1
    if p.friend_invite == 2:
        scores["공동체형"] += 2
    elif p.friend_invite == 1:
        scores["공동체형"] += 1

    # 7. 생활분리형
    scores["생활분리형"] = 0
    if p.desired_intimacy <= 2:
        scores["생활분리형"] += 2
    if p.toilet_paper_share == 0:
        scores["생활분리형"] += 1
    if p.indoor_call == 0:
        scores["생활분리형"] += 1
    if p.friend_invite == 0:
        scores["생활분리형"] += 1
    if p.meal_together <= 1:
        scores["생활분리형"] += 1

    # 8. 수면민감형
    scores["수면민감형"] = 0
    if p.sleep_sensitivity >= 4:
        scores["수면민감형"] += 3
    if p.sleep_light:
        scores["수면민감형"] += 1
    if 22 <= p.bedtime <= 24 or 0 <= p.bedtime <= 1:
        scores["수면민감형"] += 1
    if p.snoring == 0:
        scores["수면민감형"] += 1
    if p.noise_sensitivity >= 4:
        scores["수면민감형"] += 1

    best = max(scores, key=scores.get)
    return best


def profile_to_vector(p: RoommateProfile) -> List[float]:
    """Convert a profile to a normalized vector in fixed order."""
    v: List[float] = []

    # 향/음주/게임
    v.append((p.home_visit_cycle) / 4)
    v.append(float(p.perfume))
    v.append((p.indoor_scent_sensitivity - 1) / 4)
    v.append((p.alcohol_tolerance - 1) / 4)
    v.append((p.alcohol_frequency) / 7)
    v.append(float(p.drunk_habit))
    v.append(min(p.gaming_hours_per_week / 40, 1.0))
    v.append(float(p.speaker_use))
    v.append(float(p.exercise))

    # 수면
    v.append(_circular_distance(p.bedtime % 24, 0) / 12)
    v.append(_circular_distance(p.wake_time, 0) / 12)
    v.append(float(p.sleep_habit))
    v.append((p.sleep_sensitivity - 1) / 4)
    v.append((p.alarm_strength - 1) / 4)
    v.append(float(p.sleep_light))
    v.append(float(p.snoring))

    # 위생/욕실
    shower_dur_map = {10: 0, 15: 0.25, 20: 0.5, 30: 0.75, 31: 1.0}
    v.append(shower_dur_map.get(p.shower_duration, 0.25))
    v.append(_circular_distance(p.shower_time, 0) / 12)
    v.append(p.shower_cycle / 4)
    cleaning_map = {1: 0, 3: 0.25, 7: 0.5, 14: 0.75, 30: 1.0}
    v.append(cleaning_map.get(p.cleaning_cycle, 0.5))
    vent_map = {0.5: 0, 1: 0.25, 2: 0.5, 4: 0.75, 5: 1.0}
    v.append(vent_map.get(p.ventilation, 0.25))
    v.append(float(p.hairdryer_in_bathroom))
    v.append(float(p.toilet_paper_share))
    v.append(float(p.indoor_eating))
    v.append(float(p.smoking))

    # 생활 편의
    v.append((p.temperature_pref - 1) / 4)
    v.append(float(p.indoor_call))
    v.append((p.bug_handling - 1) / 4)
    laundry_map = {14: 0, 7: 0.25, 5: 0.5, 3: 0.75, 1: 1.0}
    v.append(laundry_map.get(p.laundry_cycle, 0.25))
    v.append(float(p.drying_rack))
    v.append(float(p.fridge_use))
    v.append(float(p.study_in_room))
    v.append((p.noise_sensitivity - 1) / 4)

    # 친밀도/교류
    v.append((p.desired_intimacy - 1) / 4)
    v.append((p.meal_together - 1) / 2)
    v.append((p.exercise_together - 1) / 2)
    v.append(p.friend_invite / 2)

    return v


def profile_to_json(p: RoommateProfile) -> str:
    return json.dumps(asdict(p), ensure_ascii=False)


def profile_from_json(s: str) -> RoommateProfile:
    d = json.loads(s)
    return RoommateProfile(**d)


def profile_to_dict(p: RoommateProfile) -> dict:
    return asdict(p)
