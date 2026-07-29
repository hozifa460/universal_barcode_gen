import re

files_to_clean = {
    'lib/data/services/scanner_service_impl.dart': [
        "dart:typed_data",
        "package:flutter/services.dart",
        "../../core/constants/content_type.dart",
        "../../core/errors/exceptions.dart",
    ],
    'lib/domain/usecases/batch_generate_usecase.dart': [
        "../../core/errors/failures.dart",
        "../../core/utils/service_locator.dart",
    ],
    'lib/presentation/providers/generator_provider.dart': [
        "../../core/errors/either.dart",
        "../../core/errors/failures.dart",
        "../../core/utils/service_locator.dart",
        "../../domain/entities/app_settings.dart",
        "app_providers.dart",
    ],
    'lib/presentation/providers/scanner_provider.dart': [
        "../../core/utils/service_locator.dart",
    ],
    'lib/presentation/screens/history/history_screen.dart': [
        "../../../core/utils/service_locator.dart",
    ],
    'lib/domain/services/scanner_service.dart': [
        "../entities/barcode_content.dart",
    ],
    'lib/data/repositories/history_repository_impl.dart': [
        "../../core/errors/failures.dart",
    ],
    'lib/data/services/generation_service_impl.dart': [
        "package:barcode/barcode.dart",
        "package:flutter/services.dart",
    ],
}

for filepath, imports_to_remove in files_to_clean.items():
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        for imp in imports_to_remove:
            pattern = r"import '" + re.escape(imp) + r"';\r?\n"
            content = re.sub(pattern, '', content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'cleaned: {filepath}')
    except Exception as e:
        print(f'error {filepath}: {e}')
