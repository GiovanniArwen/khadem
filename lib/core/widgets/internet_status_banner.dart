import 'package:flutter/material.dart';

import '../services/internet_connection_service.dart';

class InternetStatusBanner extends StatelessWidget {
  final Widget child;

  const InternetStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InternetConnectionService.instance.isConnected,
      builder: (context, isConnected, _) {
        return Stack(
          children: [
            child,

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    );
                  },
                  child: isConnected
                      ? const SizedBox(
                          key: ValueKey('connected'),
                        )
                      : SafeArea(
                          key: const ValueKey('disconnected'),
                          bottom: false,
                          child: Material(
                            elevation: 6,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.wifi_off_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'لا يوجد اتصال بالإنترنت',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'بعض خدمات التطبيق قد لا تكون متاحة حاليًا.',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}