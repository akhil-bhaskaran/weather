import 'package:flutter/material.dart';
import 'dart:math' as math;

class BgContainer extends StatefulWidget {
  final String? weatherCondition; // 'sunny', 'cloudy', 'rainy', 'night', etc.

  const BgContainer({super.key, this.weatherCondition = 'clear'});

  @override
  State<BgContainer> createState() => _BgContainerState();
}

class _BgContainerState extends State<BgContainer>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _sunRayController;
  late AnimationController _atmosphereController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Cloud drifting animation
    _cloudController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Sun rays rotation
    _sunRayController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Atmospheric breathing effect
    _atmosphereController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    // Floating particles/stars
    _particleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _sunRayController.dispose();
    _atmosphereController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  LinearGradient _getWeatherGradient() {
    switch (widget.weatherCondition?.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Sky blue
            Color(0xFF98D8E8), // Light blue
            Color(0xFFFFF8DC), // Cream
            Color(0xFFFFE4B5), // Moccasin
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        );
      case 'night':
      case 'clear_night':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F23), // Deep night blue
            Color(0xFF1B1F3B), // Dark blue
            Color(0xFF2D1B69), // Purple
            Color(0xFF1A1A2E), // Dark purple
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      case 'cloudy':
      case 'overcast':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF708090), // Slate gray
            Color(0xFF778899), // Light slate gray
            Color(0xFFB0C4DE), // Light steel blue
            Color(0xFFDCDCDC), // Gainsboro
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      case 'rainy':
      case 'storm':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2F4F4F), // Dark slate gray
            Color(0xFF483D8B), // Dark slate blue
            Color(0xFF696969), // Dim gray
            Color(0xFF708090), // Slate gray
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1F3B), Color(0xFF3A295E), Color(0xFFBC8CF2)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(gradient: _getWeatherGradient()),
      child: Stack(
        children: [
          // Atmospheric glow effect
          AnimatedBuilder(
            animation: _atmosphereController,
            builder: (context, child) {
              return Positioned(
                top: -100,
                left: -50,
                right: -50,
                child: Container(
                  height: screenHeight * 0.6,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      colors: [
                        _getAtmosphereColor().withOpacity(
                          0.3 + _atmosphereController.value * 0.2,
                        ),
                        _getAtmosphereColor().withOpacity(
                          0.1 + _atmosphereController.value * 0.1,
                        ),
                        Colors.transparent,
                      ],
                      radius: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),

          // Sun/Moon element
          if (widget.weatherCondition != 'rainy' &&
              widget.weatherCondition != 'storm')
            AnimatedBuilder(
              animation: _sunRayController,
              builder: (context, child) {
                return Positioned(
                  right: 30,
                  top: screenHeight * 0.12,
                  child: Transform.rotate(
                    angle: _sunRayController.value * 2 * math.pi,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors:
                              widget.weatherCondition?.contains('night') == true
                                  ? [
                                    const Color(
                                      0xFFF5F5DC,
                                    ).withOpacity(0.8), // Moon
                                    const Color(0xFFE6E6FA).withOpacity(0.4),
                                    Colors.transparent,
                                  ]
                                  : [
                                    const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.9), // Sun
                                    const Color(0xFFFFA500).withOpacity(0.6),
                                    const Color(0xFFFF6347).withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                          radius: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                widget.weatherCondition?.contains('night') ==
                                        true
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.orange.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Floating clouds
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _cloudController,
              builder: (context, child) {
                double offset = (_cloudController.value + (index * 0.3)) % 1.0;
                return Positioned(
                  left: -100 + (offset * (screenWidth + 200)),
                  top: screenHeight * (0.15 + index * 0.12),
                  child: Opacity(
                    opacity: 0.7 - (index * 0.2),
                    child: Container(
                      width: 120 + (index * 20),
                      height: 60 + (index * 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Weather particles (stars for night, light particles for day)
          ...List.generate(8, (index) {
            return AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                double floatOffset =
                    math.sin(
                      (_particleController.value * 2 * math.pi) + (index * 0.5),
                    ) *
                    10;
                return Positioned(
                  left: (index * screenWidth / 8) + (index * 20),
                  top:
                      (screenHeight * 0.1) +
                      (index % 3 * screenHeight * 0.2) +
                      floatOffset,
                  child: Container(
                    width:
                        widget.weatherCondition?.contains('night') == true
                            ? 4
                            : 0,
                    height:
                        widget.weatherCondition?.contains('night') == true
                            ? 4
                            : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.weatherCondition?.contains('night') == true
                              ? Colors.white.withOpacity(0.8)
                              : Colors.white.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Rain effect (if rainy weather)
          if (widget.weatherCondition == 'rainy' ||
              widget.weatherCondition == 'storm')
            ...List.generate(20, (index) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  double rainOffset =
                      ((_particleController.value * screenHeight * 1.5) +
                          (index * 30)) %
                      (screenHeight + 100);
                  return Positioned(
                    left:
                        (index * screenWidth / 20) +
                        math.sin(index.toDouble()) * 20,
                    top: rainOffset - 100,
                    child: Container(
                      width: 2,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // Subtle vignette effect
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                radius: 1.2,
              ),
            ),
          ),

          // Content area - your weather widgets go here
          // Positioned.fill(
          //   child: YourWeatherContent(),
          // ),
        ],
      ),
    );
  }

  Color _getAtmosphereColor() {
    switch (widget.weatherCondition?.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return const Color(0xFFFFD700); // Golden
      case 'night':
      case 'clear_night':
        return const Color(0xFF9C27B0); // Purple
      case 'cloudy':
      case 'overcast':
        return const Color(0xFF90A4AE); // Blue grey
      case 'rainy':
      case 'storm':
        return const Color(0xFF546E7A); // Dark blue grey
      default:
        return const Color(0xFFBC8CF2);
    }
  }
}
