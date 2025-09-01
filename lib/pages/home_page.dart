import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../widgets/pokemon_tile.dart';
import '../widgets/team_chip.dart';
import 'team_page.dart'; // ✅ ใช้ไฟล์ที่มีอยู่จริง

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Team'),
      ),
      floatingActionButton: Obx(() {
        final isReady = c.builderSelected.length == 3; // ✅ อิงตัวเลือกชั่วคราว
        return FloatingActionButton.extended(
          onPressed: () {
            if (!isReady) {
              Get.snackbar('Incomplete team', 'Please select exactly 3 Pokémon to create a team');
              return;
            }
            final teamId = c.createTeamFromBuilder(); // ✅ บันทึกทีมจริง
            Get.to(() => const TeamsPage()); // ✅ ไปหน้ารายการ/รายละเอียดทีมที่มีอยู่จริง
          },
          label: const Text('Create Team'),
          icon: const Icon(Icons.check),
        );
      }),
      body: Column(
        children: [
          Obx(() {
            return SizedBox(
              height: 96,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 4),
                  ...c.builderSelected // ✅ ใช้รายการที่เลือกชั่วคราว
                      .map((p) => TeamChip(
                            pokemon: p,
                            onRemove: () => c.toggleBuilder(p), // ✅ เมธอดสลับสถานะ
                          ))
                      .toList(),
                  if (c.builderSelected.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Select up to 3 Pokémon'),
                    ),
                  const SizedBox(width: 4),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.error.value != null) {
                return Center(child: Text('Error: ${c.error.value}'));
              }
              final items = c.filtered;
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = items[i];
                  final selected = c.isBuilderSelected(p); // ✅ เช็คเลือกอยู่ไหม
                  return PokemonTile(
                    pokemon: p,
                    selected: selected,
                    onTap: () => c.toggleBuilder(p), // ✅ แตะเพื่อเลือก/เอาออก
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
