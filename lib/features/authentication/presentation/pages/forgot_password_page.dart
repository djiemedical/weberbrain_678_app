// lib/features/authentication/presentation/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2225),
      appBar: AppBar(
        title: const Text('Forgot Password',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2225),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message ?? 'Password reset email sent!')),
            );
            context.router.maybePop();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: _emailFocusNode.hasFocus
                          ? const Color(0xFF99D3DF)
                          : Colors.grey),
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF999DA2)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF99D3DF)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: TextStyle(
                  color: _emailFocusNode.hasFocus
                      ? Colors.white
                      : const Color(0xFF99D3DF),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(ForgotPasswordRequested(
                          email: _emailController.text,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2691A5),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Reset Password',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
