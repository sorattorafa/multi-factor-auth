import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auth0_flutter/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

class UserWidget extends StatelessWidget {
  final UserProfile? user;

  const UserWidget({required this.user, final Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pictureUrl = user?.pictureUrl;
    // id, name, email, email verified, updated_at
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (pictureUrl != null)
        Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: CircleAvatar(
              radius: 56,
              child: ClipOval(child: Image.network(pictureUrl.toString())),
            )),
      Card(
          child: Column(children: [
        UserEntryWidget(propertyName: 'Id', propertyValue: user?.sub),
        UserEntryWidget(propertyName: 'Name', propertyValue: user?.name),
        UserEntryWidget(propertyName: 'Email', propertyValue: user?.email),
        UserEntryWidget(
            propertyName: 'Email Verified?',
            propertyValue: user?.isEmailVerified.toString()),
        UserEntryWidget(
            propertyName: 'Updated at',
            propertyValue: user?.updatedAt?.toIso8601String()),
      ]))
    ]);
  }
}

class UserEntryWidget extends StatelessWidget {
  final String propertyName;
  final String? propertyValue;

  const UserEntryWidget(
      {required this.propertyName, required this.propertyValue, final Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(propertyName), Text(propertyValue ?? '')],
        ));
  }
}

const double padding = 40.0;
const double margin = 16.0;

final Shader linearGradient = const LinearGradient(colors: <Color>[
  Color.fromRGBO(255, 79, 64, 100),
  Color.fromRGBO(255, 68, 221, 100)
], begin: Alignment.topLeft, end: Alignment.bottomRight)
    .createShader(const Rect.fromLTWH(0.0, 0.0, 500.0, 70.0));

class HeroWidget extends StatelessWidget {
  const HeroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Container(
              margin: const EdgeInsets.all(margin),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Flutter',
                        style: GoogleFonts.spaceGrotesk(
                          foreground: Paint()..shader = linearGradient,
                          fontSize: 80,
                          height: 0.8,
                          fontWeight: FontWeight.w800,
                        )),
                    Text('Sample App',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 80,
                          height: 0.8,
                          fontWeight: FontWeight.w600,
                        )),
                  ])))
    ]);
  }
}

class ExampleApp extends StatefulWidget {
  final Auth0? auth0;
  const ExampleApp({this.auth0, final Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  UserProfile? _user;

  late Auth0 auth0;
  late Auth0Web auth0Web;

  @override
  void initState() {
    super.initState();
    auth0 = widget.auth0 ??
        Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    auth0Web =
        Auth0Web(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);

    if (kIsWeb) {
      auth0Web.onLoad().then((final credentials) => setState(() {
            _user = credentials?.user;
          }));
    }
  }

  Future<void> login() async {
    try {
      if (kIsWeb) {
        return auth0Web.loginWithRedirect(redirectUrl: 'http://localhost:3000');
      }

      var credentials = await auth0
          .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
          // Use a Universal Link callback URL on iOS 17.4+ / macOS 14.4+
          // useHTTPS is ignored on Android
          .login(useHTTPS: true);

      setState(() {
        _user = credentials.user;
      });

      if (_user != null) {
        await _showUserDialog(_user!);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        await auth0Web.logout(returnToUrl: 'http://localhost:3000');
      } else {
        await auth0
            .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
            // Use a Universal Link logout URL on iOS 17.4+ / macOS 14.4+
            // useHTTPS is ignored on Android
            .logout(useHTTPS: true);
        setState(() {
          _user = null;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showUserDialog(UserProfile user) async {
   showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: AlertDialog(
            title: Text('Dados do Usuário'),
            content: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 4),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(user.pictureUrl.toString() ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Nome: ${user.name}'),
                    Text('Email: ${user.email}'),
                    Text('Telefone: ${user.phoneNumber}'),
                    Text('E-mail verificado: ${user.isEmailVerified}'),
                    Text('Telefone verificado: ${user.isPhoneNumberVerified}'),
                    Text('Gênero: ${user.gender}'),
                    Text('Data de nascimento: ${user.birthdate}'),
                    Text('Localização: ${user.zoneinfo}'),
                    Text('Idioma: ${user.locale}'),
                    Text('Endereço: ${user.address}'),
                    //Text('Reivindicações personalizadas: ${user.customClaims}'),
                        
                    // Adicione mais informações do usuário conforme necessário
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Prosseguir'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Adicione a navegação para a próxima tela aqui
                },
              ),
              TextButton(
                child: Text('Logout'),
                onPressed: () {
                  Navigator.of(context).pop();
                  logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(
          top: padding,
          bottom: padding,
          left: padding / 2,
          right: padding / 2,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Row(children: [
            _user != null
                ? Expanded(child: UserWidget(user: _user))
                : const Expanded(child: HeroWidget())
          ])),
          _user != null
              ? ElevatedButton(
                  onPressed: logout,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: const Text('Logout'),
                )
              : ElevatedButton(
                  onPressed: login,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: const Text('Login'),
                )
        ]),
      )),
    );
  }
}
