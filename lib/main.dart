import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complete Travel Details Input',
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
  final TextEditingController _destinationCityController =
      TextEditingController();
  final TextEditingController _numberOfPeopleController =
      TextEditingController();
  final TextEditingController _luggageController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));

  String _currentCity = '';
  String _destinationCity = '';
  String _numberOfPeople = '';
  String _luggage = '';
  String _budget = '';

  Future<void> chatWithGPT(String prompt) async {
    final openAiApiKey = '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';

    OpenAI.apiKey = openAiApiKey;
    final messages = [
      OpenAIChatCompletionChoiceMessageModel(
        content: prompt,
        role: OpenAIChatMessageRole.user,
      ),
    ];

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: messages,
        maxTokens: 500,
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'generate_items_to_be_carried',
            description:
                'Generate items to be carried.',
            parameters: [
              OpenAIFunctionProperty.object(
                name: 'Items',
                description:
                    'Items to be carried',
                isRequired: true,
                properties: [
                  OpenAIFunctionProperty.string(
                    name: 'Item to be carried',
                    description: 'Item',
                    isRequired: true,
                  ),
                ],
              ),
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('generate_items_to_be_carried'),
      );

      var functionResponse = chatCompletion.choices.first.message.functionCall;
      print("Recommended items to carry: ${functionResponse}");
    } catch (e) {
      print("Error communicating with GPT-3.5: $e");
    }
  }

  void _submitForm() {
    setState(() {
      _currentCity = _currentCityController.text;
      _destinationCity = _destinationCityController.text;
      _numberOfPeople = _numberOfPeopleController.text;
      _luggage = _luggageController.text;
      _budget = _budgetController.text;
    });

    String travelDetails =
        'Travel from $_currentCity to $_destinationCity for $_numberOfPeople people with $_luggage pieces of luggage from ${_startDate.toLocal()} to ${_endDate.toLocal()} within a budget of $_budget INR. What will be the things to carry?';
    chatWithGPT(travelDetails);
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
              decoration: InputDecoration(
                labelText: 'Number of People',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _luggageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Luggage (number of items)',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget (INR)',
              ),
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
            Text('Luggage: $_luggage'),
            Text('Budget: $_budget'),
          ],
        ),
      ),
    );
  }
}
