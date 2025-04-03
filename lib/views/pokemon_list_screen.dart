import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_models/pokemon_view_model.dart';
import '../models/pokemon_model.dart';
import 'pokemon_detail_screen.dart';
import 'package:flutter/cupertino.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({Key? key}) : super(key: key);

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les Pokémon au démarrage
    Future.microtask(() =>
        Provider.of<PokemonViewModel>(context, listen: false).fetchPokemons());
  }

  void _showSortOptions(PokemonViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text('Sort by ID ${viewModel.currentSortOption == SortOption.id ? (viewModel.sortAscending ? "↑" : "↓") : ""}'),
                onTap: () {
                  viewModel.toggleSortOption(SortOption.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text('Sort by Name ${viewModel.currentSortOption == SortOption.name ? (viewModel.sortAscending ? "↑" : "↓") : ""}'),
                onTap: () {
                  viewModel.toggleSortOption(SortOption.name);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<PokemonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.pokemons.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error.isNotEmpty && viewModel.pokemons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.error,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchPokemons(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = viewModel.pokemons[index];
              return PokemonListItem(pokemon: pokemon);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00ACC1),
        foregroundColor: Colors.white,
        onPressed: () {
          final viewModel = Provider.of<PokemonViewModel>(context, listen: false);
          _showSortOptions(viewModel);
        },
        child: const Icon(Icons.swap_vert),
      ),
    );
  }
}

class PokemonListItem extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonListItem({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => PokemonDetailScreen(pokemonId: pokemon.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // ID du Pokémon
              Container(
                width: 56,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),

              // Image du Pokémon
              Hero(
                tag: 'pokemon-${pokemon.id}',
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 11),

              // Informations du Pokémon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.name.substring(0, 1).toUpperCase() + pokemon.name.substring(1),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: pokemon.types.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 5.6),
                          child: Chip(
                            backgroundColor: type.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                            label: Text(
                              type.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}