import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/providers/api_providers.dart';
import 'package:trivy/screens/learning/detail_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String textFromTextField = "Hasil input akan di sini";
  int counter = 0;
  bool isToggled = false;
  String? nullableString;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  Color getContainerColor() {
    if (isToggled) {
      return Colors.blue.shade100;
    } else {
      return Colors.grey.shade200;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Halaman Belajar Flutter")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: getContainerColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Widget Dasar & State',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text('Counter saat ini: $counter'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Toggle Status: ${isToggled ? "ON" : "OFF"}'),
                    Switch(
                      value: isToggled,
                      onChanged: (value) {
                        setState(() {
                          isToggled = value;
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Tambah Counter'),
                ),
              ],
            ),
          ),
          _buildSectionTitle('2. Form, Input & Validasi'),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Masukkan Nama',
                    hintText: 'Contoh: Budi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        textFromTextField = _textController.text;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data berhasil disimpan!'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 10),
                Text('Teks yang diinput: $textFromTextField'),
              ],
            ),
          ),
          const Divider(height: 40),
          _buildSectionTitle('3. Layout Lanjutan (Stack & GridView)'),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/destination_bali.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.5),
                child: const Text(
                  'Ini adalah Stack: Teks di atas Gambar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Anda menekan item grid ke-${index + 1}'),
                    ),
                  );
                },
                child: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Item ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 40),
          _buildSectionTitle('4. Navigasi Antar Halaman'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailScreen(data: 'Ini data dari LearningScreen'),
                ),
              );
            },
            child: const Text('Pergi ke Halaman Detail'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: 'Ini data via Named Route',
              );
            },
            child: const Text('Pergi ke Detail (via Named Route)'),
          ),
          const Divider(height: 40),
          _buildSectionTitle('5. Data dari Internet (REST API)'),
          Consumer(
            builder: (context, ref, child) {
              final apiData = ref.watch(postsProvider);
              return apiData.when(
                data: (posts) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(post.id.toString()),
                          ),
                          title: Text(post.title),
                          subtitle: Text(post.body, maxLines: 2),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
