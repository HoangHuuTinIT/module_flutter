import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Một NotchedShape tùy chỉnh có thể tạo animation cho vết lõm (notch)
/// với các góc được bo tròn mềm mại (sử dụng đường cong Bézier bậc ba).
class AnimatedCircularNotch implements NotchedShape {
  const AnimatedCircularNotch({
    required this.growthAnimation,
    required this.notchMargin,
  });

  final Animation<double> growthAnimation;
  final double notchMargin;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest) || growthAnimation.value == 0.0) {
      return Path()..addRect(host);
    }

    final double fabDiameter = guest.width;
    final double notchRadius = (fabDiameter / 2.0 + notchMargin) * growthAnimation.value;

    final double verticalCenter = guest.center.dy;
    final double hostTop = host.top;
    final double verticalDistance = verticalCenter - hostTop;

    if (notchRadius < verticalDistance) {
      return Path()..addRect(host);
    }

    final double horizontalDistance = math.sqrt(notchRadius * notchRadius - verticalDistance * verticalDistance);

    final Offset p1 = Offset(guest.center.dx - horizontalDistance, hostTop);
    final Offset p2 = Offset(guest.center.dx + horizontalDistance, hostTop);

    // Các hằng số để điều khiển độ "uốn" của vai notch.
    final double curveWidth = 10.0 * growthAnimation.value;
    final double curveHeight = 3.0 * growthAnimation.value;

    return Path()
      ..moveTo(host.left, hostTop)
      ..lineTo(p1.dx - curveWidth, hostTop)

    // SỬA ĐỔI QUAN TRỌNG: Logic vẽ đường cong Bézier bậc ba mới
      ..cubicTo(
        // ĐIỂM KIỂM SOÁT 1: Giữ cho đường cong bắt đầu phẳng
        p1.dx - curveWidth * 0.1, // Tọa độ X
        hostTop,                   // Tọa độ Y (ngang bằng với mặt trên)

        // ĐIỂM KIỂM SOÁT 2: Kéo đường cong xuống để kết thúc mượt mà
        p1.dx,                     // Tọa độ X (thẳng hàng với điểm cuối)
        hostTop + curveHeight,     // Tọa độ Y (điều khiển độ sâu)

        // Điểm kết thúc
        p1.dx,                     // Tọa độ X
        p1.dy,                     // Tọa độ Y
      )

    // Vẽ cung tròn chính của notch
      ..arcToPoint(p2, radius: Radius.circular(notchRadius), clockwise: false)

    // Vẽ đường cong Bézier bậc ba cho vai phải
      ..cubicTo(
        // ĐIỂM KIỂM SOÁT 1
        p2.dx,                     // Tọa độ X
        hostTop + curveHeight,     // Tọa độ Y

        // ĐIỂM KIỂM SOÁT 2
        p2.dx + curveWidth * 0.1, // Tọa độ X
        hostTop,                   // Tọa độ Y

        // Điểm kết thúc
        p2.dx + curveWidth,        // Tọa độ X
        hostTop,                   // Tọa độ Y
      )

    // Vẽ nốt phần còn lại
      ..lineTo(host.right, hostTop)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}