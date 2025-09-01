class Team {
  final String id;
  String name;
  List<int> memberIds;

  Team({required this.id, required this.name, required this.memberIds})
      : assert(memberIds.length == 3, 'Team must have exactly 3 members');

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'memberIds': memberIds};

  factory Team.fromJson(Map<String, dynamic> m) => Team(
        id: m['id'] as String,
        name: m['name'] as String,
        memberIds: (m['memberIds'] as List).cast<int>(),
      );
}
