
#We update our carthage repo and build frameworks
carthage bootstrap --platform iOS --cache-builds

#Finnaly we need to add carthage frameworks to our Input and Output Embeding frameworks script

XCODE_INPUT_FILES="./Carthage//CarthageInput.xcfilelist"
XCODE_OUTPUT_FILES="./Carthage//CarthageOutput.xcfilelist"

#We clean the input and output files
echo "" > $XCODE_INPUT_FILES
echo "" > $XCODE_OUTPUT_FILES

#We search for all frameworks and copy it to the app
for framework in $(ls ./Carthage/Build/iOS | grep ".framework" | grep -v 'dSYM'); do

input="\$(SRCROOT)/Carthage/Build/iOS/$framework"
output="\$(BUILT_PRODUCTS_DIR)/\$(FRAMEWORKS_FOLDER_PATH)/$framework"

echo "$input" >> $XCODE_INPUT_FILES
echo "$output" >> $XCODE_OUTPUT_FILES

done
