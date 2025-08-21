import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();

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
      return 'O campo de usuário não pode estar vazio';
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

  // Método para registrar o usuário
  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: senhaController.text,
          );

      // Atualizando o nome de usuário
      await userCredential.user!.updateDisplayName(usuarioController.text);

      // Mensagem de sucesso e redirecionamento para tela de login
      Get.snackbar('Sucesso', 'Usuário cadastrado com sucesso!');
      Get.offAllNamed('/login'); // Redireciona para a tela de login
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar('Erro', 'Este e-mail já está em uso.');
      } else if (e.code == 'invalid-email') {
        Get.snackbar('Erro', 'O e-mail fornecido não é válido.');
      } else {
        Get.snackbar('Erro', e.message ?? 'Erro desconhecido.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 300),
                // Campo para o nome de usuário
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: usuarioController,
                    validator: isAValidUserName,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      label: Text('Usuário'),
                      hintText: 'Digite seu usuario',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Campo para o email
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    validator: isAValidEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      label: Text('Email'),
                      hintText: 'Digite seu email',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Campo para a senha
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: senhaController,
                    validator: isAValidPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.password),
                      label: Text('Senha'),
                      hintText: 'Digite sua senha',
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Botão para cadastrar o usuário
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      registerUser(); // Chama o método para registrar o usuário
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(Size(200, 50)),
                  ),
                  child: Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
