import 'package:flutter/material.dart';

class SleepWakeRangeSlider extends StatefulWidget {
  final int bedtime;
  final int wakeTime;
  final ValueChanged<int> onBedtimeChanged;
  final ValueChanged<int> onWakeTimeChanged;

  const SleepWakeRangeSlider({
    super.key,
    required this.bedtime,
    required this.wakeTime,
    required this.onBedtimeChanged,
    required this.onWakeTimeChanged,
  });

  @override
  State<SleepWakeRangeSlider> createState() => _SleepWakeRangeSliderState();
}

class _SleepWakeRangeSliderState extends State<SleepWakeRangeSlider> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final trackHeight = 48.0;
        final padding = const EdgeInsets.symmetric(horizontal: 24);
        final trackWidth = width - padding.horizontal;

        double valueToX(int value) {
          return padding.left + (value / 24) * trackWidth;
        }

        int xToValue(double x) {
          final localX = x - padding.left;
          final ratio = localX / trackWidth;
          return (ratio * 24).round().clamp(0, 24);
        }

        Widget buildHandle(int value, Color color, String label) {
          return Positioned(
            left: valueToX(value) - 16,
            top: (trackHeight - 32) / 2,
            child: GestureDetector(
              onPanUpdate: (details) {
                final newValue = xToValue(valueToX(value) + details.localPosition.dx);
                if (value == widget.bedtime) {
                  widget.onBedtimeChanged(newValue.clamp(0, 24));
                } else {
                  widget.onWakeTimeChanged(newValue.clamp(0, 24));
                }
              },
              onPanEnd: (_) {},
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('취침 / 기상 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.bedtime}시 취침',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.wakeTime}시 기상',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: trackHeight + 40,
              child: Stack(
                children: [
                  // Background track with day/night segments
                  Positioned(
                    left: padding.left,
                    top: (trackHeight - 24) / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: List.generate(24, (hour) {
                          final isWake = _isWakeHour(hour);
                          return Container(
                            width: trackWidth / 24,
                            height: 24,
                            color: isWake
                                ? const Color(0xFFE3F2FD)
                                : const Color(0xFF1A1A2E),
                          );
                        }),
                      ),
                    ),
                  ),
                  // Cloud icons for wake hours
                  ..._buildClouds(trackWidth, padding.left, trackHeight),
                  // Star icons for sleep hours
                  ..._buildStars(trackWidth, padding.left, trackHeight),
                  // Tick labels
                  ...List.generate(9, (i) {
                    final hour = i * 3;
                    return Positioned(
                      left: valueToX(hour) - 10,
                      top: trackHeight + 4,
                      child: SizedBox(
                        width: 20,
                        child: Text(
                          '$hour',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                      ),
                    );
                  }),
                  // Bedtime handle
                  buildHandle(widget.bedtime, const Color(0xFF1A1A2E), '취침'),
                  // Wake time handle
                  buildHandle(widget.wakeTime, const Color(0xFF1565C0), '기상'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isWakeHour(int hour) {
    // Simple logic: wake time to bedtime is awake
    if (widget.wakeTime <= widget.bedtime) {
      return hour >= widget.wakeTime && hour < widget.bedtime;
    } else {
      return hour >= widget.wakeTime || hour < widget.bedtime;
    }
  }

  List<Widget> _buildClouds(double trackWidth, double leftOffset, double trackHeight) {
    final widgets = <Widget>[];
    for (int hour = 0; hour < 24; hour++) {
      if (_isWakeHour(hour)) {
        widgets.add(
          Positioned(
            left: leftOffset + (hour / 24) * trackWidth + (trackWidth / 24 - 14) / 2,
            top: (trackHeight - 24) / 2 + 4,
            child: const Icon(Icons.cloud, size: 14, color: Color(0xFF90CAF9)),
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _buildStars(double trackWidth, double leftOffset, double trackHeight) {
    final widgets = <Widget>[];
    for (int hour = 0; hour < 24; hour++) {
      if (!_isWakeHour(hour)) {
        widgets.add(
          Positioned(
            left: leftOffset + (hour / 24) * trackWidth + (trackWidth / 24 - 10) / 2,
            top: (trackHeight - 24) / 2 + 6,
            child: const Icon(Icons.star, size: 10, color: Color(0xFFFFD700)),
          ),
        );
      }
    }
    return widgets;
  }
}
