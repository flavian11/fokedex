import 'package:flutter/material.dart';

class PokemonType {
  final String name;
  final Color color;
  final Color pastelColor;

  PokemonType({required this.name, required this.color, required this.pastelColor});

  factory PokemonType.fromName(String name) {
    switch (name.toLowerCase()) {
      case 'grass':
        return PokemonType(name: 'grass', color: const Color(0xFF78C850), pastelColor: const Color(0xFFC8F0C0));
      case 'poison':
        return PokemonType(name: 'poison', color: const Color(0xFFA040A0), pastelColor: const Color(0xFFE8C0E8));
      case 'fire':
        return PokemonType(name: 'fire', color: const Color(0xFFF08030), pastelColor: const Color(0xFFFFC7A0));
      case 'flying':
        return PokemonType(name: 'flying', color: const Color(0xFFA890F0), pastelColor: const Color(0xFFE0D8FF));
      case 'water':
        return PokemonType(name: 'water', color: const Color(0xFF6890F0), pastelColor: const Color(0xFFC8E0FF));
      case 'electric':
        return PokemonType(name: 'electric', color: const Color(0xFFF8D030), pastelColor: const Color(0xFFFFF5B3));
      case 'ice':
        return PokemonType(name: 'ice', color: const Color(0xFF98D8D8), pastelColor: const Color(0xFFD8F0F0));
      case 'ground':
        return PokemonType(name: 'ground', color: const Color(0xFFE0C068), pastelColor: const Color(0xFFF0E0B0));
      case 'rock':
        return PokemonType(name: 'rock', color: const Color(0xFFB8A038), pastelColor: const Color(0xFFE8D8B0));
      case 'psychic':
        return PokemonType(name: 'psychic', color: const Color(0xFFF85888), pastelColor: const Color(0xFFFFD0E0));
      case 'bug':
        return PokemonType(name: 'bug', color: const Color(0xFFA8B820), pastelColor: const Color(0xFFE0E8B0));
      case 'dragon':
        return PokemonType(name: 'dragon', color: const Color(0xFF7038F8), pastelColor: const Color(0xFFD0C0FF));
      case 'ghost':
        return PokemonType(name: 'ghost', color: const Color(0xFF705898), pastelColor: const Color(0xFFD0C8E0));
      case 'dark':
        return PokemonType(name: 'dark', color: const Color(0xFF705848), pastelColor: const Color(0xFFD0C0B0));
      case 'steel':
        return PokemonType(name: 'steel', color: const Color(0xFFB8B8D0), pastelColor: const Color(0xFFE0E0F0));
      case 'fairy':
        return PokemonType(name: 'fairy', color: const Color(0xFFEE99AC), pastelColor: const Color(0xFFFFE0E8));
      case 'fighting':
        return PokemonType(name: 'fighting', color: const Color(0xFFC03028), pastelColor: const Color(0xFFFFB8B0));
      case 'normal':
        return PokemonType(name: 'normal', color: const Color(0xFFA8A878), pastelColor: const Color(0xFFDCDCDC));
      default:
        return PokemonType(name: name, color: Colors.grey, pastelColor: Colors.grey);
    }
  }

  // Méthode toJson pour sérialiser PokemonType
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'pastelColor': pastelColor.value,
    };
  }

  // Factory pour désérialiser depuis JSON
  factory PokemonType.fromJson(Map<String, dynamic> json) {
    // Si nous avons juste le nom, utiliser la factory existante
    if (json.containsKey('name') && !json.containsKey('color')) {
      return PokemonType.fromName(json['name']);
    }

    // Sinon, créer directement à partir des valeurs stockées
    return PokemonType(
      name: json['name'],
      color: Color(json['color']),
      pastelColor: Color(json['pastelColor']),
    );
  }
}

class PokemonStats {
  final int hp;
  final int atk;
  final int def;
  final int speAtk;
  final int speDef;
  final int speed;

  PokemonStats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.speAtk,
    required this.speDef,
    required this.speed
  });

  factory PokemonStats.fromStats(List<dynamic> stats) {
    int hp = 0;
    int atk = 0;
    int def = 0;
    int speAtk = 0;
    int speDef = 0;
    int speed = 0;

    for (var stat in stats) {
      String statName = stat['stat']['name'];
      int baseStat = stat['base_stat'];

      switch (statName) {
        case 'hp':
          hp = baseStat;
          break;
        case 'attack':
          atk = baseStat;
          break;
        case 'defense':
          def = baseStat;
          break;
        case 'special-attack':
          speAtk = baseStat;
          break;
        case 'special-defense':
          speDef = baseStat;
          break;
        case 'speed':
          speed = baseStat;
          break;
      }
    }

    return PokemonStats(
        hp: hp,
        atk: atk,
        def: def,
        speAtk: speAtk,
        speDef: speDef,
        speed: speed
    );
  }

  // Méthode toJson pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'hp': hp,
      'atk': atk,
      'def': def,
      'speAtk': speAtk,
      'speDef': speDef,
      'speed': speed,
    };
  }

  // Factory pour désérialiser depuis JSON
  factory PokemonStats.fromJson(Map<String, dynamic> json) {
    return PokemonStats(
      hp: json['hp'],
      atk: json['atk'],
      def: json['def'],
      speAtk: json['speAtk'],
      speDef: json['speDef'],
      speed: json['speed'],
    );
  }
}

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExp;
  final String imageUrl;
  final List<PokemonType> types;
  final PokemonStats stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExp,
    required this.imageUrl,
    required this.types,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    List typesJson = [];

    // Gérer les différentes structures possibles pour les types
    if (json.containsKey('types')) {
      if (json['types'] is List) {
        typesJson = json['types'];
      }
    }

    List<PokemonType> pokemonTypes = [];

    // Convertir les types selon leur format
    if (typesJson.isNotEmpty) {
      if (typesJson.first is Map && typesJson.first.containsKey('type')) {
        // Format API: [{"type": {"name": "grass"}}]
        pokemonTypes = typesJson.map((typeEntry) {
          return PokemonType.fromName(typeEntry['type']['name']);
        }).toList();
      } else if (typesJson.first is Map && typesJson.first.containsKey('name')) {
        // Format cache: [{"name": "grass", "color": 123456, "pastelColor": 654321}]
        pokemonTypes = typesJson.map((typeEntry) {
          return PokemonType.fromJson(typeEntry);
        }).toList();
      }
    }

    // Gérer les différentes structures possibles pour les stats
    PokemonStats pokemonStats;
    if (json.containsKey('stats')) {
      if (json['stats'] is List) {
        // Format API: [{"base_stat": 45, "stat": {"name": "hp"}}]
        pokemonStats = PokemonStats.fromStats(json['stats']);
      } else if (json['stats'] is Map) {
        // Format cache: {"hp": 45, "atk": 60, ...}
        pokemonStats = PokemonStats.fromJson(json['stats']);
      } else {
        // Valeurs par défaut si format inconnu
        pokemonStats = PokemonStats(hp: 0, atk: 0, def: 0, speAtk: 0, speDef: 0, speed: 0);
      }
    } else {
      // Valeurs par défaut si pas de stats
      pokemonStats = PokemonStats(hp: 0, atk: 0, def: 0, speAtk: 0, speDef: 0, speed: 0);
    }

    return Pokemon(
        id: id,
        name: json['name'],
        height: json["height"],
        weight: json["weight"],
        baseExp: json["base_experience"],
        imageUrl: json['imageUrl'] ?? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
        types: pokemonTypes,
        stats: pokemonStats
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'base_experience': baseExp,
      'imageUrl': imageUrl,
      'types': types.map((type) => type.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}