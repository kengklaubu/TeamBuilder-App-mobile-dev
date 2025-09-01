import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/team.dart';
import '../widgets/pokemon_tile.dart';

class EditTeamPage extends StatefulWidget {
  final String teamId;
  const EditTeamPage({super.key, required this.teamId});

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late RxList<int> selectedIds; // ทำงานแยกจาก builder

  @override
  void initState() {
    super.initState();
    final c = Get.find<TeamController>();
    final t = c.teams.firstWhere((e) => e.id == widget.teamId);
    selectedIds = RxList<int>(List<int>.from(t.memberIds));
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Team Members')),
      body: Obx(() {
        final items = c.filtered;
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = items[i];
            final selected = selectedIds.contains(p.id);
            return PokemonTile(
              pokemon: p,
              selected: selected,
              onTap: () {
                setState(() {
                  if (selected) {
                    selectedIds.remove(p.id);
                  } else {
                    if (selectedIds.length >= 3) {
                      Get.snackbar('Team full', 'You can select up to 3 Pokémon');
                      return;
                    }
                    selectedIds.add(p.id);
                  }
                });
              },
            );
          },
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () {
              if (selectedIds.length != 3) {
                Get.snackbar('Exactly 3 required', 'Select exactly 3 Pokémon');
                return;
              }
              c.updateTeamMembers(widget.teamId, selectedIds.toList());
              Get.back();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ),
      ),
    );
  }
}
