import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _hasEightChars = false;
  bool _hasSpecialChar = false;
  bool _hasNumber = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _passwordsMatch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Image.asset(AppAssets.deltalogo),
          ),
          const Text('Sign Up'),
        ],
      )),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding:const EdgeInsets.all(16.0),
          width: 300,
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Row(children: [
                  Expanded(
                      child: TextFormField(
                    decoration:const InputDecoration(labelText: 'First Name'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _firstName = value;
                      });
                    },
                  )),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: TextFormField(
                    decoration:const InputDecoration(labelText: 'Last Name'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _lastName = value;
                      });
                    },
                  )),
                ]),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration:const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // add email validatio logic here
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    /*
                        if (!EmailValidator.validate(value)) {
                          return 'Please Enter a valid email';
                        }
                        */
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration:const InputDecoration(
                    labelText: 'Username',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _username = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter A valid phone number';
                    } else if (value.length < 10) {
                      return 'The Phone number you entered is not complete';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_hasEightChars ||
                        !_hasSpecialChar ||
                        !_hasNumber ||
                        !_hasUpperCase ||
                        _hasLowerCase) {
                      return 'Password does not meet requirements';
                    }
                    return null;
                  },
                  onChanged: _validatePassword,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _password) {
                      return 'Password do not match';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _confirmPassword = value;
                      _passwordsMatch = value == _password;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding:const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequirementRow(
                          _hasEightChars, 'At least 8 characters'),
                      _buildRequirementRow(
                          _hasSpecialChar, 'Contains Special character'),
                      _buildRequirementRow(_hasNumber, 'Contains number'),
                      _buildRequirementRow(
                          _hasUpperCase, 'Contains uppercase letter'),
                      _buildRequirementRow(
                          _hasLowerCase, 'Contains lowercase letter'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {}, child: const Text('Sign Up'))),
                    Expanded(
                        child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:const Text(
                        'Close',
                        style: TextStyle(color: Colors.red),
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    // Handle form submission here
    // This is where tou would typically send the data to your backend
    var formData = {
      'Firstname': _firstName,
      'LastName': _lastName,
      'UserName': _username,
      'Email': _email,
      'PhoneNumber': _phoneNumber,
      'Password': _password,
      'ConfirmPassword': _confirmPassword,
    };
  }

  void _validatePassword(String value) {
    setState(() {
      _hasEightChars = value.length >= 8;
      _hasSpecialChar = RegExp(r'[!@~$%^&*(),.?":{}|<>]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
      _password = value;
    });
  }

  Widget _buildRequirementRow(bool isMet, String requirement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
        const  SizedBox(
            width: 10,
          ),
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
