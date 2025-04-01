import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/pokemon_model.dart';
import 'services/pokemon_service.dart';
import 'views/pokemon_list_screen.dart';
import 'view_models/pokemon_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PokemonViewModel(PokemonService()),
      child: MaterialApp(
        title: 'Pokédex',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF5252),
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF5252),
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.system,
        home: const PokemonListScreen(),
      ),
    );
  }
}