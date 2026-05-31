import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

final Set<Factory<OneSequenceGestureRecognizer>>
liquidGlassNativeControlGestureRecognizers =
    Set<Factory<OneSequenceGestureRecognizer>>.unmodifiable(
      <Factory<OneSequenceGestureRecognizer>>[
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      ],
    );
