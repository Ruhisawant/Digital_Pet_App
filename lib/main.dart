import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  DigitalPetAppState createState() => DigitalPetAppState();
}

class DigitalPetAppState extends State<DigitalPetApp> {
  final TextEditingController _controller = TextEditingController();
  late ConfettiController _confettiController;
  String petName = "Your Pet";
  String _selectedActivity = 'Play';
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 50;
  int _seconds = 30;
  int winSeconds = 0; 
  bool gameOver = false; 
  bool hasWon = false; 
  Timer? _timer;

  // Determines the color of the pet based on its happiness level
  Color petColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // Returns an emoji based on the pet's mood
  String petMood() {
    if (happinessLevel > 70) {
      return '😁';
    } else if (happinessLevel >= 30) {
      return '😑';
    } else {
      return '😭';
    }
  }

  // Increases happiness, decreases energy, and updates hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _energyLevel = (_energyLevel - 10).clamp(0, 100);
    });
  }

  // Decreases hunger, increases energy, and updates happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _energyLevel = (_energyLevel + 10).clamp(0, 100);
    });
    _countdown();
  }

  // Updates happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increases hunger over time
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Starts a countdown for hunger and manages game logic based on seconds
  void _countdown() {
    _timer?.cancel();
    _seconds = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameOver || hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _seconds = 30;
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
        }

        if (happinessLevel > 80) {
          winSeconds++;
        } else {
          winSeconds = 0;
        }

        if (hungerLevel >= 100 && happinessLevel <= 10) {
          gameOver = true;
        } else if (winSeconds >= 180) {
          hasWon = true;
          _confettiController.play(); // Start confetti
        }
      });
    });
  }

  // Calls the appropriate pet activity based on selected activity
  void _performActivity() {
    if (_selectedActivity == 'Play') {
      _playWithPet();
    } else if (_selectedActivity == 'Feed') {
      _feedPet();
    }
  }

  // Resets the game state when restarting
  void resetGame() { 
    setState(() {
      hasWon = false; 
      gameOver = false; 
      winSeconds = 0; 
      happinessLevel = 50; 
      hungerLevel = 50; 
      _energyLevel = 50; 
      _seconds = 30; 
      _countdown(); 
    });
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _countdown(); // Starts the countdown timer when the app is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancels the timer when the widget is disposed of
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Game Over screen
    if (gameOver) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Text('Game Over!', style: TextStyle(fontSize: 40, color: Colors.red)), 
              const SizedBox(height: 30), 
              ElevatedButton(
                onPressed: resetGame,
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
      );
    }

    // Winning screen and confetti animation
    if (hasWon) {
      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  const Text('You Win!', style: TextStyle(fontSize: 50, color: Colors.green)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.red, Colors.blue, Colors.purple, Colors.yellow, Colors.pink],
              ),
            ),
          ],
        ),
      );
    }


    // Main gameplay screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet App'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Pet name input field
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: "What's your pet's name?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      petName = _controller.text;
                    });
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text('Name: $petName', style: const TextStyle(fontSize: 30.0)),

            // Pet color and image display
            const SizedBox(height: 10),
            Container(
              width: 250,
              height: 250,
              color: petColor(),
              child: Image.asset('assets/images/cat.png', fit: BoxFit.cover),
            ),

            Text('Mood: ${petMood()}', style: const TextStyle(fontSize: 30.0, color: Colors.black)),
            const SizedBox(height: 20),

            // Displaying happiness and hunger levels
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Happiness Level: $happinessLevel', style: const TextStyle(fontSize: 20.0)),
                  const SizedBox(height: 10),
                  Text('Hunger Level: $hungerLevel', style: const TextStyle(fontSize: 20.0)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Your pet will be hungry in $_seconds seconds', style: const TextStyle(fontSize: 20.0, color: Colors.red)),
            
            // Dropdown to select activity
            DropdownButton<String>(
              value: _selectedActivity,
              items: ['Play', 'Feed'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedActivity = newValue!;
                });
              },
            ),

            // Button to confirm the selected activity
            ElevatedButton(
              onPressed: _performActivity,
              child: const Text('Confirm Activity'),
            ),
            const SizedBox(height: 20),
            // Displaying energy level with a progress bar
            Text('Energy Level: $_energyLevel',
                style: const TextStyle(fontSize: 20.0)),
            SizedBox(
              width: 300,
              child: LinearProgressIndicator(
                value: _energyLevel / 100.0,
                minHeight: 10.0,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
