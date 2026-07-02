import '../mock/mock_data.dart';
import '../models/nanny_model.dart';

/// Contrat d'accès aux profils nounous.
abstract class NannyRepository {
  Future<List<NannyModel>> getNannies();

  Future<NannyModel> getNannyById(String id);

  Future<List<NannyModel>> getFavorites();

  Future<List<String>> getQuartiers();
}

/// Implémentation mock : lit [MockData] avec une latence simulée.
class MockNannyRepository implements NannyRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<List<NannyModel>> getNannies() =>
      Future.delayed(_latency, () => List.unmodifiable(MockData.nannies));

  @override
  Future<NannyModel> getNannyById(String id) => Future.delayed(
    _latency,
    () => MockData.nannies.firstWhere(
      (n) => n.id == id,
      orElse: () => throw StateError('Nounou introuvable : $id'),
    ),
  );

  @override
  Future<List<NannyModel>> getFavorites() => Future.delayed(
    _latency,
    () => List.unmodifiable(MockData.nannies.take(3).toList()),
  );

  @override
  Future<List<String>> getQuartiers() =>
      Future.delayed(_latency, () => List.unmodifiable(MockData.quartiers));
}
