import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/team.dart';
import 'team_detail_page.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: Obx(() {
        if (c.teams.isEmpty) {
          return const Center(child: Text('No teams yet. Create one from Home.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.teams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final t = c.teams[i];
            final members = c.membersOf(t);
            return ListTile(
              tileColor: Colors.indigo.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: CircleAvatar(
                child: Text('${i + 1}'),
              ),
              title: Text(t.name),
              subtitle: Text(members.map((m) => _cap(m.name)).join(' • ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => TeamDetailPage(teamId: t.id)),
              onLongPress: () => _confirmDelete(context, c, t.id),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, TeamController c, String teamId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete team?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () { c.deleteTeam(teamId); Get.back(); },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
