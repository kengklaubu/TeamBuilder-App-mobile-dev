import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeService {
  final _baseUrl = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151');

  Future<List<Pokemon>> fetchPokemonList() async {
    final res = await http.get(_baseUrl);
    if (res.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final List list = data['results'] as List;
    return list.map((e) => Pokemon.fromListItem(e as Map<String, dynamic>)).toList();
  }
}
