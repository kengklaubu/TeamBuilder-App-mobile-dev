import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';
import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  // Load environment variables with better error handling
  var env = DotEnv(includePlatformEnvironment: true);
  
  try {
    // Try to load .env file from root directory
    env.load(['.env']);
    print('✅ Environment file loaded successfully');
  } catch (e) {
    print('⚠️  Could not load .env file: $e');
    print('Make sure you have a .env file in your project root');
    return;
  }

  // Check if required environment variables exist
  final pocketbaseUrl = env['POCKETBASE_URL'];
  final adminEmail = env['POCKETBASE_ADMIN_EMAIL'];
  final adminPassword = env['POCKETBASE_ADMIN_PASSWORD'];

  if (pocketbaseUrl == null || adminEmail == null || adminPassword == null) {
    print('❌ Missing required environment variables:');
    if (pocketbaseUrl == null) print('  - POCKETBASE_URL');
    if (adminEmail == null) print('  - POCKETBASE_ADMIN_EMAIL');
    if (adminPassword == null) print('  - POCKETBASE_ADMIN_PASSWORD');
    return;
  }

  final pb = PocketBase(pocketbaseUrl);
  final faker = Faker();
  final random = Random();

  try {
    await pb.collection('_superusers').authWithPassword(
      adminEmail,
      adminPassword,
    );
    print('✅ Connected as Admin');
  } catch (e) {
    print('❌ Failed to authenticate admin: $e');
    return;
  }

  print('🚀 Starting to generate 50 products...');

  for (int i = 0; i < 50; i++) {
    final name = faker.food.dish();
    final price = (random.nextDouble() * 500 + 50).toStringAsFixed(2);

    String imageUrl = 'https://via.placeholder.com/200';
    try {
      final res = await http.get(
        Uri.parse('https://foodish-api.com/api/'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        imageUrl = data['image'] ?? imageUrl;
      }
    } catch (e) {
      print('⚠️  Could not fetch image for $name: $e');
    }

    try {
      final record = await pb.collection('dssishop').create(body: {
        'name': name,
        'price': double.parse(price),
        'imageUrl': imageUrl,
      });
      print('✅ Created (${i + 1}/50): ${record.id} - $name (\$${price})');
    } catch (e) {
      print('❌ Error creating $name: $e');
    }

    // Small delay to avoid overwhelming the API
    await Future.delayed(Duration(milliseconds: 100));
  }

  print('🎉 Finished generating products.');
}