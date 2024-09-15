// Mocks generated by Mockito 5.4.4 from annotations
// in x_video_ai/test/services/content_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:convert' as _i6;
import 'dart:io' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:x_video_ai/gateway/file_getaway.dart' as _i2;

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

class _FakeFileWrapper_0 extends _i1.SmartFake implements _i2.FileWrapper {
  _FakeFileWrapper_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDirectoryWrapper_1 extends _i1.SmartFake
    implements _i2.DirectoryWrapper {
  _FakeDirectoryWrapper_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFile_2 extends _i1.SmartFake implements _i3.File {
  _FakeFile_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FileGateway].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileGateway extends _i1.Mock implements _i2.FileGateway {
  MockFileGateway() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FileWrapper getFile(String? path) => (super.noSuchMethod(
        Invocation.method(
          #getFile,
          [path],
        ),
        returnValue: _FakeFileWrapper_0(
          this,
          Invocation.method(
            #getFile,
            [path],
          ),
        ),
      ) as _i2.FileWrapper);

  @override
  bool exists(String? path) => (super.noSuchMethod(
        Invocation.method(
          #exists,
          [path],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i4.Future<void> createDirectory(String? path) => (super.noSuchMethod(
        Invocation.method(
          #createDirectory,
          [path],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i2.DirectoryWrapper getDirectory(String? path) => (super.noSuchMethod(
        Invocation.method(
          #getDirectory,
          [path],
        ),
        returnValue: _FakeDirectoryWrapper_1(
          this,
          Invocation.method(
            #getDirectory,
            [path],
          ),
        ),
      ) as _i2.DirectoryWrapper);
}

/// A class which mocks [FileWrapper].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileWrapper extends _i1.Mock implements _i2.FileWrapper {
  MockFileWrapper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#path),
        ),
      ) as String);

  @override
  String readAsStringSync() => (super.noSuchMethod(
        Invocation.method(
          #readAsStringSync,
          [],
        ),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.method(
            #readAsStringSync,
            [],
          ),
        ),
      ) as String);

  @override
  void writeAsStringSync(String? contents) => super.noSuchMethod(
        Invocation.method(
          #writeAsStringSync,
          [contents],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool existsSync() => (super.noSuchMethod(
        Invocation.method(
          #existsSync,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  void createSync({bool? recursive = false}) => super.noSuchMethod(
        Invocation.method(
          #createSync,
          [],
          {#recursive: recursive},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<bool> exists() => (super.noSuchMethod(
        Invocation.method(
          #exists,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<String> readAsString(
          {_i6.Encoding? encoding = const _i6.Utf8Codec()}) =>
      (super.noSuchMethod(
        Invocation.method(
          #readAsString,
          [],
          {#encoding: encoding},
        ),
        returnValue: _i4.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #readAsString,
            [],
            {#encoding: encoding},
          ),
        )),
      ) as _i4.Future<String>);

  @override
  _i4.Future<_i3.File> writeAsString(
    String? contents, {
    _i3.FileMode? mode = _i3.FileMode.write,
    _i6.Encoding? encoding = const _i6.Utf8Codec(),
    bool? flush = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #writeAsString,
          [contents],
          {
            #mode: mode,
            #encoding: encoding,
            #flush: flush,
          },
        ),
        returnValue: _i4.Future<_i3.File>.value(_FakeFile_2(
          this,
          Invocation.method(
            #writeAsString,
            [contents],
            {
              #mode: mode,
              #encoding: encoding,
              #flush: flush,
            },
          ),
        )),
      ) as _i4.Future<_i3.File>);
}

/// A class which mocks [DirectoryWrapper].
///
/// See the documentation for Mockito's code generation for more information.
class MockDirectoryWrapper extends _i1.Mock implements _i2.DirectoryWrapper {
  MockDirectoryWrapper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#path),
        ),
      ) as String);

  @override
  List<_i3.FileSystemEntity> listSync() => (super.noSuchMethod(
        Invocation.method(
          #listSync,
          [],
        ),
        returnValue: <_i3.FileSystemEntity>[],
      ) as List<_i3.FileSystemEntity>);
}
