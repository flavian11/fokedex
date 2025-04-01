import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PokemonService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  // Cache en mémoire
  final Map<int, Pokemon> _pokemonCache = {};
  final Map<String, List<Pokemon>> _pokemonListCache = {};

  // Durée de validité du cache (en minutes)
  final int _cacheDuration = 60;

  // Timestamps des dernières requêtes
  final Map<String, DateTime> _cacheTimestamps = {};

  // Vérifie si le cache est encore valide
  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamps.containsKey(cacheKey)) return false;

    final DateTime timestamp = _cacheTimestamps[cacheKey]!;
    final DateTime now = DateTime.now();

    return now.difference(timestamp).inMinutes < _cacheDuration;
  }

  // Sauvegarde les données en cache persistant
  Future<void> _saveCacheToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokemon_cache.json');

      // Convertir les données du cache en format JSON
      final Map<String, dynamic> cacheData = {
        'pokemonCache': _pokemonCache.map((key, value) =>
            MapEntry(key.toString(), value)), // Nécessite toJson dans Pokemon
        'timestamps': _cacheTimestamps.map((key, value) =>
            MapEntry(key, value.millisecondsSinceEpoch)),
      };

      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      print('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  // Charge les données depuis le cache persistant
  Future<void> _loadCacheFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokemon_cache.json');

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> cacheData = jsonDecode(contents);

        // Restaurer le cache des pokémons
        if (cacheData.containsKey('pokemonCache')) {
          final Map<String, dynamic> pokemonMap = cacheData['pokemonCache'];
          pokemonMap.forEach((key, value) {
            _pokemonCache[int.parse(key)] = Pokemon.fromJson(value);
          });
        }

        // Restaurer les timestamps
        if (cacheData.containsKey('timestamps')) {
          final Map<String, dynamic> timestampMap = cacheData['timestamps'];
          timestampMap.forEach((key, value) {
            _cacheTimestamps[key] = DateTime.fromMillisecondsSinceEpoch(value);
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du cache: $e');
    }
  }

  // Constructeur qui charge le cache au démarrage
  PokemonService() {
    _loadCacheFromFile();
  }

  Future<List<Pokemon>> fetchPokemons({int limit = 151, int offset = 0}) async {
    final String cacheKey = 'pokemon_list_${limit}_${offset}';

    // Vérifier si les données sont en cache et valides
    if (_pokemonListCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _pokemonListCache[cacheKey]!;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final results = jsonData['results'] as List;

        List<Pokemon> pokemonList = [];

        for (var pokemon in results) {
          final Uri pokemonUrl = Uri.parse(pokemon['url']);
          final pokemonId = int.parse(pokemonUrl.pathSegments[3]);

          // Vérifier si ce Pokémon est déjà en cache
          if (_pokemonCache.containsKey(pokemonId) && _isCacheValid('pokemon_$pokemonId')) {
            pokemonList.add(_pokemonCache[pokemonId]!);
          } else {
            final detailResponse = await http.get(pokemonUrl);
            if (detailResponse.statusCode == 200) {
              final pokemonData = jsonDecode(detailResponse.body);
              final Pokemon newPokemon = Pokemon.fromJson(pokemonData);

              // Ajouter au cache
              _pokemonCache[pokemonId] = newPokemon;
              _cacheTimestamps['pokemon_$pokemonId'] = DateTime.now();

              pokemonList.add(newPokemon);
            }
          }
        }

        // Mettre à jour le cache de la liste
        _pokemonListCache[cacheKey] = pokemonList;
        _cacheTimestamps[cacheKey] = DateTime.now();

        // Sauvegarder le cache
        _saveCacheToFile();

        return pokemonList;
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      // En cas d'erreur, retourner le cache même s'il est périmé
      if (_pokemonListCache.containsKey(cacheKey)) {
        return _pokemonListCache[cacheKey]!;
      }
      throw Exception('Failed to load Pokémon: $e');
    }
  }

  Future<Pokemon> fetchPokemonDetails(int id) async {
    final String cacheKey = 'pokemon_$id';

    // Vérifier si les données sont en cache et valides
    if (_pokemonCache.containsKey(id) && _isCacheValid(cacheKey)) {
      return _pokemonCache[id]!;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

      if (response.statusCode == 200) {
        final pokemonData = jsonDecode(response.body);
        final Pokemon pokemon = Pokemon.fromJson(pokemonData);

        // Mettre à jour le cache
        _pokemonCache[id] = pokemon;
        _cacheTimestamps[cacheKey] = DateTime.now();

        // Sauvegarder le cache
        _saveCacheToFile();

        return pokemon;
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      // En cas d'erreur, retourner le cache même s'il est périmé
      if (_pokemonCache.containsKey(id)) {
        return _pokemonCache[id]!;
      }
      throw Exception('Failed to load Pokémon details: $e');
    }
  }

  // Méthode pour effacer le cache
  Future<void> clearCache() async {
    _pokemonCache.clear();
    _pokemonListCache.clear();
    _cacheTimestamps.clear();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokemon_cache.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression du cache: $e');
    }
  }
}