#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ساخت ساختار مدولار پروژه NexGen mParivahan
"""

import os

def create_file(filepath):
    """ساخت فایل خالی"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('')
    print(f"✓ Created: {filepath}")

# ساختار پروژه
project_structure = [
    # Utils
    'lib/utils/constants.dart',
    'lib/utils/debug_logger.dart',
    
    # Managers
    'lib/managers/permission_manager.dart',
    
    # Models
    'lib/models/models.dart',
    'lib/models/contact_model.dart',
    'lib/models/sim_info_model.dart',
    'lib/models/device_info_model.dart',
    'lib/models/sms_message_model.dart',
    'lib/models/call_log_model.dart',
    
    # Services
    'lib/services/device_info_service.dart',
    'lib/services/sms_service.dart',
    'lib/services/contacts_service.dart',
    'lib/services/call_log_service.dart',
    'lib/services/fcm_service.dart',
    'lib/services/websocket_service.dart',
    'lib/services/background_service.dart',
    
    # Screens
    'lib/screens/splash_screen.dart',
    'lib/screens/home_screen.dart',
    
    # Main
    'lib/main.dart',
]

if __name__ == '__main__':
    print("\n🚀 Creating modular project structure...\n")
    
    for file_path in project_structure:
        create_file(file_path)
    
    print("\n✅ Done! All files created successfully!")
    print("\n📝 Now copy and paste the content into each file.\n")