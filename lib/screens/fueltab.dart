import 'package:flutter/material.dart';

class FuelFootprintTab extends StatefulWidget {
  final String title;
  final double emissionFactor; // Emission factor for CO2 calculation
  final double costFactor; // Cost per gallon
  final String input;
  final Function(String) onInputChanged;

  const FuelFootprintTab({
    Key? key,
    required this.title,
    required this.emissionFactor,
    required this.costFactor,
    required this.input,
    required this.onInputChanged,
  }) : super(key: key);

  @override
  _FuelFootprintTabState createState() => _FuelFootprintTabState();
}

class _FuelFootprintTabState extends State<FuelFootprintTab> {
  late TextEditingController _gallonsController;
  String _selectedFuelType = 'Oil'; // Default fuel type
  final Map<String, double> _fuelEmissions = {
    'Oil': 0.0102, // Emission factor for Oil in tonnes CO2 per gallon
    'Gas': 0.0053, // Example factor for Gas
    'Propane': 0.012, // Example factor for Propane
  };
  final Map<String, double> _fuelCostPerGallon = {
    'Oil': 1.25, // USD cost per gallon of Oil
    'Gas': 1.10, // Example cost for Gas
    'Propane': 1.50, // Example cost for Propane
  };

  @override
  void initState() {
    super.initState();
    _gallonsController = TextEditingController(text: widget.input);
  }

  @override
  void dispose() {
    _gallonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _gallons = double.tryParse(_gallonsController.text) ?? 0.0;
    double _emissionFactor = _fuelEmissions[_selectedFuelType]!;
    double _costFactor = _fuelCostPerGallon[_selectedFuelType]!;

    // Calculate CO2 Emission in tonnes
    double _co2Emission = _gallons * _emissionFactor;

    // Calculate total cost in USD, and convert to INR (assuming 1 USD = ₹80)
    double _totalCostInUSD = _gallons * _costFactor;
    double _totalCostInINR = _totalCostInUSD * 80;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.green,
                  )),
              const SizedBox(height: 16.0),
              const Text('Fuel Type', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8.0),
              DropdownButton<String>(
                value: _selectedFuelType,
                items: _fuelEmissions.keys
                    .map((fuelType) => DropdownMenuItem(
                          value: fuelType,
                          child: Text(fuelType),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedFuelType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Gallons', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _gallonsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter gallons',
                ),
                onChanged: (input) {
                  widget.onInputChanged(input);
                  setState(() {}); // Update calculations dynamically
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tonnes CO2:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(_co2Emission.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cost (in Rs):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('₹${_totalCostInINR.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
