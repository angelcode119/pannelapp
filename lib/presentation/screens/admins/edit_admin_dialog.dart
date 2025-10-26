import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/admin.dart';
import '../../providers/admin_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAdminDialog extends StatefulWidget {
  final Admin admin;

  const EditAdminDialog({
    super.key,
    required this.admin,
  });

  @override
  State<EditAdminDialog> createState() => _EditAdminDialogState();
}

class _EditAdminDialogState extends State<EditAdminDialog> {
  late String _selectedRole;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.admin.role;
    _isActive = widget.admin.isActive;
  }

  Future<void> _updateAdmin() async {
    setState(() => _isLoading = true);

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.updateAdmin(
      widget.admin.username,
      role: _selectedRole != widget.admin.role ? _selectedRole : null,
      isActive: _isActive != widget.admin.isActive ? _isActive : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Admin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Username: ${widget.admin.username}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Name: ${widget.admin.fullName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Email: ${widget.admin.email}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.admin_panel_settings),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            items: const [
              DropdownMenuItem(
                value: 'super_admin',
                child: Text('Super Admin'),
              ),
              DropdownMenuItem(
                value: 'admin',
                child: Text('Admin'),
              ),
              DropdownMenuItem(
                value: 'viewer',
                child: Text('Viewer'),
              ),
            ],
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Status'),
            subtitle: Text(_isActive ? 'Active' : 'Inactive'),
            value: _isActive,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateAdmin,
          child: _isLoading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}