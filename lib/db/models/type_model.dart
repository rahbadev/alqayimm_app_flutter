class TypeModel {
  final int id;
  final String name;
  final String groupName;

  TypeModel({required this.id, required this.name, required this.groupName});

  factory TypeModel.fromMap(Map<String, dynamic> map) {
    return TypeModel(
      id: map['id'] as int,
      name: map['name'] as String,
      groupName: map['group_name'] as String,
    );
  }
}
