#include <windows.h>
#include <iostream>
#include <string>

// The name of the registry value we will create
#define APPLICATION_NAME "NaughtyWindow"

/**
 * Adds the current executable to the Windows Registry "Run" key
 * so it starts automatically when the user logs in.
 */
void AddToStartup() {
    HKEY registryKeyHandle;
    char executablePath[MAX_PATH];
    
    // 1. Get the full path of the current running .exe file
    // The first parameter NULL tells the function to get the path of the current process
    DWORD pathLength = GetModuleFileNameA(NULL, executablePath, MAX_PATH);
    if (pathLength == 0) {
        std::cerr << "Failed to get executable path." << std::endl;
        return;
    }

    // 2. Open the registry key for the current user's auto-run applications
    // HKEY_CURRENT_USER doesn't require administrator privileges to write to the 'Run' key
    LSTATUS openResult = RegOpenKeyExA(
        HKEY_CURRENT_USER, 
        "Software\\Microsoft\\Windows\\CurrentVersion\\Run", 
        0, 
        KEY_WRITE, 
        &registryKeyHandle
    );

    if (openResult == ERROR_SUCCESS) {
        // 3. Create or update a value inside that key
        // We set the value name to "NaughtyWindow" and the data to our file path
        LSTATUS setResult = RegSetValueExA(
            registryKeyHandle, 
            APPLICATION_NAME, 
            0, 
            REG_SZ, 
            (const BYTE*)executablePath, 
            (DWORD)(strlen(executablePath) + 1)
        );

        if (setResult == ERROR_SUCCESS) {
            std::cout << "Persistence established in Registry." << std::endl;
        } else {
            std::cerr << "Failed to set Registry value." << std::endl;
        }

        // 4. Always close the handle to the registry key when finished
        RegCloseKey(registryKeyHandle);
    } else {
        std::cerr << "Failed to open Registry key." << std::endl;
    }
}

int main() {
    // Optional: Hide the console window to act like a background process
    // HWND consoleWindowHandle = GetConsoleWindow();
    // ShowWindow(consoleWindowHandle, SW_HIDE);

    // Call our function to ensure we run again after a reboot
    AddToStartup();

    // Loop forever to keep the "malware" running
    while (true) {
        // Sleep for 15 seconds (15,000 milliseconds) to avoid spamming too fast
        Sleep(15000);

        // Display the annoying popup
        // MB_SYSTEMMODAL makes the window stay on top of other windows
        MessageBoxA(
            NULL, 
            "This is the Naughty Window bonus exercise.\nCan you find and remove me from your system?", 
            "Diagnostic Challenge", 
            MB_OK | MB_ICONEXCLAMATION | MB_SYSTEMMODAL
        );
    }

    return 0;
}
