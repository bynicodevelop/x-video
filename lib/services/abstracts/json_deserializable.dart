abstract class JsonDeserializable<T> {
  T fromJson(Map<String, dynamic> json);
  T mergeWith(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
