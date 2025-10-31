import 'package:flutter/material.dart';
import '../../../../data/models/device.dart';
import '../../../../data/repositories/device_repository.dart';

class AddNoteDialog extends StatefulWidget {
  final Device device;

  const AddNoteDialog({
    super.key,
    required this.device,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final DeviceRepository _repository = DeviceRepository();

  String _selectedPriority = 'none';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ?? ???? ?? ?????? ???? ??? Note ???? ????? ????
    if (widget.device.hasNote) {
      _selectedPriority = widget.device.notePriority ?? 'none';
      _messageController.text = widget.device.noteMessage ?? '';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _repository.sendCommand(
        widget.device.deviceId,
        'note',
        parameters: {
          'priority': _selectedPriority,
          'message': _messageController.text.trim(),
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note saved successfully'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save note'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'lowbalance':
        return const Color(0xFFF59E0B); // Amber/Warning
      case 'highbalance':
        return const Color(0xFF10B981); // Green/Success
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'lowbalance':
        return Icons.warning_rounded;
      case 'highbalance':
        return Icons.check_circle_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'lowbalance':
        return 'Low Balance ??';
      case 'highbalance':
        return 'High Balance ?';
      default:
        return 'No Priority';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.note_add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.device.hasNote ? 'Edit Note' : 'Add Note',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          widget.device.model,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Priority Selection
              Text(
                'Priority',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _PriorityOption(
                      priority: 'lowbalance',
                      label: 'Low Balance',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFF59E0B),
                      isSelected: _selectedPriority == 'lowbalance',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedPriority = 'lowbalance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PriorityOption(
                      priority: 'highbalance',
                      label: 'High Balance',
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      isSelected: _selectedPriority == 'highbalance',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedPriority = 'highbalance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PriorityOption(
                      priority: 'none',
                      label: 'None',
                      icon: Icons.note_rounded,
                      color: const Color(0xFF6B7280),
                      isSelected: _selectedPriority == 'none',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedPriority = 'none'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Message Input
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Enter note message...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF252B3D) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              'Save Note',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Priority Option Widget
class _PriorityOption extends StatelessWidget {
  final String priority;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? const Color(0xFF252B3D) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : (isDark ? Colors.white54 : const Color(0xFF64748B)),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
