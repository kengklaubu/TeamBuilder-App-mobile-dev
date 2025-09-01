import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/pokemon.dart';
import '../models/team.dart';
import '../services/poke_service.dart';
import '../storage/storage_keys.dart';

class TeamController extends GetxController {
  TeamController(this._service);
  final PokeService _service;
  final _box = GetStorage();
  final _uuid = const Uuid();

  // โปเกมอนทั้งหมดที่โหลดมาให้เลือก
  final all = <Pokemon>[].obs;

  // โหมด "กำลังก่อทีมใหม่" ที่หน้า Home
  final builderSelected = <Pokemon>[].obs;
  final builderName = 'My Team'.obs;

  // คลังทีมทั้งหมดที่สร้างไว้
  final teams = <Team>[].obs;

  // ค้นหา
  final query = ''.obs;

  // สถานะโหลด/เออเรอร์
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadPersisted();
    _loadAll();
    // persist เมื่อมีการเปลี่ยนแปลง
    ever<List<Team>>(teams, (_) => _persistTeams());
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await _service.fetchPokemonList();
      all.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPersisted() {
    final raw = _box.read<List>(StorageKeys.teams)?.cast<Map>() ?? const [];
    teams.assignAll(
      raw.map((e) => Team.fromJson(Map<String, dynamic>.from(e))),
    );
  }

  void _persistTeams() {
    _box.write(
      StorageKeys.teams,
      teams.map((t) => t.toJson()).toList(),
    );
  }

  // ---------- Builder helpers (API ให้ HomePage เรียกใช้) ----------
  bool isBuilderSelected(Pokemon p) =>
      builderSelected.any((x) => x.id == p.id);

  void toggleBuilder(Pokemon p) {
    const maxTeamSize = 3;
    if (isBuilderSelected(p)) {
      builderSelected.removeWhere((x) => x.id == p.id);
    } else {
      if (builderSelected.length >= maxTeamSize) {
        Get.snackbar('Team full', 'You can select up to $maxTeamSize Pokémon');
        return;
      }
      builderSelected.add(p);
    }
  }

  void resetBuilder() {
    builderSelected.clear();
    builderName.value = 'My Team';
  }

  void renameBuilder(String name) {
    builderName.value = name.trim().isEmpty ? 'My Team' : name.trim();
  }

  // ---------- สร้าง/แก้ทีม ----------
  /// เรียกตอนกด "Create Team" ที่หน้า Home
  String createTeamFromBuilder() {
    if (builderSelected.length != 3) {
      throw Exception('Please select exactly 3 Pokémon');
    }
    final t = Team(
      id: _uuid.v4(),
      name: builderName.value,
      memberIds: builderSelected.map((e) => e.id).toList(),
    );
    teams.add(t);
    _persistTeams();
    // เคลียร์สถานะหน้า Builder
    resetBuilder();
    return t.id;
  }

  /// ดึงสมาชิกของทีมสำหรับหน้า detail
  List<Pokemon> membersOf(Team t) {
    // map id -> pokemon (กันกรณีข้อมูลไม่ครบ)
    final mapById = {for (final p in all) p.id: p};
    return t.memberIds
        .where((id) => mapById.containsKey(id))
        .map((id) => mapById[id]!)
        .toList();
  }

  void updateTeamMembers(String teamId, List<int> newIds) {
    if (newIds.length != 3) {
      Get.snackbar('Exactly 3 required', 'A team must have exactly 3 members');
      return;
    }
    final idx = teams.indexWhere((e) => e.id == teamId);
    if (idx == -1) return;
    teams[idx].memberIds = List<int>.from(newIds);
    teams.refresh();
    _persistTeams();
  }

  void renameTeam(String teamId, String newName) {
    final idx = teams.indexWhere((e) => e.id == teamId);
    if (idx == -1) return;
    teams[idx].name = newName.trim().isEmpty ? 'My Team' : newName.trim();
    teams.refresh();
    _persistTeams();
  }

  void deleteTeam(String teamId) {
    teams.removeWhere((e) => e.id == teamId);
    _persistTeams();
  }

  // ---------- ค้นหา ----------
  List<Pokemon> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  // ---------- (ถ้าหน้าอื่นยังเรียกชื่อเก่าอยู่ ให้ alias ไว้กันพัง) ----------
  // สำหรับโค้ดเดิมที่อาจเรียก isSelectedInBuilder / toggleInBuilder
  bool isSelectedInBuilder(Pokemon p) => isBuilderSelected(p);
  void toggleInBuilder(Pokemon p) => toggleBuilder(p);
}
