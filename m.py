import os
import re

# ⚙️ تنظیمات - اینجا رو تغییر بده
SCALE_FACTOR = 0.8  # 0.8 = 20% کوچیک‌تر | 0.5 = 50% کوچیک‌تر | 1.2 = 20% بزرگ‌تر

def resize_file(file_path):
    """تغییر سایز مقادیر در یک فایل"""
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # محافظت از Color ها
    color_pattern = r'Color\((0x[0-9A-Fa-f]+)\)'
    colors = re.findall(color_pattern, content)
    color_placeholders = {}
    
    for i, color in enumerate(colors):
        placeholder = f'COLOR_PROTECTED_{i}_PLACEHOLDER'
        color_placeholders[placeholder] = color
        content = content.replace(f'Color({color})', placeholder, 1)
    
    # پترن‌های مختلف (هم با responsive و هم بدون)
    patterns = [
        # با responsive units (.w, .h, .sp, .r)
        r'width:\s*(\d+\.?\d*)\.(w)',
        r'height:\s*(\d+\.?\d*)\.(h)',
        r'fontSize:\s*(\d+\.?\d*)\.(sp)',
        r'size:\s*(\d+\.?\d*)\.(r)',
        r'EdgeInsets\.all\((\d+\.?\d*)\.(r)\)',
        r'horizontal:\s*(\d+\.?\d*)\.(w)',
        r'vertical:\s*(\d+\.?\d*)\.(h)',
        r'left:\s*(\d+\.?\d*)\.(w)',
        r'right:\s*(\d+\.?\d*)\.(w)',
        r'top:\s*(\d+\.?\d*)\.(h)',
        r'bottom:\s*(\d+\.?\d*)\.(h)',
        r'BorderRadius\.circular\((\d+\.?\d*)\.(r)\)',
        r'Radius\.circular\((\d+\.?\d*)\.(r)\)',
        
        # بدون responsive units (معمولی)
        r'width:\s*(\d+\.?\d*)(,)',
        r'height:\s*(\d+\.?\d*)(,)',
        r'fontSize:\s*(\d+\.?\d*)(,|\))',
        r'size:\s*(\d+\.?\d*)(,|\))',
        r'EdgeInsets\.all\((\d+\.?\d*)(\))',
        r'horizontal:\s*(\d+\.?\d*)(,)',
        r'vertical:\s*(\d+\.?\d*)(,|\))',
        r'left:\s*(\d+\.?\d*)(,)',
        r'right:\s*(\d+\.?\d*)(,)',
        r'top:\s*(\d+\.?\d*)(,)',
        r'bottom:\s*(\d+\.?\d*)(,)',
        r'BorderRadius\.circular\((\d+\.?\d*)(\))',
        r'Radius\.circular\((\d+\.?\d*)(\))',
    ]
    
    # اعمال تغییرات
    for pattern in patterns:
        def replace_match(match):
            value = float(match.group(1))
            new_value = round(value * SCALE_FACTOR, 2)
            
            # حذف .0 برای اعداد صحیح
            if new_value == int(new_value):
                new_value = int(new_value)
            
            # ساخت متن جدید
            prefix = match.group(0).split(match.group(1))[0]
            suffix = match.group(2)
            return f"{prefix}{new_value}{suffix}"
        
        content = re.sub(pattern, replace_match, content)
    
    # برگرداندن Color ها
    for placeholder, color in color_placeholders.items():
        content = content.replace(placeholder, f'Color({color})')
    
    # ذخیره اگه تغییر کرده
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    """تغییر سایز در همه فایل‌های dart"""
    
    lib_path = 'lib'
    
    if not os.path.exists(lib_path):
        print("❌ پوشه lib پیدا نشد!")
        return
    
    print(f"🔧 ضریب تغییر سایز: {SCALE_FACTOR}")
    if SCALE_FACTOR < 1:
        print(f"   (مقادیر {int((1-SCALE_FACTOR)*100)}% کوچیک‌تر می‌شن)\n")
    else:
        print(f"   (مقادیر {int((SCALE_FACTOR-1)*100)}% بزرگ‌تر می‌شن)\n")
    
    confirm = input("آماده‌ای؟ (y/n): ")
    if confirm.lower() != 'y':
        print("لغو شد!")
        return
    
    updated_files = []
    total_files = 0
    
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith('.dart'):
                total_files += 1
                file_path = os.path.join(root, file)
                
                try:
                    if resize_file(file_path):
                        updated_files.append(file_path)
                        print(f"✅ {file_path}")
                except Exception as e:
                    print(f"❌ خطا در {file_path}: {e}")
    
    print("\n" + "="*50)
    print(f"🎉 تمام شد!")
    print(f"📊 {total_files} فایل بررسی شد")
    print(f"✅ {len(updated_files)} فایل تغییر کرد")
    print("="*50)
    
    if updated_files:
        print(f"\n📝 مثال تغییرات:")
        new_width = round(100 * SCALE_FACTOR, 2)
        new_font = round(16 * SCALE_FACTOR, 2)
        new_padding = round(20 * SCALE_FACTOR, 2)
        if new_width == int(new_width): new_width = int(new_width)
        if new_font == int(new_font): new_font = int(new_font)
        if new_padding == int(new_padding): new_padding = int(new_padding)
        
        print(f"   width: 100  →  width: {new_width}")
        print(f"   fontSize: 16  →  fontSize: {new_font}")
        print(f"   padding: 20  →  padding: {new_padding}")

if __name__ == '__main__':
    main()