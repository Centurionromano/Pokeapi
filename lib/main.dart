import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéAPI Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const PokemonHome(),
    );
  }
}

class PokemonHome extends StatefulWidget {
  const PokemonHome({super.key});

  @override
  State<PokemonHome> createState() => _PokemonHomeState();
}

class _PokemonHomeState extends State<PokemonHome> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      pokemonData = null;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pokémon no encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Pokémon')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Escribe el nombre del Pokémon (ej: pikachu)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchPokemon(_controller.text.toLowerCase()),
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (pokemonData != null)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      pokemonData!['name'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      pokemonData!['sprites']['front_default'],
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    Text('Altura: ${pokemonData!['height']}'),
                    Text('Peso: ${pokemonData!['weight']}'),
                    Text(
                      'Tipo: ${(pokemonData!['types'] as List)
                          .map((t) => t['type']['name'])
                          .join(', ')}',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
