import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class PokemonTile extends StatelessWidget {
  final Pokemon pokemon;
  final bool selected;
  final VoidCallback onTap;
  const PokemonTile({super.key, required this.pokemon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: selected ? 0.98 : 1.0,
      child: ListTile(
        onTap: onTap,
        leading: Hero(
          tag: 'poke_${pokemon.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: pokemon.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 56,
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => const Icon(Icons.error_outline),
            ),
          ),
        ),
        title: Text(
          _capitalize(pokemon.name),
          style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? Colors.indigo.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Colors.indigo : Colors.grey.shade300),
          ),
          child: Icon(selected ? Icons.check_circle : Icons.add_circle_outline),
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
