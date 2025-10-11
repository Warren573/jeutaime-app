import 'package:flutter/material.dart';
import '../models/pet_social.dart';

class PetAdoptScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int currentCoins;
  
  const PetAdoptScreen({
    super.key,
    required this.onCoinsUpdated,
    required this.currentCoins,
  });

  @override
  State<PetAdoptScreen> createState() => _PetAdoptScreenState();
}

class _PetAdoptScreenState extends State<PetAdoptScreen> {
  Pet? myAdoptedPet;
  List<Pet> availablePets = [];
  List<Pet> incarnatedPetsNearby = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      // Générer des animaux disponibles à l'adoption
      availablePets = List.generate(4, (index) {
        final types = PetType.values;
        final names = ['Max', 'Luna', 'Charlie', 'Bella'];
        
        return Pet.generateAnimal(
          'available_${index}',
          UserMode.adopter,
          types[index % types.length],
          names[index],
        );
      });
      
      // Générer des animaux incarnés à proximité
      incarnatedPetsNearby = List.generate(3, (index) {
        final types = [PetType.cat, PetType.dog, PetType.rabbit];
        final names = ['Shadow', 'Whiskers', 'Fluffy'];
        
        return Pet.generateAnimal(
          'incarnated_${index}',
          UserMode.incarnate,
          types[index],
          names[index],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        title: const Text('🏠 Adoption d\'Animaux', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (myAdoptedPet == null) ...[
              const Text(
                '🏠 Adoptez votre compagnon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Animaux disponibles à l'adoption
              ...availablePets.map((pet) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Text(pet.emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            pet.type.toString().split('.').last,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          myAdoptedPet = pet;
                          availablePets.remove(pet);
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Adopter', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )),
            ] else ...[
              // Mon animal adopté
              const Text(
                '🏠 Mon Animal de Compagnie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(myAdoptedPet!.emoji, style: const TextStyle(fontSize: 60)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myAdoptedPet!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                myAdoptedPet!.type.toString().split('.').last,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Animaux incarnés à proximité
              const Text(
                '🎭 Animaux incarnés à proximité',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ...incarnatedPetsNearby.map((pet) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1e1e),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.purple.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Text(pet.emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Animal incarné',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vous offrez une friandise à ${pet.name} !'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('🍪', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vous proposez un jeu à ${pet.name} !'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('🎾', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}