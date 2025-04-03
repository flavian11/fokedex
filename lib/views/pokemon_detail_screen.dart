import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon_model.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailScreen({Key? key, required this.pokemonId}) : super(key: key);

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<Pokemon> _pokemonFuture;
  final PokemonService _pokemonService = PokemonService();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pokemonFuture = _pokemonService.fetchPokemonDetails(widget.pokemonId);
  }

  // get bg color based on pokemon types
  Color getBackgroundColor(List<PokemonType> types) {
    if (types.isEmpty) return Colors.grey.shade200;
    return types[0].pastelColor;
  }

  Future<void> playPokemonCry(Pokemon pokemon) async {
    final url = "https://play.pokemonshowdown.com/audio/cries/${pokemon.name.replaceAll("-", "").toLowerCase()}.mp3";
    try {
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible de jouer le cri du Pokémon"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pokemon>(
      future: _pokemonFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        Color appBarColor = Colors.red;
        Color backgroundColor = Colors.grey.shade100;

        if (snapshot.hasData) {
          final pokemon = snapshot.data!;
          backgroundColor = getBackgroundColor(pokemon.types);
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: appBarColor,
            title: Text("Détails"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: isLoading ?
          const Center(child: CircularProgressIndicator()) :
          hasError ?
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _pokemonFuture = _pokemonService.fetchPokemonDetails(widget.pokemonId);
                    });
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ) :
          _buildPokemonDetails(snapshot.data!, backgroundColor),
        );
      },
    );
  }

  Widget _buildPokemonDetails(Pokemon pokemon, Color bgColor) {
    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header with types and img
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: getBackgroundColor(pokemon.types),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    pokemon.name.substring(0, 1).toUpperCase() + pokemon.name.substring(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokemon.types.map<Widget>((type) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: type.color,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          type.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // pokemon base info
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn("Height", "${pokemon.height / 10}m"),
                  _buildInfoColumn("Weight", "${pokemon.weight / 10}kg"),
                  _buildInfoColumn("Base EXP", "${pokemon.baseExp ?? '?'}"),
                ],
              ),
            ),

            // Pokemon stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBadge("hp", pokemon.stats.hp, Colors.red),
                      _buildStatBadge("atk", pokemon.stats.atk, Colors.orange),
                      _buildStatBadge("def", pokemon.stats.def, Colors.yellow),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBadge("spa", pokemon.stats.speAtk, Colors.blue.shade300),
                      _buildStatBadge("spd", pokemon.stats.speDef, Colors.green.shade300),
                      _buildStatBadge("spe", pokemon.stats.speed, Colors.pink.shade300),
                    ],
                  ),
                ],
              ),
            ),

            // Play cry button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.volume_up),
                label: Text("Play Cry", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pokemon.types[0].color,
                  foregroundColor: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => playPokemonCry(pokemon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          "$value",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}