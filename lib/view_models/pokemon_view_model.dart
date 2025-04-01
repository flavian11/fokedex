import 'package:flutter/foundation.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

class PokemonViewModel extends ChangeNotifier {
  final PokemonService _pokemonService;

  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  String _error = '';

  PokemonViewModel(this._pokemonService);

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPokemons({int limit = 151}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _pokemons = await _pokemonService.fetchPokemons(limit: limit);
      _pokemons.sort((a, b) => a.id.compareTo(b.id));
    } catch (e) {
      _error = 'Erreur de chargement des Pokémon: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}