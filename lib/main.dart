import 'package:controlese/controllers/finance_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// Importações das views
import 'view/login_screen.dart';
import 'view/create_account.dart';
import 'view/finance_page.dart';
import 'view/welcome_page.dart';

// Serviços
import 'view/auth_service.dart';
import 'services/database_service.dart';

// Configurações do Firebase
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Registra os serviços no GetX
  Get.put(AuthService());
  Get.put(DatabaseService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle \$E',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: const CardThemeData(
          // ← Use CardThemeData
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ), // ← Use BorderRadius.all
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),

      // Determina a tela inicial baseada no estado de autenticação
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mostra loading enquanto verifica o estado de auth
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando...'),
                  ],
                ),
              ),
            );
          }

          // Se há erro na autenticação
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        Get.offAll(() => const MyApp());
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Se usuário está autenticado, vai para a tela de finanças
          if (snapshot.hasData && snapshot.data != null) {
            // Inicializa o FinanceController aqui para usuários autenticados
            Get.put(FinanceController(), permanent: true);
            return const FinanceHomePage();
          }

          // Se não está autenticado, vai para login
          return const LoginScreen();
        },
      ),

      // Rotas nomeadas
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/create', page: () => const CreateAccountPage()),
        GetPage(
          name: '/finance',
          page: () => const FinanceHomePage(),
          binding: BindingsBuilder(() {
            Get.put(FinanceController());
          }),
        ),
        GetPage(name: '/welcome', page: () => const WelcomePage()),
      ],

      // Rota inicial (será sobrescrita pelo StreamBuilder)
      initialRoute: '/login',

      // Rota desconhecida
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64),
                SizedBox(height: 16),
                Text('Página não encontrada'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Binding personalizado para gerenciar dependências
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(DatabaseService(), permanent: true);
  }
}

// Controller de aplicação global
class AppController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();

    // Escuta mudanças no estado de autenticação
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      currentUser.value = user;

      if (user != null) {
        // Usuário logou - inicializar dados se necessário
        print('Usuário logado: ${user.email}');
      } else {
        // Usuário deslogou - limpar dados
        print('Usuário deslogado');
        // Remove o FinanceController quando usuário desloga
        if (Get.isRegistered<FinanceController>()) {
          Get.delete<FinanceController>();
        }
      }
    });
  }

  void showLoading() {
    isLoading.value = true;
  }

  void hideLoading() {
    isLoading.value = false;
  }
}
