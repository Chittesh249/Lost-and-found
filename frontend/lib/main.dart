import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'pages/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // ✅ Initialize Supabase here using env vars
  await Supabase.initialize(
    url: dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!,
    anonKey: dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!,
  );

  runApp(const AmritaRetrieverApp());
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AmritaRetrieverApp extends StatefulWidget {
  const AmritaRetrieverApp({super.key});

  @override
  State<AmritaRetrieverApp> createState() => _AmritaRetrieverAppState();
}

class _AmritaRetrieverAppState extends State<AmritaRetrieverApp> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    supabase
        .channel('public:Lost_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'Lost_items',
          callback: (payload) {
            final newItem = payload.newRecord;
            final message = newItem['location_lost'] != null 
                ? "New item lost at ${newItem['location_lost']}"
                : "New item lost!";
            
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'VIEW',
                  onPressed: () {
                    // Navigate to details if needed, 
                    // for now just close
                  },
                ),
              ),
            );
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Amrita Retriever',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
