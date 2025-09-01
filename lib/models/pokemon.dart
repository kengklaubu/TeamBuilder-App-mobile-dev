class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({required this.id, required this.name, required this.imageUrl});

  static int _idFromUrl(String url) {
    final match = RegExp(r"/pokemon/(\d+)/").firstMatch(url);
    if (match == null) return -1;
    return int.tryParse(match.group(1)!) ?? -1;
  }

  factory Pokemon.fromListItem(Map<String, dynamic> m) {
    final id = _idFromUrl(m['url'] as String);
    final name = (m['name'] as String).toLowerCase();
    final img =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    return Pokemon(id: id, name: name, imageUrl: img);
  }
}
