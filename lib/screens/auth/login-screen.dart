import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:transito/models/app_colors.dart';
import 'package:transito/screens/auth/register-screen.dart';

import '../../providers/authentication_service.dart';
import '../navbar_screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _loginFormKey = GlobalKey<FormBuilderState>();
  final _emailFieldKey = GlobalKey<FormBuilderFieldState>();
  final _passwordFieldKey = GlobalKey<FormBuilderFieldState>();

  void onLoginBtnPress() async {
    setState(() {
      _isLoading = true;
    });
    _loginFormKey.currentState!.saveAndValidate();
    if (_loginFormKey.currentState!.isValid) {
      AuthenticationService()
          .loginUserWithEmail(
        _emailFieldKey.currentState!.value,
        _passwordFieldKey.currentState!.value,
      )
          .then(
        (err) {
          print(err);
          if (err == null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            setState(() {
              _isLoading = false;
            });
            switch (err) {
              case 'user-not-found':
                _emailFieldKey.currentState!.invalidate("An account with this email doesn't exist");
                break;
              case 'wrong-password':
                _passwordFieldKey.currentState!.invalidate("Incorrect password");
                break;
              case 'user-disabled':
                _emailFieldKey.currentState!.invalidate("This account has been disabled");
                break;
              default:
                _emailFieldKey.currentState!.invalidate("Oops, something went wrong on our end");
                _passwordFieldKey.currentState!.invalidate("Oops, something went wrong on our end");
                break;
            }
          }
        },
      );
    } else {
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _isLoading = false;
        });
        _loginFormKey.currentState!.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User?>(context);
    bool isLoggedIn = user != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Welcome!')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: SvgPicture.asset('assets/images/logo.svg'),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Simply login and never miss a bus again!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: AppColors.kindaGrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 55,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => debugPrint("Google!"),
                              icon: SvgPicture.asset('assets/images/google_logo.svg'),
                              label: const Text('Sign in with Google',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: const [
                                  Expanded(child: Divider(thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      'or',
                                      style: TextStyle(color: AppColors.kindaGrey),
                                    ),
                                  ),
                                  Expanded(child: Divider(thickness: 1)),
                                ],
                              ),
                            ),
                            FormBuilder(
                              key: _loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FormBuilderTextField(
                                    key: _emailFieldKey,
                                    name: 'email',
                                    scrollPadding: const EdgeInsets.symmetric(vertical: 50),
                                    keyboardType: TextInputType.emailAddress,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.email(),
                                    ]),
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    key: _passwordFieldKey,
                                    name: 'password',
                                    scrollPadding: const EdgeInsets.symmetric(vertical: 50),
                                    obscureText: !_isPasswordVisible,
                                    keyboardType: TextInputType.visiblePassword,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: FormBuilderValidators.compose(
                                        [FormBuilderValidators.required()]),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(_isPasswordVisible
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded),
                                        iconSize: 24,
                                        splashRadius: 1,
                                        color: Colors.white70,
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 21.0),
                                    child: OutlinedButton(
                                      onPressed: () => onLoginBtnPress(),
                                      child: AnimatedSwitcher(
                                        transitionBuilder: (child, animation) => ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                        duration: const Duration(milliseconds: 175),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              )
                                            : const Text('Login'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New Here?',
                            style: TextStyle(color: AppColors.kindaGrey),
                          ),
                          const SizedBox(width: 3),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text(
                              'Register!',
                              style: TextStyle(color: AppColors.veryPurple),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
