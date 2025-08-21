import 'package:controlese/view/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:controlese/models/user_app.dart';
import 'package:controlese/view/welcome_page.dart';

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      print(userCredential.user?.uid); //pra acessar a uid do firebase
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  String? isAValidEmail(value) {
    if (value == null || value.isEmpty) {
      return 'O campo de e-mail não pode estar vazio';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Insira um e-mail válido';
    }
    return null;
  }

  String? isAValidUserName(value) {
    if (value.isEmpty) {
      return 'O campo de e-mail não pode estar vazio';
    }
    return null;
  }

  String? isAValidPassword(value) {
    if (value == null || value.isEmpty) {
      return 'A senha não pode estar vazia';
    }

    if (value.length < 6) {
      return 'A senha deve conter pelo menos 6 caracteres';
    }

    String pattern = r'^(?=.*[0-9]).+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'A senha deve conter pelo menos 1 caractere numérico.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 150),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  width: 300,
                  child: TextFormField(
                    controller: emailController,
                    validator: isAValidEmail,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      label: Text('Email'),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  width: 300,
                  child: TextFormField(
                    controller: usernameController,
                    validator: isAValidUserName,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      label: Text('Nome de usuário'),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  width: 300,
                  child: TextFormField(
                    controller: passwordController,
                    validator: isAValidPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.password),
                      label: Text('Senha'),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await createUserWithEmailAndPassword();

                    /*if (_formKey.currentState?.validate() == true) {
                      UserApp newUser = UserApp(
                        email: emailController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                      );

                      AuthService authService = AuthService();
                      String? message = await authService.createUser(
                        user: newUser,
                      );
                      if (message == null) {
                        Get.off(WelcomePage());
                        Get.snackbar(
                          'SUCESSO!',
                          'O usuário foi criado com sucesso.',
                        );
                      } else {
                        Get.snackbar(
                          'ERRO!',
                          message,
                          backgroundColor: Colors.red[50],
                          colorText: Colors.red,
                        );
                      }
                    }*/
                  },
                  child: Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//if (_formKey.currentState?.validate() == true) {}