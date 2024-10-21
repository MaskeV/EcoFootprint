import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsScreen extends StatefulWidget {
  @override
  _TipsScreenState createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  void _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    bool? hasVisited = prefs.getBool('hasVisited');

    if (hasVisited == null || !hasVisited) {
      _showCarbonFootprintTipsDialog();
      await prefs.setBool('hasVisited', true);
    }
  }

  void _showCarbonFootprintTipsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Carbon Footprint Tips'),
          content: CarbonFootprintTipsContent(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoFootprint'),
      ),
      body: Center(
        child: Text('Welcome to EcoFootprint App!'),
      ),
    );
  }
}

class CarbonFootprintTipsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Here are some tips for reducing your carbon footprint:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          _buildTip(
            '1. Reduce your meat consumption: Eating less meat can help reduce greenhouse gas emissions from livestock and the production of animal feed.',
          ),
          _buildTip(
            '2. Use energy-efficient appliances: Switching to energy-efficient appliances can help reduce your electricity usage and carbon footprint.',
          ),
          _buildTip(
            '3. Walk, bike, or take public transportation: Using alternative modes of transportation can help reduce your carbon footprint from driving.',
          ),
          _buildTip(
            '4. Plant trees: Trees absorb carbon dioxide from the atmosphere and can help reduce greenhouse gas emissions.',
          ),
          _buildTip(
            '5. Reduce your plastic usage: Plastics are made from fossil fuels and contribute to greenhouse gas emissions when they are produced and disposed of.',
          ),
          _buildTip(
            '6. Use renewable energy sources: Switching to renewable energy sources like solar or wind power can help reduce your carbon footprint.',
          ),
          SizedBox(height: 16.0),
          Text(
            'Remember, every small action counts towards reducing our carbon footprint and protecting the environment for future generations.',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
}
