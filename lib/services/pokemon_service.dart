import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PokemonService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  // momery cache
  final Map<int, Pokemon> _pokemonCache = {};
  final Map<String, List<Pokemon>> _pokemonListCache = {};

  // cache time validity (in minutes)
  final int _cacheDuration = 60;

  // last requests timestamps
  final Map<String, DateTime> _cacheTimestamps = {};

  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamps.containsKey(cacheKey)) return false;

    final DateTime timestamp = _cacheTimestamps[cacheKey]!;
    final DateTime now = DateTime.now();

    return now.difference(timestamp).inMinutes < _cacheDuration;
  }

  Future<void> _saveCacheToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokemon_cache.json');

      final Map<String, dynamic> cacheData = {
        'pokemonCache': _pokemonCache.map((key, value) =>
            MapEntry(key.toString(), value)),
        'timestamps': _cacheTimestamps.map((key, value) =>
            MapEntry(key, value.millisecondsSinceEpoch)),
      };

      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      print('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  Future<void> _loadCacheFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pokemon_cache.json');

      if (await file.exists()) {
        final String contents = await file.readAsString();
        final Map<String, dynamic> cacheData = jsonDecode(contents);

        if (cacheData.containsKey('pokemonCache')) {
          final Map<String, dynamic> pokemonMap = cacheData['pokemonCache'];
          pokemonMap.forEach((key, value) {
            _pokemonCache[int.parse(key)] = Pokemon.fromJson(value);
          });
        }

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

  // Load cache at start up
  PokemonService() {
    _loadCacheFromFile();
  }

  Future<List<Pokemon>> fetchPokemons({int limit = 100000, int offset = 0}) async {
    final String cacheKey = 'pokemon_list_${limit}_${offset}';

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

          if (_pokemonCache.containsKey(pokemonId) && _isCacheValid('pokemon_$pokemonId')) {
            pokemonList.add(_pokemonCache[pokemonId]!);
          } else {
            final detailResponse = await http.get(pokemonUrl);
            if (detailResponse.statusCode == 200) {
              final pokemonData = jsonDecode(detailResponse.body);
              final Pokemon newPokemon = Pokemon.fromJson(pokemonData);

              _pokemonCache[pokemonId] = newPokemon;
              _cacheTimestamps['pokemon_$pokemonId'] = DateTime.now();

              pokemonList.add(newPokemon);
            }
          }
        }

        _pokemonListCache[cacheKey] = pokemonList;
        _cacheTimestamps[cacheKey] = DateTime.now();

        _saveCacheToFile();

        return pokemonList;
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      // In case of error, return cache even if it's outdated
      if (_pokemonListCache.containsKey(cacheKey)) {
        return _pokemonListCache[cacheKey]!;
      }
      throw Exception('Failed to load Pokémon: $e');
    }
  }

  Future<Pokemon> fetchPokemonDetails(int id) async {
    final String cacheKey = 'pokemon_$id';

    if (_pokemonCache.containsKey(id) && _isCacheValid(cacheKey)) {
      return _pokemonCache[id]!;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

      if (response.statusCode == 200) {
        final pokemonData = jsonDecode(response.body);
        final Pokemon pokemon = Pokemon.fromJson(pokemonData);

        _pokemonCache[id] = pokemon;
        _cacheTimestamps[cacheKey] = DateTime.now();

        _saveCacheToFile();

        return pokemon;
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      // In case of error, return cache even if it's outdated
      if (_pokemonCache.containsKey(id)) {
        return _pokemonCache[id]!;
      }
      throw Exception('Failed to load Pokémon details: $e');
    }
  }

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