import 'package:flutter/material.dart';

class CarbonFootprintCalculatorPage extends StatefulWidget {
  const CarbonFootprintCalculatorPage({Key? key}) : super(key: key);

  @override
  _CarbonFootprintCalculatorPageState createState() =>
      _CarbonFootprintCalculatorPageState();
}

class _CarbonFootprintCalculatorPageState
    extends State<CarbonFootprintCalculatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List to store user inputs for each tab
  List<String> _userInputs = List.generate(9, (index) => ''); // Updated to 9 inputs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // Total tabs including the new Fuel tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      setState(() {
        _tabController.index++;
      });
    }
  }

  void _previousTab() {
    if (_tabController.index > 0) {
      setState(() {
        _tabController.index--;
      });
    }
  }

  void _updateUserInput(int index, String input) {
    setState(() {
      _userInputs[index] = input; // Save the input in the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Calculator'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.green,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Electric'),
            Tab(text: 'Heat'),
            Tab(text: 'Vehicle'),
            Tab(text: 'Air'),
            Tab(text: 'Rail'),
            Tab(text: 'Shipping'),
            Tab(text: 'Events'),
            Tab(text: 'Fuel'),  // New Fuel tab added
            Tab(text: 'Total'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CarbonFootprintTab(
            title: 'Electric',
            emissionFactor: 0.0004167,
            costFactor: 0.06,
            input: _userInputs[0],
            onInputChanged: (input) => _updateUserInput(0, input),
          ),
          CarbonFootprintTab(
            title: 'Heat',
            emissionFactor: 105,
            costFactor: 0.10,
            input: _userInputs[1],
            onInputChanged: (input) => _updateUserInput(1, input),
          ),
          CarbonFootprintTab(
            title: 'Vehicle',
            emissionFactor: 0.79,
            costFactor: 0.05,
            input: _userInputs[2],
            onInputChanged: (input) => _updateUserInput(2, input),
          ),
          CarbonFootprintTab(
            title: 'Air',
            emissionFactor: 1100,
            costFactor: 0.12,
            input: _userInputs[3],
            onInputChanged: (input) => _updateUserInput(3, input),
          ),
          CarbonFootprintTab(
            title: 'Rail',
            emissionFactor: 0.04,
            costFactor: 0.01,
            input: _userInputs[4],
            onInputChanged: (input) => _updateUserInput(4, input),
          ),
          CarbonFootprintTab(
            title: 'Shipping',
            emissionFactor: 0.001,
            costFactor: 0.02,
            input: _userInputs[5],
            onInputChanged: (input) => _updateUserInput(5, input),
          ),
          CarbonFootprintTab(
            title: 'Events',
            emissionFactor: 0.05,
            costFactor: 0.15,
            input: _userInputs[6],
            onInputChanged: (input) => _updateUserInput(6, input),
          ),
          FuelTab( // New Fuel tab
            input: _userInputs[7],
            onInputChanged: (input) => _updateUserInput(7, input),
          ),
          TotalTab( // Total Tab to calculate overall emissions and costs
            userInputs: _userInputs,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousTab,
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed: _nextTab,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class CarbonFootprintTab extends StatefulWidget {
  final String title;
  final double emissionFactor; // For CO2 emission calculation
  final double costFactor; // USD cost per unit
  final String input; // Accept the current input
  final Function(String) onInputChanged; // Callback for input change

  const CarbonFootprintTab({
    Key? key,
    required this.title,
    required this.emissionFactor,
    required this.costFactor,
    required this.input,
    required this.onInputChanged,
  }) : super(key: key);

  @override
  _CarbonFootprintTabState createState() => _CarbonFootprintTabState();
}

class _CarbonFootprintTabState extends State<CarbonFootprintTab> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.input);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _kWh = double.tryParse(_inputController.text) ?? 0.0;

    // Calculate CO2 Emission in tonnes
    double _co2Emission = _kWh * widget.emissionFactor;

    // Calculate total cost in USD, and convert to INR (assuming 1 USD = ₹80)
    double _totalCostInUSD = _kWh * widget.costFactor;
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
              const Text('EMISSION TOTALS', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text('kWh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: TextFormField(
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter kWh',
                      ),
                      onChanged: (input) {
                        widget.onInputChanged(input);
                        setState(() {}); // Update calculations dynamically
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tonnes CO2:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(_co2Emission.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cost (in Rs):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

class FuelTab extends StatefulWidget {
  final String input; // Accept the current input
  final Function(String) onInputChanged; // Callback for input change

  const FuelTab({
    Key? key,
    required this.input,
    required this.onInputChanged,
  }) : super(key: key);

  @override
  _FuelTabState createState() => _FuelTabState();
}

class _FuelTabState extends State<FuelTab> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.input);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _litres = double.tryParse(_inputController.text) ?? 0.0;

    // Calculate CO2 Emission in tonnes for Fuel
    double _co2Emission = _litres * 2.31; // Assuming 2.31 kg CO2 per litre of gasoline

    // Calculate total cost in USD, and convert to INR (assuming 1 USD = ₹80)
    double _totalCostInUSD = _litres * 0.9; // Assuming cost of gasoline is $0.9 per litre
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
              const Text('FUEL USAGE', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Litres:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: TextFormField(
                      controller: _inputController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter litres of fuel',
                      ),
                      onChanged: (input) {
                        widget.onInputChanged(input);
                        setState(() {}); // Update calculations dynamically
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tonnes CO2:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(_co2Emission.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cost (in Rs):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

class TotalTab extends StatelessWidget {
  final List<String> userInputs; // Store inputs from each tab

  const TotalTab({
    Key? key,
    required this.userInputs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total emissions and costs
    double totalEmissions = 0.0;
    double totalCosts = 0.0;

    // Electricity
    double electricKWh = double.tryParse(userInputs[0]) ?? 0.0;
    totalEmissions += electricKWh * 0.0004167; // CO2 emission
    totalCosts += electricKWh * 0.06; // Cost in USD

    // Heat
    double heatKWh = double.tryParse(userInputs[1]) ?? 0.0;
    totalEmissions += heatKWh * 105; // CO2 emission
    totalCosts += heatKWh * 0.10; // Cost in USD

    // Vehicle
    double vehicleMileage = double.tryParse(userInputs[2]) ?? 0.0;
    totalEmissions += vehicleMileage * 0.79; // CO2 emission
    totalCosts += vehicleMileage * 0.05; // Cost in USD

    // Air Travel
    double airFlights = double.tryParse(userInputs[3]) ?? 0.0;
    totalEmissions += airFlights * 1100; // CO2 emission
    totalCosts += airFlights * 0.12; // Cost in USD

    // Rail Travel
    double railDistance = double.tryParse(userInputs[4]) ?? 0.0;
    totalEmissions += railDistance * 0.04; // CO2 emission
    totalCosts += railDistance * 0.01; // Cost in USD

    // Shipping
    double shippingDistance = double.tryParse(userInputs[5]) ?? 0.0;
    totalEmissions += shippingDistance * 0.001; // CO2 emission
    totalCosts += shippingDistance * 0.02; // Cost in USD

    // Events
    double eventsCount = double.tryParse(userInputs[6]) ?? 0.0;
    totalEmissions += eventsCount * 0.05; // CO2 emission
    totalCosts += eventsCount * 0.15; // Cost in USD

    // Fuel
    double fuelLitres = double.tryParse(userInputs[7]) ?? 0.0;
    totalEmissions += fuelLitres * 2.31; // CO2 emission
    totalCosts += fuelLitres * 0.9; // Cost in USD

    // Total emissions in tonnes
    totalEmissions /= 1000; // Convert grams to tonnes

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
              const Text('TOTAL CARBON FOOTPRINT', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total CO2 (tonnes):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(totalEmissions.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cost (in Rs):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('₹${(totalCosts * 80).toStringAsFixed(2)}',
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
