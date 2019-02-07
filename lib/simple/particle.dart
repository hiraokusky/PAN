import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pimp_my_button/src/pimp_my_button.dart';

class FireworkParticle extends Particle {
  @override
  void paint(Canvas canvas, Size size, progress, seed) {
    Random random = Random(seed);
    int randomMirrorOffset = random.nextInt(8) + 1;
    CompositeParticle(children: [
      CircleMirror(
          numberOfParticles: 6,
          child: AnimatedPositionedParticle(
            begin: Offset(0.0, 20.0),
            end: Offset(0.0, 60.0),
            child: FadingRect(width: 5.0, height: 15.0, color: Colors.pink),
          ),
          initialRotation: -pi / randomMirrorOffset),
      CircleMirror.builder(
          numberOfParticles: 6,
          particleBuilder: (index) {
            return IntervalParticle(
                child: AnimatedPositionedParticle(
                  begin: Offset(0.0, 30.0),
                  end: Offset(0.0, 50.0),
                  child: FadingTriangle(
                      baseSize: 6.0 + random.nextDouble() * 4.0,
                      heightToBaseFactor: 1.0 + random.nextDouble(),
                      variation: random.nextDouble(),
                      color: Colors.pink),
                ),
                interval: Interval(
                  0.0,
                  0.8,
                ));
          },
          // division by 0 is not good ;)
          initialRotation: -pi / randomMirrorOffset + 8),
    ]).paint(canvas, size, progress, seed);
  }
}