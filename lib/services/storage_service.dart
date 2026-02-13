import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dream.dart';

class StorageService {
  static const String _dreamsKey = 'gabby_dreams';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<Dream>> loadDreams() async {
    final String? dreamsJson = _prefs?.getString(_dreamsKey);
    if (dreamsJson == null || dreamsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> dreamsList = jsonDecode(dreamsJson);
      return dreamsList.map((d) => Dream.fromJson(d)).toList();
    } catch (e) {
      print('Error loading dreams: $e');
      return [];
    }
  }

  static Future<void> saveDreams(List<Dream> dreams) async {
    final String dreamsJson = jsonEncode(dreams.map((d) => d.toJson()).toList());
    await _prefs?.setString(_dreamsKey, dreamsJson);
  }

  static Future<void> addDream(Dream dream) async {
    final dreams = await loadDreams();
    final existingIndex = dreams.indexWhere((d) => d.id == dream.id);
    if (existingIndex != -1) {
      // Dream already exists, update it instead
      dreams[existingIndex] = dream;
    } else {
      // New dream, add it
      dreams.add(dream);
    }
    await saveDreams(dreams);
  }

  static Future<void> updateDream(Dream dream) async {
    final dreams = await loadDreams();
    final index = dreams.indexWhere((d) => d.id == dream.id);
    if (index != -1) {
      dreams[index] = dream;
      await saveDreams(dreams);
    }
  }

  static Future<void> deleteDream(String dreamId) async {
    final dreams = await loadDreams();
    dreams.removeWhere((d) => d.id == dreamId);
    await saveDreams(dreams);
  }
}
