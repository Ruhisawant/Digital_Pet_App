import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  final TextEditingController _controller = TextEditingController();
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 50;
  int _seconds = 30;
  Timer? _timer;
  String _selectedActivity = 'Play';

  Color petColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String petMood() {
    if (happinessLevel > 70) {
      return '😁';
    } else if (happinessLevel >= 30) {
      return '😑';
    } else {
      return '😭';
    }
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _energyLevel = (_energyLevel - 10).clamp(0, 100);
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _energyLevel = (_energyLevel + 10).clamp(0, 100);
    });
    _countdown();
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  void _countdown() {
    _timer?.cancel();
    _seconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          _seconds = 30;
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
        });
      }
    });
  }

  void _performActivity() {
    if (_selectedActivity == 'Play') {
      _playWithPet();
    } else if (_selectedActivity == 'Feed') {
      _feedPet();
    }
  }

  @override
  void initState() {
    super.initState();
    _countdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet App'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            Text('Name: $petName', style: const TextStyle(fontSize: 40.0)),

            const SizedBox(height: 10),
            Container(
              width: 250,
              height: 250,
              color: petColor(),
              child: Image.asset('assets/images/cat.png', fit: BoxFit.cover),
            ),

            Text('Mood: ${petMood()}', style: const TextStyle(fontSize: 40.0, color: Colors.black)),
            
            const SizedBox(height: 20),
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

            ElevatedButton(
              onPressed: _performActivity,
              child: const Text('Confirm Activity'),
            ),
            const SizedBox(height: 20),
            Text('Energy Level: $_energyLevel',
                style: const TextStyle(fontSize: 20.0)),
            SizedBox(
              width: 300,
              child: LinearProgressIndicator(
                value: _energyLevel / 100.0,
                minHeight: 10.0,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
