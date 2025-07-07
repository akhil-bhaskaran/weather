import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/presentaion/auth_pages/bloc/auth_bloc.dart';
import 'package:weather_app/presentaion/auth_pages/sign_in_page.dart';
import 'package:weather_app/presentaion/splash_screen/splash_screen.dart';

import 'package:weather_app/theme/app_colors.dart';

import 'package:weather_app/theme/theme.dart';
import 'package:weather_app/widgets/my_textfield.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight / 3,
              color: Colors.black,
              child: Image.asset(
                "assets/images/raint.png",
                fit: BoxFit.fitHeight,
              ),
            ),
            Container(
              height: screenHeight * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),

              //Bloc
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is ToggleToLoginState) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) => const SignInPage(),
                        transitionsBuilder:
                            (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                      ),
                    );
                  } else if (state is AuthFailure) {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            backgroundColor: AppColors.greybg,
                            title: const Text(
                              "Notice",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            content: Text(
                              state.message,
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                    );
                  } else if (state is AuthSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                    );
                  }
                },
                builder: (context, state) {
                  return state.runtimeType == AuthLoading
                      ? Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'Create \nAccount',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: 20),
                            MyTextfield(
                              hintText: 'Email',
                              controller: emailController,
                            ),
                            SizedBox(height: 20),
                            MyTextfield(
                              hintText: "Password",
                              controller: passwordController,
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sign Up",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 26,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    BlocProvider.of<AuthBloc>(context).add(
                                      AuthSignUpRequested(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.arrow_forward),
                                  style: ElevatedButton.styleFrom(
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(16),
                                    iconColor: Colors.white,
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<AuthBloc>(
                                      context,
                                    ).add(AuthToggleToLogin());
                                  },
                                  child: Text(
                                    "Sign In",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
