import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:stability_image_generation/stability_image_generation.dart';

class AiTextToImageGenerator extends StatefulWidget {
  const AiTextToImageGenerator({super.key});

  @override
  State<AiTextToImageGenerator> createState() => _AiTextToImageGeneratorState();
}

class _AiTextToImageGeneratorState extends State<AiTextToImageGenerator>
    with SingleTickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final StabilityAI _ai = StabilityAI();
  final String apiKey = 'sk-7WSA5nUb3a2eXbiGiRtMjlaJdfEruINfrZ6yaTqqIekjLlwm';
  final ImageAIStyle imageAIStyle = ImageAIStyle.digitalPainting;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isItems = false;
  Uint8List? _generatedImage;
  bool _hasError = false;
  String? _errorMessage;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  Future<void> _generate(String query) async {
    setState(() {
      _hasError = false; // Reset error before new generation
      _errorMessage = null;
    });
    try {
      Uint8List image = await _ai.generateImage(
        apiKey: apiKey,
        imageAIStyle: imageAIStyle,
        prompt: query,
      );
      setState(() {
        _generatedImage = image;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString(); // Store the error message
      });
    }
    _animationController.forward();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "AI Text to Image Generator",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 5.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _queryController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Enter your prompt',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isItems
                    ? FutureBuilder(
                  future: _generate(_queryController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    } else if (_hasError) {
                      return Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 50),
                            const SizedBox(height: 10),
                            Text(
                              'Error: $_errorMessage',
                              style:
                              const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Please check your API key or try again later.',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (_generatedImage != null) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(_generatedImage!),
                          ),
                        ),
                      );
                    } else {
                      return const Text(
                        'No image generated yet',
                        style: TextStyle(color: Colors.white),
                      );
                    }
                  },
                )
                    : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 300,
                        color: Colors.grey[700],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No image generated yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    String query = _queryController.text;
                    if (query.isNotEmpty) {
                      setState(() {
                        isItems = true;
                        _animationController.reset();
                      });
                      _focusNode.unfocus(); // Close the keyboard
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF6200EE),
                    elevation: 8,
                  ),
                  child: const Text(
                    "Generate Image",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
