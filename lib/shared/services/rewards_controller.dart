import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:nucleo_casa_decor_android/mobile/models/reward.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RewardsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<RewardModel> awardsList = <RewardModel>[].obs;

  final StreamController<bool> _loadingController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String> get errorStream => _errorController.stream;

  final String apiUrl = 'https://apicasadecor.com/api/premio/';

  get dataController => null;

  @override
  void onClose() {
    _loadingController.close();
    _errorController.close();
    super.onClose();
  }

  Future<void> fetchAwards() async {
    _setLoading(true);
    _setError('');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _setError('Usuário não autenticado.');
        awardsList.clear();
        _setLoading(false);
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<RewardModel> rewards =
            data.map((jsonItem) => RewardModel.fromJson(jsonItem)).toList();
        awardsList.assignAll(rewards);
      } else {
        _setError('Erro ao buscar prêmios. Código: ${response.statusCode}');
        awardsList.clear();
      }
    } catch (e) {
      _setError('Erro na requisição: $e');
      awardsList.clear();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReward(RewardModel reward) async {
    _setLoading(true);
    _setError('');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _setError('Usuário não autenticado.');
        _setLoading(false);
        return;
      }

      final response = await http.delete(
        Uri.parse('$apiUrl${reward.id.toString()}/'), // aqui convertemos para String
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        // sucesso
        awardsList.removeWhere((r) => r.id == reward.id);
      } else {
        _setError('Erro ao deletar prêmio. Código: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Erro na requisição: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading.value = value;
    _loadingController.add(value);
  }

  void _setError(String message) {
    errorMessage.value = message;
    if (message.isNotEmpty) {
      _errorController.add(message);
    }
  }

  void initValues() {}
}
