// lib/features/authentication/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  void _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  void _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2225),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/weber_brain_logo.svg',
                height: 50,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hintText: 'username@email.com',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.white),
                    checkColor: const Color(0xFF1F2225),
                  ),
                  const Text('Remember me',
                      style: TextStyle(color: Colors.white)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.router.push(const ForgotPasswordRoute()),
                    child: const Text('Forgot password?',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: () {
                    _saveRememberMe();
                    // Directly navigate to HomePage without authentication
                    context.router.replace(const HomeRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2691A5),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Login',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.router.push(const RegisterRoute()),
                child: const Text('Create an account',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
