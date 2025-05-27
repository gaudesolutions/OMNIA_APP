import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/clinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_state.dart';

class ClinicFormPage extends StatefulWidget {
  final Clinic? clinic; // null for new clinic, non-null for edit

  const ClinicFormPage({Key? key, this.clinic}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ClinicFormPageState createState() => _ClinicFormPageState();
}

class _ClinicFormPageState extends State<ClinicFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  bool _isActive = true;
  bool _isSubmitting = false; // Added this line to track form submission state

  @override
  void initState() {
    super.initState();
    final clinic = widget.clinic;
    _nameController = TextEditingController(text: clinic?.name ?? '');
    _addressController = TextEditingController(text: clinic?.address ?? '');
    _cityController = TextEditingController(text: clinic?.city ?? '');
    _stateController = TextEditingController(text: clinic?.state ?? '');
    _postalCodeController = TextEditingController(text: clinic?.postalCode ?? '');
    _phoneController = TextEditingController(text: clinic?.phone ?? '');
    _emailController = TextEditingController(text: clinic?.email ?? '');
    _websiteController = TextEditingController(text: clinic?.website ?? '');
    _isActive = clinic?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final clinicData = Clinic(
      id: widget.clinic?.id ?? 0,
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalCodeController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      website: _websiteController.text,
      active: _isActive,
      staffCount: widget.clinic?.staffCount ?? 0,
    );

    final bloc = context.read<ClinicBloc>();
    
    // Show loading state
    setState(() {
      _isSubmitting = true;
    });
    
    // Track whether we've already handled a response to prevent multiple actions
    bool responseHandled = false;
    
    // Declare the subscription variable first
    late final StreamSubscription<ClinicState> subscription;
    
    // Then initialize it
    subscription = bloc.stream.listen((state) {
      
      
      // Only handle the response if we haven't already
      if (!responseHandled) {
        if (state.status == ClinicStatus.success) {
          responseHandled = true;
          subscription.cancel();
          // ignore: use_build_context_synchronously
          Navigator.pop(context, true);
        } else if (state.status == ClinicStatus.failure) {
          responseHandled = true;
          subscription.cancel();
          setState(() {
            _isSubmitting = false;
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to save clinic')),
          );
        }
      }
    });
    
    // Add debug print to verify event is being dispatched
    // print('Submitting clinic: ${widget.clinic == null ? "Create new" : "Update ID: ${widget.clinic!.id}"}');
    
    if (widget.clinic == null) {
      bloc.add(AddClinicEvent(clinic: clinicData));
    } else {
      bloc.add(UpdateClinicEvent(clinic: clinicData));
    }
    
    // Add a timeout in case the operation takes too long
    Future.delayed(const Duration(seconds: 10), () {
      if (!responseHandled) {
        responseHandled = true;
        subscription.cancel();
        if (_isSubmitting && mounted) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operation timed out. Please try again.')),
          );
        }
      }
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinic == null ? 'Add New Clinic' : 'Edit Clinic'),
        backgroundColor: const Color(0xFF00BFA5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinic Information Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clinic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Clinic Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter a clinic name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter an address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Please enter a city'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Please enter a state'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(
                          labelText: 'Postal Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter a postal code'
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Contact Information Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter a phone number'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty)
                                ? 'Please enter an email'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Status Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        activeColor: const Color(0xFF00BFA5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button with loading state
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Disable the button when submitting
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.clinic == null ? 'Add Clinic' : 'Update Clinic',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}