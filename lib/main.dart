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
            name: 'get_multiple_checkpoints',
            description: 'Get checkpoints within the destination',
            parameters: [
              OpenAIFunctionProperty.object(
                name: 'checkpoints',
                description: 'Checkpoints where transport needs to be changed',
                isRequired: true,
                properties: [
                  OpenAIFunctionProperty.string(
                    name: 'Checkpoint',
                    description:
                        'The checkpoint not including current city. eg. Delhi',
                    isRequired: true,
                  ),
                  OpenAIFunctionProperty.object(
                      name: 'multiple_low_impact_transport_options',
                      description:
                          'Low impact transport options to travel to checkpoints from previous',
                      isRequired: true,
                      properties: [
                        OpenAIFunctionProperty.string(
                          name: 'low_impact_transport',
                          description:
                              'Low impact transport to travel to checkpoint from previous eg. Train',
                          isRequired: true,
                        ),
                        OpenAIFunctionProperty.string(
                          name: 'carbon_footprint',
                          description:
                              'Estimated carbon footprint via transport while travelling to checkpoint from previous',
                          isRequired: true,
                        ),
                        OpenAIFunctionProperty.string(
                          name: 'estimated_price',
                          description:
                              'Estimated price for transport for travelling to current checkpoint from previous checkpoint',
                          isRequired: true,
                        ),
                      ]),
                ],
              ),
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('get_multiple_checkpoints'),
      );

      FunctionCallResponse? response =
          chatCompletion.choices.first.message.functionCall;
      var arguments = response?.arguments;
      var checkpoints = arguments?['checkpoints'];
      List<Map<String, dynamic>> checkpointDetails = [];

      for (var checkpoint in checkpoints) {
        var checkpointName = checkpoint['Checkpoint'];
        var transportOptions =
            checkpoint['multiple_low_impact_transport_options'];

        // Preparing data for display or further processing
        checkpointDetails.add({
          'checkpoint': checkpointName,
          'transport_options': transportOptions['low_impact_transport'],
          'carbon_footprint': transportOptions['carbon_footprint'],
          'estimated_price': transportOptions['estimated_price'],
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailsPage(checkpointDetails: checkpointDetails),
          ),
        );
      }
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
        'Travel from $_currentCity to $_destinationCity for $_numberOfPeople people with $_luggage pieces of luggage from ${_startDate.toLocal()} to ${_endDate.toLocal()} within a budget of $_budget INR. Give different low impact transportation options to travel within all the city names aka checkpoints where the transport is changed along with its carbon footprints and price.';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define a smaller width for the text fields
    double textFieldWidth = screenWidth * 0.2; // 60% of screen width

    // Define the gray color
    Color grayColor = Color(0xFFD9D9D9); // Specific gray color

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                "https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: screenWidth * 0.3, // Adjust width to 80% of screen width
            height: screenHeight * 0.7, // Adjust height to 80% of screen height
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color:
                  Color(0xB7D9D9D9), // Semi-transparent white for the container
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              // Allows scrolling when content is larger than the container
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _currentCityController,
                      decoration: InputDecoration(
                        labelText: 'Current City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _destinationCityController,
                      decoration: InputDecoration(
                        labelText: 'Destination City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // This will ensure even spacing around the buttons
  children: <Widget>[
    Expanded( // Using Expanded to give equal space for both buttons
      child: ElevatedButton(
        onPressed: () => _selectStartDate(context),
        child: Text('Select Start Date'),
      ),
    ),
    SizedBox(width: 20), // Space between the two buttons
    Expanded( // Using Expanded to give equal space for both buttons
      child: ElevatedButton(
        onPressed: () => _selectEndDate(context),
        child: Text('Select End Date'),
      ),
    ),
  ],
),
SizedBox(height: 10), // Space between the buttons and the date display
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: <Widget>[
    Text('Start Date: ${_startDate.toLocal()}'.split(' ')[0]),
    Text('End Date: ${_endDate.toLocal()}'.split(' ')[0]),
  ],
),
SizedBox(height: 20), 
                  Container(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _numberOfPeopleController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of People',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _luggageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Luggage (number of items)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Budget (INR)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: grayColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> checkpointDetails;

  DetailsPage({required this.checkpointDetails});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final Set<Map<String, dynamic>> selectedDetails = {};

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedDetails = {};

    // Group details by checkpoint
    for (var detail in widget.checkpointDetails) {
      final cityName = detail['checkpoint'];
      if (!groupedDetails.containsKey(cityName)) {
        groupedDetails[cityName] = [];
      }
      groupedDetails[cityName]!.add(detail);
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                // Left half of the screen with the image
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1610437759118-6c9a45aab39b?q=80&w=1854&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Right half of the screen with the list
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white70,
                    child: ListView(
                      children: groupedDetails.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            ...entry.value.map((detail) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedDetails.contains(detail)) {
                                      selectedDetails.remove(detail);
                                    } else {
                                      selectedDetails.add(detail);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selectedDetails.contains(detail) ? Colors.blue : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transport Options: ${detail['transport_options']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedDetails.contains(detail) ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'Carbon Footprint: ${detail['carbon_footprint']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedDetails.contains(detail) ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'Estimated Price: ${detail['estimated_price']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedDetails.contains(detail) ? Colors.white : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You saved \$2000 and the environment!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Next button press
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}