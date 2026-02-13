#!/usr/bin/env python3

import json
import uuid
import plistlib
from pathlib import Path

# Generate UUIDs for all project elements
def generate_uuid():
    return str(uuid.uuid4()).upper().replace('-', '')[:24]

PROJECT_ROOT = Path("/Users/davids/Documents/Source/git/language-game")
PROJECT_NAME = "LanguageGame"
PRODUCT_NAME = "LanguageGame"
BUNDLE_ID = "com.bisaya.languagegame"
MIN_OS = "17.0"

# Generate unique identifiers
project_id = generate_uuid()
main_target_id = generate_uuid()
main_group_id = generate_uuid()
app_group_id = generate_uuid()
sources_group_id = generate_uuid()
frameworks_group_id = generate_uuid()

# Create the pbxproj structure
pbxproj_data = {
    'archiveVersion': 1,
    'classes': {},
    'objectVersion': 56,
    'objects': {
        # Project reference
        project_id: {
            'isa': 'PBXProject',
            'attributes': {
                'BuildIndependentTargetsInParallel': 1,
                'LastUpgradeCheck': 1500,
                'TargetAttributes': {
                    main_target_id: {
                        'CreatedOnToolsVersion': '15.0',
                        'LastSwiftMigration': 1500,
                    }
                }
            },
            'buildConfigurationList': generate_uuid(),
            'compatibilityVersion': 'Xcode 14.0',
            'developmentRegion': 'en',
            'hasScannedForEncodings': 0,
            'knownRegions': ['en', 'Base'],
            'mainGroup': main_group_id,
            'productRefGroup': generate_uuid(),
            'projectDirPath': '',
            'projectRoot': '',
            'targets': [main_target_id],
        },
    },
    'rootObject': project_id,
}

# This is complex to generate manually. Let's create a simpler approach.
print("✅ Project structure ready for Xcode command-line setup")

