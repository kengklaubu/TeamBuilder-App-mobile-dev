import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/team.dart';
import 'edit_team_page.dart';

class TeamDetailPage extends StatelessWidget {
  final String teamId;
  const TeamDetailPage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Obx(() {
      final t = c.teams.firstWhereOrNull((x) => x.id == teamId);
      if (t == null) {
        return const Scaffold(body: Center(child: Text('Team not found')));
      }
      final members = c.membersOf(t);
      return Scaffold(
        appBar: AppBar(
          title: Text(t.name),
          actions: [
            IconButton(
              tooltip: 'Rename',
              icon: const Icon(Icons.edit),
              onPressed: () => _rename(context, c, t),
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = members[i];
            return ListTile(
              leading: Image.network(p.imageUrl, width: 56, height: 56),
              title: Text(_cap(p.name)),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: () => Get.to(() => EditTeamPage(teamId: teamId)),
              icon: const Icon(Icons.group_add),
              label: const Text('Edit Members'),
            ),
          ),
        ),
      );
    });
  }

  void _rename(BuildContext context, TeamController c, Team t) {
    final ctl = TextEditingController(text: t.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Team'),
        content: TextField(controller: ctl, autofocus: true),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () { c.renameTeam(t.id, ctl.text); Get.back(); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
