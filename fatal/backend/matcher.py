"""Roommate matching utilities."""

import math
from dataclasses import dataclass, asdict
from typing import List

from models import RoommateProfile, profile_to_vector

WEIGHTS = [
    1.0,  # home_visit_cycle
    1.5,  # perfume
    2.0,  # indoor_scent_sensitivity
    1.0,  # alcohol_tolerance
    1.5,  # alcohol_frequency
    2.0,  # drunk_habit
    1.0,  # gaming_hours_per_week
    2.0,  # speaker_use
    0.5,  # exercise
    3.0,  # bedtime
    3.0,  # wake_time
    2.0,  # sleep_habit
    2.5,  # sleep_sensitivity
    1.5,  # alarm_strength
    1.0,  # sleep_light
    3.0,  # snoring
    0.5,  # shower_duration
    1.0,  # shower_time
    1.5,  # shower_cycle
    2.0,  # cleaning_cycle
    1.0,  # ventilation
    0.5,  # hairdryer_in_bathroom
    0.5,  # toilet_paper_share
    2.0,  # indoor_eating
    3.0,  # smoking
    2.5,  # temperature_pref
    1.0,  # indoor_call
    0.5,  # bug_handling
    1.0,  # laundry_cycle
    0.5,  # drying_rack
    0.5,  # fridge_use
    1.0,  # study_in_room
    2.5,  # noise_sensitivity
    2.0,  # desired_intimacy
    1.0,  # meal_together
    0.5,  # exercise_together
    1.5,  # friend_invite
]


@dataclass
class MatchResult:
    profile_a: RoommateProfile
    profile_b: RoommateProfile
    score: float
    distance: float
    hard_block: bool
    block_reasons: list[str]
    detail: dict[str, float]

    def to_dict(self) -> dict:
        return {
            "profile_a": profile_to_dict(self.profile_a),
            "profile_b": profile_to_dict(self.profile_b),
            "score": self.score,
            "distance": self.distance,
            "hard_block": self.hard_block,
            "block_reasons": self.block_reasons,
            "detail": self.detail,
        }


def profile_to_dict(p: RoommateProfile) -> dict:
    return asdict(p)


def _hard_filters(a: RoommateProfile, b: RoommateProfile) -> list[str]:
    reasons = []
    if a.smoking != b.smoking:
        reasons.append("흡연/비흡연 불일치")
    bed_diff = abs(a.bedtime - b.bedtime) % 24
    bed_diff = min(bed_diff, 24 - bed_diff)
    if bed_diff >= 5:
        reasons.append(f"취침시간 차이 {bed_diff}h")
    if (a.snoring and b.sleep_sensitivity >= 4) or (b.snoring and a.sleep_sensitivity >= 4):
        reasons.append("코골이+예민")
    return reasons


def _category_score(va: list[float], vb: list[float]) -> dict[str, float]:
    slices = {
        "향/음주/게임": (0, 9),
        "수면": (9, 16),
        "위생": (16, 25),
        "생활": (25, 33),
        "교류": (33, 37),
    }
    result = {}
    for name, (s, e) in slices.items():
        w = WEIGHTS[s:e]
        diffs = [abs(va[i] - vb[i]) * w[i - s] for i in range(s, e)]
        max_d = sum(w)
        d = sum(diffs)
        result[name] = round((1 - d / max_d) * 100, 1)
    return result


def match(a: RoommateProfile, b: RoommateProfile) -> MatchResult:
    va = profile_to_vector(a)
    vb = profile_to_vector(b)
    dist = math.sqrt(sum(w * (x - y) ** 2 for w, x, y in zip(WEIGHTS, va, vb)))
    max_dist = math.sqrt(sum(WEIGHTS))
    score = (1 - dist / max_dist) * 100

    block_reasons = _hard_filters(a, b)
    if block_reasons:
        score = max(0.0, score - 30)
    detail = _category_score(va, vb)

    return MatchResult(
        profile_a=a,
        profile_b=b,
        score=round(score, 2),
        distance=round(dist, 4),
        hard_block=bool(block_reasons),
        block_reasons=block_reasons,
        detail=detail,
    )


def rank_matches(target: RoommateProfile, pool: List[RoommateProfile], top_n: int = 5, exclude_blocked: bool = False) -> List[MatchResult]:
    results = [match(target, p) for p in pool if p.uid != target.uid]
    if exclude_blocked:
        results = [r for r in results if not r.hard_block]
    results.sort(key=lambda r: r.score, reverse=True)
    return results[:top_n]


def best_pairings(profiles: List[RoommateProfile], exclude_blocked: bool = True) -> List[MatchResult]:
    n = len(profiles)
    all_pairs: List[MatchResult] = []
    for i in range(n):
        for j in range(i + 1, n):
            r = match(profiles[i], profiles[j])
            if exclude_blocked and r.hard_block:
                continue
            all_pairs.append(r)

    all_pairs.sort(key=lambda r: r.score, reverse=True)

    matched = set()
    pairings: List[MatchResult] = []
    for r in all_pairs:
        a_id = r.profile_a.uid
        b_id = r.profile_b.uid
        if a_id not in matched and b_id not in matched:
            pairings.append(r)
            matched.add(a_id)
            matched.add(b_id)
        if len(matched) >= n:
            break
    return pairings
