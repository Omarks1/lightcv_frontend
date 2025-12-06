import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatMessage {
  final String message;
  final bool isBot;
  final int questionType;
  final List<String> options;
  final List<String>? suggestions;
  final List<String>? dropdownOptions;
  final bool sectionComplete;
  final bool awaitingConfirmation;

  ChatMessage({
    required this.message,
    required this.isBot,
    this.questionType = 1,
    this.options = const [],
    this.suggestions,
    this.dropdownOptions,
    this.sectionComplete = false,
    this.awaitingConfirmation = false,
  });
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  String? _sessionId;
  String? _selectedDropdownValue;
  DateTime? _selectedDate;

  // Send message to backend
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(message: message, isBot: false));
    });

    // Clear input
    _messageController.clear();
    _selectedDropdownValue = null;
    _selectedDate = null;

    try {
      final response = await http.post(
        Uri.parse('https://lightcvbackend-production.up.railway.app/api/chat/send_message'),
        // Uri.parse('http://localhost:5000/api/chat/send_message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'session_id': _sessionId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _handleBotResponse(data);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Handle bot response and update UI
  void _handleBotResponse(Map<String, dynamic> data) {
    setState(() {
      _messages.add(ChatMessage(
        message: data['message'] ?? '',
        isBot: true,
        questionType: data['question_type'] ?? 1,
        options: List<String>.from(data['options'] ?? []),
        suggestions: data['suggestions'] != null 
            ? List<String>.from(data['suggestions']) 
            : null,
        dropdownOptions: data['dropdown_options'] != null 
            ? List<String>.from(data['dropdown_options']) 
            : null,
        sectionComplete: data['section_complete'] ?? false,
        awaitingConfirmation: data['awaiting_confirmation'] ?? false,
      ));
    });
  }

  // Show month/year date picker
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _messageController.text = "${picked.month}/${picked.year}";
      });
    }
  }

  // Build option buttons (for question types 3 & 4)
  Widget _buildOptionButtons(List<String> options, bool isMultiple) {
    List<String> selectedOptions = [];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        bool isSelected = _messageController.text.contains(option);
        
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                setLocalState(() {
                  String currentText = _messageController.text;
                  
                  if (selected) {
                    // Add option to message
                    if (currentText.isEmpty) {
                      _messageController.text = option;
                    } else {
                      _messageController.text = currentText + ', ' + option;
                    }
                  } else {
                    // Remove option from message
                    List<String> parts = currentText.split(', ');
                    parts.remove(option);
                    _messageController.text = parts.join(', ');
                  }
                });
                
                // Update main widget state
                setState(() {});
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[200],
              checkmarkColor: Colors.blue[800],
            );
          },
        );
      }).toList(),
    );
  }

  // Build suggestion buttons
  Widget _buildSuggestionButtons(List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          onPressed: () {
            String currentText = _messageController.text;
            if (currentText.isEmpty) {
              _messageController.text = suggestion;
            } else {
              _messageController.text = currentText + ', ' + suggestion;
            }
            setState(() {});
          },
          backgroundColor: Colors.green[100],
        );
      }).toList(),
    );
  }

  // Build input area based on question type
  Widget _buildInputArea() {
    if (_messages.isEmpty) return SizedBox();
    
    final lastMessage = _messages.last;
    if (!lastMessage.isBot) return SizedBox();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dropdown for question type 4 (cities/universities)
          if (lastMessage.questionType == 4 && lastMessage.options.isNotEmpty)
            _buildCityUniversityDropdown(lastMessage.options),
          
          // Interactive option buttons for question types 2 & 3 (add to text)
          if ((lastMessage.questionType == 2 || lastMessage.questionType == 3) && 
              lastMessage.options.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اختر من الخيارات (يمكن الإضافة للنص):', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _buildOptionButtons(lastMessage.options, lastMessage.questionType == 3),
                SizedBox(height: 16),
              ],
            ),
          
          // Suggestion buttons for skills/languages
          if (lastMessage.suggestions != null && lastMessage.suggestions!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اقتراحات:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _buildSuggestionButtons(lastMessage.suggestions!),
                SizedBox(height: 16),
              ],
            ),
          
          // Text input with date picker button for question type 5
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك هنا...',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              // Date picker button for question type 5
              if (lastMessage.questionType == 5)
                IconButton(
                  icon: Icon(Icons.date_range, color: Colors.blue),
                  onPressed: _showDatePicker,
                  tooltip: 'اختر التاريخ',
                ),
              
              // Send button
              IconButton(
                icon: Icon(Icons.send, color: Colors.blue),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build city/university dropdown for question type 4
  Widget _buildCityUniversityDropdown(List<String> options) {
    // Check if it's city or university based on options content
    bool isCity = options.contains("مدينة");
    bool isUniversity = options.contains("جامعة");
    
    if (!isCity && !isUniversity) {
      return SizedBox(); // Not a special dropdown
    }
    
    // Load appropriate data
    List<String> dropdownData = [];
    if (isCity) {
      dropdownData = [
        "الرياض", "جدة", "مكة المكرمة", "المدينة المنورة", "الدمام",
        "الخبر", "الظهران", "تبوك", "بريدة", "خميس مشيط", "حائل",
        "الجبيل", "الطائف", "ينبع", "الأحساء", "القطيف", "عرعر"
      ];
    } else if (isUniversity) {
      dropdownData = [
        "جامعة الملك سعود", "جامعة الملك عبدالعزيز", "جامعة الإمام محمد بن سعود الإسلامية",
        "جامعة الملك فهد للبترول والمعادن", "جامعة الملك فيصل", "جامعة أم القرى",
        "الجامعة الإسلامية بالمدينة المنورة", "جامعة الملك خالد", "جامعة القصيم",
        "جامعة طيبة", "جامعة تبوك", "جامعة حائل", "جامعة الجوف"
      ];
    }
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedDropdownValue,
        hint: Text(isCity ? 'اختر المدينة' : 'اختر الجامعة'),
        isExpanded: true,
        underline: SizedBox(),
        items: dropdownData.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, textDirection: TextDirection.rtl),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDropdownValue = newValue;
            _messageController.text = newValue ?? '';
          });
        },
      ),
    );
  }

  // Build message bubble with options displayed above input
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Message bubble
          Row(
            mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (message.isBot) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
                ),
                SizedBox(width: 8),
              ],
              
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isBot ? Colors.grey[200] : Colors.blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.message,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: message.isBot ? Colors.black : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              if (!message.isBot) ...[
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),
          
          // Show options for bot messages (this was missing!)
          if (message.isBot && message.options.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.options.map((option) {
                return ActionChip(
                  label: Text(option),
                  onPressed: () {
                    _messageController.text = option;
                    setState(() {});
                  },
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مساعد السيرة الذاتية'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  // Start conversation
  Future<void> _startConversation() async {
    try {
      final response = await http.post(
        Uri.parse('https://lightcvbackend-production.up.railway.app/api/chat/start_conversation'),
        // Uri.parse('http://localhost:5000/api/chat/start_conversation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _sessionId = data['session_id'];
        _handleBotResponse(data);
      }
    } catch (e) {
      print('Error starting conversation: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tahoma', // Supports Arabic
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}