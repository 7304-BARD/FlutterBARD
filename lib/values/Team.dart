class Team {
  final String id;
  final String name;
  const Team(this.id, this.name);

  Map<String, String> toMap() => {'id': id, 'name': name};

  static Team fromMap(Map<String, dynamic> m) => new Team(m['id'], m['name']);
}
