import 'package:flutter/foundation.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

enum SortOption { id, name }

class PokemonViewModel extends ChangeNotifier {
  final PokemonService _pokemonService;

  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  SortOption _currentSortOption = SortOption.id;
  bool _sortAscending = true;

  PokemonViewModel(this._pokemonService);

  List<Pokemon> get pokemons => _filteredPokemons;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  SortOption get currentSortOption => _currentSortOption;
  bool get sortAscending => _sortAscending;

  Future<void> fetchPokemons({int limit = 100000}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _pokemons = await _pokemonService.fetchPokemons(limit: limit);
      _applyFiltersAndSort();
    } catch (e) {
      _error = 'Erreur de chargement des Pokémon: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleSortOption(SortOption option) {
    if (_currentSortOption == option) {
      _sortAscending = !_sortAscending;
    } else {
      _currentSortOption = option;
      _sortAscending = true;
    }

    _applyFiltersAndSort();
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    if (_searchQuery.isEmpty) {
      _filteredPokemons = List.from(_pokemons);
    } else {
      _filteredPokemons = _pokemons.where((pokemon) {
        final String name = pokemon.name.toLowerCase();
        final String id = pokemon.id.toString();
        final String query = _searchQuery.toLowerCase();

        return name.contains(query) || id.contains(query);
      }).toList();
    }

    if (_currentSortOption == SortOption.id) {
      _filteredPokemons.sort((a, b) => _sortAscending
          ? a.id.compareTo(b.id)
          : b.id.compareTo(a.id));
    } else {
      _filteredPokemons.sort((a, b) => _sortAscending
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
    }
  }
}