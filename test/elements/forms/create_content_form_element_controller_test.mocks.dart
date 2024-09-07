// Mocks generated by Mockito 5.4.4 from annotations
// in x_video_ai/test/elements/forms/create_content_form_element_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:flutter_riverpod/flutter_riverpod.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:state_notifier/state_notifier.dart' as _i7;
import 'package:x_video_ai/controllers/content_controller.dart' as _i4;
import 'package:x_video_ai/models/content_model.dart' as _i2;
import 'package:x_video_ai/services/content_service.dart' as _i3;

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

class _FakeContentModel_0 extends _i1.SmartFake implements _i2.ContentModel {
  _FakeContentModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ContentService].
///
/// See the documentation for Mockito's code generation for more information.
class MockContentService extends _i1.Mock implements _i3.ContentService {
  MockContentService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void saveContent(_i2.ContentModel? contentModel) => super.noSuchMethod(
        Invocation.method(
          #saveContent,
          [contentModel],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.ContentModel> loadContents(String? path) => (super.noSuchMethod(
        Invocation.method(
          #loadContents,
          [path],
        ),
        returnValue: <_i2.ContentModel>[],
      ) as List<_i2.ContentModel>);

  @override
  Map<String, dynamic> getContent(String? path) => (super.noSuchMethod(
        Invocation.method(
          #getContent,
          [path],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}

/// A class which mocks [ContentController].
///
/// See the documentation for Mockito's code generation for more information.
class MockContentController extends _i1.Mock implements _i4.ContentController {
  MockContentController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isInitialized => (super.noSuchMethod(
        Invocation.getter(#isInitialized),
        returnValue: false,
      ) as bool);

  @override
  bool get isReadyVideo => (super.noSuchMethod(
        Invocation.getter(#isReadyVideo),
        returnValue: false,
      ) as bool);

  @override
  bool get hasChronical => (super.noSuchMethod(
        Invocation.getter(#hasChronical),
        returnValue: false,
      ) as bool);

  @override
  _i2.ContentModel get content => (super.noSuchMethod(
        Invocation.getter(#content),
        returnValue: _FakeContentModel_0(
          this,
          Invocation.getter(#content),
        ),
      ) as _i2.ContentModel);

  @override
  set onError(_i5.ErrorListener? _onError) => super.noSuchMethod(
        Invocation.setter(
          #onError,
          _onError,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get mounted => (super.noSuchMethod(
        Invocation.getter(#mounted),
        returnValue: false,
      ) as bool);

  @override
  _i6.Stream<_i2.ContentModel> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i6.Stream<_i2.ContentModel>.empty(),
      ) as _i6.Stream<_i2.ContentModel>);

  @override
  _i2.ContentModel get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _FakeContentModel_0(
          this,
          Invocation.getter(#state),
        ),
      ) as _i2.ContentModel);

  @override
  set state(_i2.ContentModel? value) => super.noSuchMethod(
        Invocation.setter(
          #state,
          value,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.ContentModel get debugState => (super.noSuchMethod(
        Invocation.getter(#debugState),
        returnValue: _FakeContentModel_0(
          this,
          Invocation.getter(#debugState),
        ),
      ) as _i2.ContentModel);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void initContent(_i2.ContentModel? contentModel) => super.noSuchMethod(
        Invocation.method(
          #initContent,
          [contentModel],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setContent(
    String? title,
    String? content,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setContent,
          [
            title,
            content,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setChronical(String? content) => super.noSuchMethod(
        Invocation.method(
          #setChronical,
          [content],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setAudio(String? audio) => super.noSuchMethod(
        Invocation.method(
          #setAudio,
          [audio],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setSrt(Map<String, dynamic>? srt) => super.noSuchMethod(
        Invocation.method(
          #setSrt,
          [srt],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setSrtWithGroup(List<Map<String, dynamic>>? srtWithGroup) =>
      super.noSuchMethod(
        Invocation.method(
          #setSrtWithGroup,
          [srtWithGroup],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setAss(String? assContent) => super.noSuchMethod(
        Invocation.method(
          #setAss,
          [assContent],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setSections(List<Map<String, dynamic>>? sections) => super.noSuchMethod(
        Invocation.method(
          #setSections,
          [sections],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void updateSections(Map<String, dynamic>? section) => super.noSuchMethod(
        Invocation.method(
          #updateSections,
          [section],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void save() => super.noSuchMethod(
        Invocation.method(
          #save,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool updateShouldNotify(
    _i2.ContentModel? old,
    _i2.ContentModel? current,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateShouldNotify,
          [
            old,
            current,
          ],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i5.RemoveListener addListener(
    _i7.Listener<_i2.ContentModel>? listener, {
    bool? fireImmediately = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
          {#fireImmediately: fireImmediately},
        ),
        returnValue: () {},
      ) as _i5.RemoveListener);

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
