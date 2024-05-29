// Mocks generated by Mockito 5.4.4 from annotations
// in pro_image_editor_tony/test/widgets/color_picker/bar_color_picker_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes, must_be_immutable
import 'dart:ui' as _i2;

import 'package:flutter/foundation.dart' as _i4;
import 'package:flutter/material.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:pro_image_editor_tony/widgets/color_picker/bar_color_picker.dart'
    as _i5;
import 'package:pro_image_editor_tony/widgets/color_picker/color_picker_configs.dart'
    as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeColor_0 extends _i1.SmartFake implements _i2.Color {
  _FakeColor_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeState_1<T extends _i3.StatefulWidget> extends _i1.SmartFake
    implements _i3.State<T> {
  _FakeState_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeStatefulElement_2 extends _i1.SmartFake
    implements _i3.StatefulElement {
  _FakeStatefulElement_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_3 extends _i1.SmartFake
    implements _i3.DiagnosticsNode {
  _FakeDiagnosticsNode_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({
    _i4.TextTreeConfiguration? parentConfiguration,
    _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info,
  }) =>
      super.toString();
}

/// A class which mocks [BarColorPicker].
///
/// See the documentation for Mockito's code generation for more information.
class MockBarColorPicker extends _i1.Mock implements _i5.BarColorPicker {
  @override
  _i6.PickMode get pickMode => (super.noSuchMethod(
        Invocation.getter(#pickMode),
        returnValue: _i6.PickMode.color,
        returnValueForMissingStub: _i6.PickMode.color,
      ) as _i6.PickMode);

  @override
  double get length => (super.noSuchMethod(
        Invocation.getter(#length),
        returnValue: 0.0,
        returnValueForMissingStub: 0.0,
      ) as double);

  @override
  dynamic Function(int) get colorListener => (super.noSuchMethod(
        Invocation.getter(#colorListener),
        returnValue: (int value) => null,
        returnValueForMissingStub: (int value) => null,
      ) as dynamic Function(int));

  @override
  double get cornerRadius => (super.noSuchMethod(
        Invocation.getter(#cornerRadius),
        returnValue: 0.0,
        returnValueForMissingStub: 0.0,
      ) as double);

  @override
  bool get horizontal => (super.noSuchMethod(
        Invocation.getter(#horizontal),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i2.Color get thumbColor => (super.noSuchMethod(
        Invocation.getter(#thumbColor),
        returnValue: _FakeColor_0(
          this,
          Invocation.getter(#thumbColor),
        ),
        returnValueForMissingStub: _FakeColor_0(
          this,
          Invocation.getter(#thumbColor),
        ),
      ) as _i2.Color);

  @override
  double get thumbRadius => (super.noSuchMethod(
        Invocation.getter(#thumbRadius),
        returnValue: 0.0,
        returnValueForMissingStub: 0.0,
      ) as double);

  @override
  _i2.Color get initialColor => (super.noSuchMethod(
        Invocation.getter(#initialColor),
        returnValue: _FakeColor_0(
          this,
          Invocation.getter(#initialColor),
        ),
        returnValueForMissingStub: _FakeColor_0(
          this,
          Invocation.getter(#initialColor),
        ),
      ) as _i2.Color);

  @override
  _i3.State<_i3.StatefulWidget> createState() => (super.noSuchMethod(
        Invocation.method(
          #createState,
          [],
        ),
        returnValue: _FakeState_1<_i3.StatefulWidget>(
          this,
          Invocation.method(
            #createState,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeState_1<_i3.StatefulWidget>(
          this,
          Invocation.method(
            #createState,
            [],
          ),
        ),
      ) as _i3.State<_i3.StatefulWidget>);

  @override
  _i3.StatefulElement createElement() => (super.noSuchMethod(
        Invocation.method(
          #createElement,
          [],
        ),
        returnValue: _FakeStatefulElement_2(
          this,
          Invocation.method(
            #createElement,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeStatefulElement_2(
          this,
          Invocation.method(
            #createElement,
            [],
          ),
        ),
      ) as _i3.StatefulElement);

  @override
  String toStringShort() => (super.noSuchMethod(
        Invocation.method(
          #toStringShort,
          [],
        ),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringShort,
            [],
          ),
        ),
        returnValueForMissingStub: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringShort,
            [],
          ),
        ),
      ) as String);

  @override
  void debugFillProperties(_i4.DiagnosticPropertiesBuilder? properties) =>
      super.noSuchMethod(
        Invocation.method(
          #debugFillProperties,
          [properties],
        ),
        returnValueForMissingStub: null,
      );

  @override
  String toStringShallow({
    String? joiner = r', ',
    _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.debug,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #toStringShallow,
          [],
          {
            #joiner: joiner,
            #minLevel: minLevel,
          },
        ),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringShallow,
            [],
            {
              #joiner: joiner,
              #minLevel: minLevel,
            },
          ),
        ),
        returnValueForMissingStub: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringShallow,
            [],
            {
              #joiner: joiner,
              #minLevel: minLevel,
            },
          ),
        ),
      ) as String);

  @override
  String toStringDeep({
    String? prefixLineOne = r'',
    String? prefixOtherLines,
    _i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.debug,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #toStringDeep,
          [],
          {
            #prefixLineOne: prefixLineOne,
            #prefixOtherLines: prefixOtherLines,
            #minLevel: minLevel,
          },
        ),
        returnValue: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringDeep,
            [],
            {
              #prefixLineOne: prefixLineOne,
              #prefixOtherLines: prefixOtherLines,
              #minLevel: minLevel,
            },
          ),
        ),
        returnValueForMissingStub: _i7.dummyValue<String>(
          this,
          Invocation.method(
            #toStringDeep,
            [],
            {
              #prefixLineOne: prefixLineOne,
              #prefixOtherLines: prefixOtherLines,
              #minLevel: minLevel,
            },
          ),
        ),
      ) as String);

  @override
  _i3.DiagnosticsNode toDiagnosticsNode({
    String? name,
    _i4.DiagnosticsTreeStyle? style,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #toDiagnosticsNode,
          [],
          {
            #name: name,
            #style: style,
          },
        ),
        returnValue: _FakeDiagnosticsNode_3(
          this,
          Invocation.method(
            #toDiagnosticsNode,
            [],
            {
              #name: name,
              #style: style,
            },
          ),
        ),
        returnValueForMissingStub: _FakeDiagnosticsNode_3(
          this,
          Invocation.method(
            #toDiagnosticsNode,
            [],
            {
              #name: name,
              #style: style,
            },
          ),
        ),
      ) as _i3.DiagnosticsNode);

  @override
  List<_i3.DiagnosticsNode> debugDescribeChildren() => (super.noSuchMethod(
        Invocation.method(
          #debugDescribeChildren,
          [],
        ),
        returnValue: <_i3.DiagnosticsNode>[],
        returnValueForMissingStub: <_i3.DiagnosticsNode>[],
      ) as List<_i3.DiagnosticsNode>);

  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}
