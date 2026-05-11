import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder textFieldUnderKey(Key key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(TextFormField),
  );
}
