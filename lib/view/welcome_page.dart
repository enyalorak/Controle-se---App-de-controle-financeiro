import 'package:controlese/view/auth_service.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                "https://cdn.pixabay.com/photo/2017/09/21/14/56/saving-money-2772141_960_720.png",
                height: 200,
              ),
              Text(
                'CONTROLE-SE',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 50),

              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 8),
                      Text('Criar Conta'),
                    ],
                  ),
                  //,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Logar Conta'),
                    ],
                  ),
                ),
                //Text('Logar Conta'),
              ),

              SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().loginGoogle();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone do Google
                      SizedBox(width: 10),
                      Text(
                        'Logar com Google',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                  //Text('Logar com Google'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
