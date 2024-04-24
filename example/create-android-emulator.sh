cd $ANDROID_HOME/tools/bin
sdk="system-images;android-33;google_apis_playstore;arm64-v8a"
# installedImage=$(sdkmanager --list_installed | grep -o $sdk)
# if [[ $installedImage = $sdk ]]; then
# echo "The required SDK is already installed";
# else
# yes | sdkmanager --install $sdk
# yes | sdkmanager --licenses

# fi

name=Test_Pixel_2_API_33
cd $ANDROID_HOME/tools/bin
echo no | avdmanager create avd --force --name Test_Pixel_2_API_33 --abi arm64-v8a --package

echo no | avdmanager create avd --force --name EmulatorFlutter --package "system-images;android-33;google_apis_playstore"