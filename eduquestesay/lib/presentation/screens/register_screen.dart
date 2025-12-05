import 'package:eduquestesay/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart' as my_providers;
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
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_providers.AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),

                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blue.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.school,
                              size: 40,
                              color: Colors.blue.shade700,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join EduQuest to start your learning journey',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

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

                        _buildPasswordField(
                          controller: _password,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
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
                          keyboardType: TextInputType.phone,
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

                        // Role Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Role',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              prefixIcon: Icon(Icons.people_outline, color: Colors.grey),
                            ),
                            value: _selectedRole,
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
                            items: const [
                              DropdownMenuItem(
                                value: 'Student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'Teacher',
                                child: Text('Teacher'),
                              ),
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

                        // Create Account Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                
                                UserModel? success = await authProvider.registerWithEmail(
                                  _email.text,
                                  _password.text,
                                  _fullName.text,
                                  _phoneNumber.text, 
                                  _selectedRole,
                                );
                                
                                if (!mounted) return;
                                
                                setState(() => _isLoading = false);

                                if (success != null) {
                                  Navigator.pushReplacementNamed(context, AppRouter.login);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.blue.withOpacity(0.3),
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
                        const SizedBox(height: 32),

                        // Login Link
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => Navigator.pushReplacementNamed(
                              context, 
                              AppRouter.login
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade500,
            ),
            onPressed: () => setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            }),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }
}