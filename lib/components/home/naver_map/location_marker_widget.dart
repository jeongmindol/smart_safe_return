import 'package:flutter/material.dart';

class LocationMarkerWidget extends StatefulWidget {
  final String? currentAddress;
  final String? clickedAddress;
  final VoidCallback? onRouteRequest;
  final bool isRouteFetched;
  final String? estimatedTime;
  final VoidCallback? onStartSafety;
  final Function(int)? onAdjustTime;

  const LocationMarkerWidget({
    super.key,
    this.currentAddress,
    this.clickedAddress,
    this.onRouteRequest,
    this.isRouteFetched = false,
    this.estimatedTime,
    this.onStartSafety,
    this.onAdjustTime,
  });

  @override
  State<LocationMarkerWidget> createState() => _LocationMarkerWidgetState();
}

class _LocationMarkerWidgetState extends State<LocationMarkerWidget> {
  @override
  void didUpdateWidget(covariant LocationMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 도착 위치가 변경되었고, null이 아닐 때 자동으로 길찾기 실행
    if (widget.clickedAddress != null &&
        widget.clickedAddress != oldWidget.clickedAddress) {
      widget.onRouteRequest?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 현재 위치
        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: _buildAddressContainer(
            "현재 위치 : ",
            widget.currentAddress ?? "주소를 불러오는 중...",
          ),
        ),

        // 도착 위치
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: _buildAddressContainer(
            "도착 위치 : ",
            widget.clickedAddress ?? "지도를 클릭해 위치를 선택하세요",
          ),
        ),

        // ⏱ 예상 도착 시간 + 조절 버튼
        if (widget.estimatedTime != null)
          Positioned(
            top: 160,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => widget.onAdjustTime?.call(-5),
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    "예상 도착 시간: ${widget.estimatedTime}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onAdjustTime?.call(5),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),

        // 버튼: "안전 귀가 시작" (도착 위치가 있어야 활성화됨)
        Positioned(
          bottom: 30,
          left: 50,
          right: 50,
          child: ElevatedButton(
            onPressed: widget.isRouteFetched && widget.clickedAddress != null
                ? widget.onStartSafety
                : null, // 도착 위치 없으면 비활성화
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (widget.clickedAddress != null && widget.isRouteFetched)
                      ? Colors.blue
                      : Colors.grey, // 도착 위치 없으면 비활성화 색상
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "안전 귀가 시작",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressContainer(String title, String address) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Text(
        "$title $address",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
