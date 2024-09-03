import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class CreateContentState implements JsonDeserializable {
  final String id;
  final String name;
  final Map<String, String?> errors;
  final bool isValidForm;

  CreateContentState({
    this.id = '',
    this.name = '',
    this.errors = const {},
    this.isValidForm = false,
  });

  @override
  CreateContentState mergeWith(Map<String, dynamic> json) => CreateContentState(
        id: json['id'] ?? id,
        name: json['name'] ?? name,
        errors: json['errors'] ?? errors,
        isValidForm: json['isValidForm'] ?? isValidForm,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'errors': errors,
        'isValidForm': isValidForm,
      };

  @override
  CreateContentState fromJson(Map<String, dynamic> json) => CreateContentState(
        id: json['id'] ?? id,
        name: json['name'] ?? name,
        errors: json['errors'] ?? errors,
        isValidForm: json['isValidForm'] ?? isValidForm,
      );
}
