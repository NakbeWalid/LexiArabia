import 'package:flutter/material.dart';
import 'package:dualingocoran/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_provider.dart';
import '../main.dart';
import '../widgets/google_logo_icon.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        final userCredential = await authService.registerWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );

        // Charger l'utilisateur dans UserProvider
        if (userCredential?.user != null) {
          await userProvider.loadUser(userCredential!.user!.uid);
        }

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false, // Supprime tous les écrans précédents
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e.code);
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.errorGeneric;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userCredential = await authService.signInWithGoogle();

      // Charger l'utilisateur dans UserProvider
      if (userCredential?.user != null) {
        await userProvider.loadUser(userCredential!.user!.uid);
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false, // Supprime tous les écrans précédents
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e.code);
      });
      print('❌ Erreur Firebase Auth: ${e.code} - ${e.message}');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(
          context,
        )!.errorWithDetails(e.toString());
      });
      print('❌ Erreur inattendue: $e');
      print('Stack trace: $stackTrace');
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.authEmailInUse;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalidEmail;
      case 'weak-password':
        return AppLocalizations.of(context)!.authWeakPassword;
      case 'operation-not-allowed':
        return AppLocalizations.of(context)!.authOperationNotAllowed;
      case 'sign_in_canceled':
        return AppLocalizations.of(context)!.authSignInCanceled;
      case 'sign_in_failed':
        return AppLocalizations.of(context)!.authGoogleFailed;
      case 'network_error':
        return AppLocalizations.of(context)!.authNetworkError;
      case 'google_sign_in_error':
        return AppLocalizations.of(context)!.authGoogleError;
      case 'account-exists-with-different-credential':
        return AppLocalizations.of(
          context,
        )!.authAccountExistsDifferentCredential;
      case 'invalid-credential':
        return AppLocalizations.of(context)!.authInvalidCredential;
      case 'unknown_error':
        return AppLocalizations.of(context)!.authUnknownError;
      default:
        return AppLocalizations.of(context)!.errorWithDetails(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo et titre
                    Icon(
                      Icons.person_add_outlined,
                      size: 80,
                      color: Colors.white,
                    ).animate().scale(delay: 100.ms, duration: 600.ms),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.signupTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.signupWelcome,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 32),

                    // Message d'erreur
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(),
                    SizedBox(height: 16),

                    // Champ nom
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.nameLabel,
                        hintText: AppLocalizations.of(context)!.nameHint,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterName;
                        }
                        if (value.length < 2) {
                          return AppLocalizations.of(context)!.nameTooShort;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 400.ms),
                    SizedBox(height: 16),

                    // Champ email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailLabel,
                        hintText: AppLocalizations.of(context)!.emailHint,
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterEmail;
                        }
                        if (!value.contains('@')) {
                          return AppLocalizations.of(context)!.invalidEmail;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 500.ms),
                    SizedBox(height: 16),

                    // Champ mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.passwordLabel,
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.enterNewPassword;
                        }
                        if (value.length < 6) {
                          return AppLocalizations.of(context)!.passwordTooShort;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 600.ms),
                    SizedBox(height: 16),

                    // Champ confirmation mot de passe
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signUpWithEmail(),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.confirmPasswordLabel,
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.confirmPassword;
                        }
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(
                            context,
                          )!.passwordsDontMatch;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 700.ms),
                    SizedBox(height: 24),

                    // Bouton inscription
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUpWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.createMyAccount,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ).animate().slideY(delay: 800.ms),
                    SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                    SizedBox(height: 16),

                    // Bouton Google
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
                        icon: const GoogleLogoIcon(size: 22),
                        label: Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.continueWithGoogle,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey.shade800,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ).animate().slideY(delay: 1000.ms),
                    SizedBox(height: 24),

                    // Lien connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.alreadyHaveAccount,
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.signIn,
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade300,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
