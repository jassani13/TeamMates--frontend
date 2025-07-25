import 'package:flutter/material.dart';
import 'package:base_code/package/screen_packages.dart';

class AddStaffForm extends StatefulWidget {
  final int teamId;
  final Function onStaffAdded;
  const AddStaffForm({required this.teamId, required this.onStaffAdded, Key? key}) : super(key: key);

  @override
  State<AddStaffForm> createState() => _AddStaffFormState();
}

class _AddStaffFormState extends State<AddStaffForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String? staffRole;
  final List<String> staffRoles = ['Coach', 'Manager', 'Assistant Coach'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Staff'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
              onSaved: (val) => name = val!,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Role'),
              items: staffRoles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
              onChanged: (val) => staffRole = val,
              validator: (val) => val == null ? 'Select role' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              // Call API to add staff
              await dio.post('/api/team/add-member', data: {
                'name': name,
                'team_id': widget.teamId,
                'role_type': 'staff',
                'staff_role': staffRole,
              });
              widget.onStaffAdded();
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
} 