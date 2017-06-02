# GenStrings
ios Localizable.strings generator

add string extension

extension String {
    var localized: String {
        let string = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return string
    }
}
and use localized variable for localization
Example:
textfield.text = "Enter Text".localized

for Storyboard: use 
pod 'IBLocalizable'
and set localizedString in xib,storyboard


Add run script in project:

set -x
# Get base path to project
BASE_PATH="$PROJECT_DIR/$PROJECT_NAME"

#--------- START OF YOUR CONFIGURATION (change Path_To_.. to fit)

# Get path to GenStrings.swift
GENSTRINGS_PATH="Path_To_../GenStrings.swift"

# Get path to main localization file (usually english).
OUTPUT_PATH="$BASE_PATH/Base.lproj/Localizable.strings"

# Get path to root source folder
INPUT_PATH="$BASE_PATH"

#--------- END OF YOUR CONFIGURATION

# Add permission to generator for script execution
chmod 755 "$GENSTRINGS_PATH"

# Actually generate output. -- CUSTOMIZE -- parameters to your needs (see documentation).
# Will only re-generate script if something changed
"$GENSTRINGS_PATH" "$INPUT_PATH" "$OUTPUT_PATH"
