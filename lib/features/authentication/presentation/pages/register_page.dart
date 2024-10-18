// lib/features/authentication/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../config/routes/app_router.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _nameFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2225),
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2225),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            context.router.push(const LoginRoute());
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Name',
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
                    color: _nameFocusNode.hasFocus
                        ? Colors.white
                        : const Color(0xFF99D3DF),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Email',
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
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF999DA2)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF99D3DF)),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    suffixIcon:
                        const Icon(Icons.visibility_off, color: Colors.grey),
                  ),
                  style: TextStyle(
                    color: _passwordFocusNode.hasFocus
                        ? Colors.white
                        : const Color(0xFF99D3DF),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(RegisterRequested(
                            email: _emailController.text,
                            password: _passwordController.text,
                            name: _nameController.text,
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2691A5),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Register',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.router.push(const LoginRoute()),
                  child: const Text('Already have an account? Login',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
