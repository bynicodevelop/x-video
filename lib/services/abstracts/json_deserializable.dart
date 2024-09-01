abstract class JsonDeserializable {
   fromJson(Map<String, dynamic> json);
   mergeWith(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
