import 'package:eduquestesay/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart' as my_providers; // <-- Add alias
import '../../../core/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _phoneNumber = TextEditingController();
  
  String _selectedRole = 'Student';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Use the alias here
    final authProvider = Provider.of<my_providers.AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Us Today',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _fullName,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _password,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _phoneNumber,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.length < 8) {
                              return 'Phone number must be at least 8 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              prefixIcon: Icon(Icons.people_outline, color: Colors.grey),
                            ),
                            value: _selectedRole,
                            style: const TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                              DropdownMenuItem(value: 'Student', child: Text('Student')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value ?? 'Student';
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Role is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                // Use the alias here too
                                UserModel? success = await authProvider.registerWithEmail(
                                  _email.text,
                                  _password.text,
                                  _fullName.text,
                                  _phoneNumber.text, 
                                  _selectedRole,
                                );
                                
                                setState(() {
                                  _isLoading = false;
                                });

                                if (success != null && mounted) {
                                  Navigator.pushReplacementNamed(context, AppRouter.login);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => Navigator.pushReplacementNamed(
                              context, 
                              AppRouter.login
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.grey.shade600),
                                children: const [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
        ),
        validator: validator,
      ),
    );
  }
}