import 'package:flutter/material.dart';

// A calm, premium code theme with no bright blue/purple.
// Works with `flutter_highlight` theme maps.
const Map<String, TextStyle> premiumCodeTheme = {
  'root': TextStyle(color: Color(0xFFEDE8DE), backgroundColor: Color(0xFF121614)),
  'comment': TextStyle(color: Color(0xFF7E827B), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xFF7E827B), fontStyle: FontStyle.italic),

  'keyword': TextStyle(color: Color(0xFFA8B4A0), fontWeight: FontWeight.w600),
  'selector-tag': TextStyle(color: Color(0xFFA8B4A0), fontWeight: FontWeight.w600),
  'section': TextStyle(color: Color(0xFFA8B4A0), fontWeight: FontWeight.w600),

  'string': TextStyle(color: Color(0xFFB8924B)),
  'subst': TextStyle(color: Color(0xFFEDE8DE)),

  'number': TextStyle(color: Color(0xFFB8924B)),
  'literal': TextStyle(color: Color(0xFFB8924B)),
  'type': TextStyle(color: Color(0xFFB9B6AD)),
  'built_in': TextStyle(color: Color(0xFFB9B6AD)),

  'title': TextStyle(color: Color(0xFFE2D7C4), fontWeight: FontWeight.w600),
  'name': TextStyle(color: Color(0xFFE2D7C4), fontWeight: FontWeight.w600),
  'attribute': TextStyle(color: Color(0xFFE2D7C4)),

  'meta': TextStyle(color: Color(0xFFB9B6AD)),
  'tag': TextStyle(color: Color(0xFFB9B6AD)),

  'punctuation': TextStyle(color: Color(0xFFB9B6AD)),
  'symbol': TextStyle(color: Color(0xFFB9B6AD)),
  'bullet': TextStyle(color: Color(0xFFB9B6AD)),
  'addition': TextStyle(color: Color(0xFFA8B4A0)),
  'deletion': TextStyle(color: Color(0xFFB85D5D)),
};

