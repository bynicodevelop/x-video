// Mocks generated by Mockito 5.4.4 from annotations
// in x_video_ai/test/controllers/config_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i2;
import 'package:x_video_ai/services/abstracts/json_deserializable.dart' as _i1;
import 'package:x_video_ai/services/config_service.dart' as _i3;

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

class _FakeConfigService_0<T1 extends _i1.JsonDeserializable<T1>>
    extends _i2.SmartFake implements _i3.ConfigService<T1> {
  _FakeConfigService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ConfigService].
///
/// See the documentation for Mockito's code generation for more information.
class MockConfigService<T extends _i1.JsonDeserializable<T>> extends _i2.Mock
    implements _i3.ConfigService<T> {
  MockConfigService() {
    _i2.throwOnMissingStub(this);
  }

  @override
  bool get isLoaded => (super.noSuchMethod(
        Invocation.getter(#isLoaded),
        returnValue: false,
      ) as bool);

  @override
  _i4.Future<_i3.ConfigService<T>> createConfiguration() => (super.noSuchMethod(
        Invocation.method(
          #createConfiguration,
          [],
        ),
        returnValue:
            _i4.Future<_i3.ConfigService<T>>.value(_FakeConfigService_0<T>(
          this,
          Invocation.method(
            #createConfiguration,
            [],
          ),
        )),
      ) as _i4.Future<_i3.ConfigService<T>>);

  @override
  _i4.Future<_i3.ConfigService<T>> loadConfiguration(
    String? path,
    T? model, {
    String? name = r'config.json',
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadConfiguration,
          [
            path,
            model,
          ],
          {#name: name},
        ),
        returnValue:
            _i4.Future<_i3.ConfigService<T>>.value(_FakeConfigService_0<T>(
          this,
          Invocation.method(
            #loadConfiguration,
            [
              path,
              model,
            ],
            {#name: name},
          ),
        )),
      ) as _i4.Future<_i3.ConfigService<T>>);

  @override
  _i4.Future<_i3.ConfigService<T>> updateConfiguration(
    String? key,
    dynamic value,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateConfiguration,
          [
            key,
            value,
          ],
        ),
        returnValue:
            _i4.Future<_i3.ConfigService<T>>.value(_FakeConfigService_0<T>(
          this,
          Invocation.method(
            #updateConfiguration,
            [
              key,
              value,
            ],
          ),
        )),
      ) as _i4.Future<_i3.ConfigService<T>>);

  @override
  _i3.ConfigService<T> copyWith({
    String? path,
    String? name,
    T? model,
    bool? isLoaded,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #copyWith,
          [],
          {
            #path: path,
            #name: name,
            #model: model,
            #isLoaded: isLoaded,
          },
        ),
        returnValue: _FakeConfigService_0<T>(
          this,
          Invocation.method(
            #copyWith,
            [],
            {
              #path: path,
              #name: name,
              #model: model,
              #isLoaded: isLoaded,
            },
          ),
        ),
      ) as _i3.ConfigService<T>);
}
