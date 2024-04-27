import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services to use input formatters

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Travel Details Input',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _currentCityController = TextEditingController();
  final TextEditingController _destinationCityController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();
  final TextEditingController _luggageController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));

  String _currentCity = '';
  String _destinationCity = '';
  String _numberOfPeople = '';
  String _luggage = '';
  String _budget = '';

  void _submitForm() {
    setState(() {
      _currentCity = _currentCityController.text;
      _destinationCity = _destinationCityController.text;
      _numberOfPeople = _numberOfPeopleController.text;
      _luggage = _luggageController.text;
      _budget = _budgetController.text;
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Travel Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _currentCityController,
              decoration: InputDecoration(
                labelText: 'Current City',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _destinationCityController,
              decoration: InputDecoration(
                labelText: 'Destination City',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectStartDate(context),
              child: Text('Select Start Date'),
            ),
            Text('Start Date: ${_startDate.toLocal()}'.split(' ')[0]),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectEndDate(context),
              child: Text('Select End Date'),
            ),
            Text('End Date: ${_endDate.toLocal()}'.split(' ')[0]),
            SizedBox(height: 20),
            TextField(
              controller: _numberOfPeopleController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Number of People',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _luggageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Luggage (kg)',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget (INR)',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            Text('Current City: $_currentCity'),
            Text('Destination City: $_destinationCity'),
            Text('Number of People: $_numberOfPeople'),
            Text('Luggage: $_luggage kg'),
            Text('Budget: $_budget INR'),
          ],
        ),
      ),
    );
  }
}
