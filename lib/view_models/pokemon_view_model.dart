import 'package:flutter/foundation.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

enum SortOption {id, name}

class PokemonViewModel extends ChangeNotifier {
  final PokemonService _pokemonService;

  List<Pokemon> _pokemons = [];
  bool _isLoading = false;
  String _error = '';

  SortOption _currentSortOption = SortOption.id;
  bool _sortAscending = true;

  PokemonViewModel(this._pokemonService);

  List<Pokemon> get pokemons => _pokemons;
  bool get isLoading => _isLoading;
  String get error => _error;
  SortOption get currentSortOption => _currentSortOption;
  bool get sortAscending => _sortAscending;

  Future<void> fetchPokemons({int limit = 100000}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _pokemons = await _pokemonService.fetchPokemons(limit: limit);
      _sortPokemons();
    } catch (e) {
      _error = 'Erreur de chargement des Pokémon: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSortOption(SortOption option) {
    if (_currentSortOption == option) {
      _sortAscending = !_sortAscending;
    } else {
      _currentSortOption = option;
      _sortAscending = true;
    }

    _sortPokemons();
    notifyListeners();
  }

  void _sortPokemons() {
    if (_currentSortOption == SortOption.id) {
      _pokemons.sort((a, b) => _sortAscending
          ? a.id.compareTo(b.id)
          : b.id.compareTo(a.id));
    } else {
      _pokemons.sort((a, b) => _sortAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
    }
  }
}