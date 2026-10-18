/*
 * dowser-passthrough.c
 * ---------------------
 * A drop-in replacement for Cities: Skylines II's Paradox launcher bootstrapper
 * (`Launcher\dowser.exe`) that skips the launcher entirely and starts the game.
 *
 * WHY THIS EXISTS
 *   On Steam, Cities: Skylines II launches `Launcher\dowser.exe`, which boots the
 *   Paradox launcher UI before the game. Under Wine/D3DMetal on Apple Silicon the
 *   Paradox launcher is unreliable (and unnecessary — Paradox Mods still works
 *   through the in-game menu). The usual "skip launcher" Steam launch-option trick
 *   doesn't stick because Steam invokes dowser.exe directly. Replacing dowser.exe
 *   with this stub makes Steam's launch path go straight to the game.
 *
 * WHAT IT DOES
 *   1. Launches `..\Cities2.exe` (dowser lives in Launcher\, the game is one level up).
 *   2. For a few seconds, repeatedly pushes the game's top-level window to the
 *      foreground. This is a belt-and-suspenders focus nudge at startup; the real
 *      fix for the recurring focus-loss freeze is running the game in BORDERLESS
 *      display mode (see docs/focus-freeze-fix.md), not this.
 *   3. Waits for the game to exit, then returns its exit code (so Steam still sees
 *      "running" / "stopped" correctly).
 *
 * BUILD (on macOS, with mingw-w64 from Homebrew: `brew install mingw-w64`)
 *   x86_64-w64-mingw32-gcc -O2 -mwindows \
 *       -o dowser.exe dowser-passthrough.c -luser32
 *
 * INSTALL  (see launcher-bypass/README.md for the full procedure)
 *   Back up the original:  mv dowser.exe dowser.exe.off
 *   Drop this build in as: Launcher\dowser.exe
 *
 * This file is MIT-licensed (see repo LICENSE). It contains no Apple code.
 */

#include <windows.h>
#include <stdio.h>

/* How long to keep nudging the game window to the foreground after launch. */
#define FOCUS_WINDOW_MS   25000
#define FOCUS_POLL_MS       500

static DWORD        g_childPid = 0;
static HWND         g_best     = NULL;
static RECT         g_bestRect = {0};

/* Pick the largest visible, titled top-level window owned by the game process. */
static BOOL CALLBACK pick_window(HWND hwnd, LPARAM lparam)
{
    (void)lparam;
    if (!IsWindowVisible(hwnd)) return TRUE;

    DWORD pid = 0;
    GetWindowThreadProcessId(hwnd, &pid);
    if (pid != g_childPid) return TRUE;

    /* Skip tool windows and zero-area windows. */
    RECT r;
    if (!GetWindowRect(hwnd, &r)) return TRUE;
    LONG w = r.right - r.left, h = r.bottom - r.top;
    if (w <= 0 || h <= 0) return TRUE;

    LONG bestArea = (g_bestRect.right - g_bestRect.left) *
                    (g_bestRect.bottom - g_bestRect.top);
    if ((LONG)(w * h) > bestArea) {
        g_best     = hwnd;
        g_bestRect = r;
    }
    return TRUE;
}

static void nudge_foreground(void)
{
    g_best = NULL;
    ZeroMemory(&g_bestRect, sizeof(g_bestRect));
    EnumWindows(pick_window, 0);
    if (!g_best) return;

    AllowSetForegroundWindow(g_childPid);
    ShowWindow(g_best, SW_SHOW);
    BringWindowToTop(g_best);
    SetForegroundWindow(g_best);
    SetActiveWindow(g_best);
    SetFocus(g_best);
}

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmdLine, int nShow)
{
    (void)hInst; (void)hPrev; (void)lpCmdLine; (void)nShow;

    /* Resolve ..\Cities2.exe relative to this executable's directory. */
    char self[MAX_PATH];
    GetModuleFileNameA(NULL, self, MAX_PATH);
    char *slash = strrchr(self, '\\');          /* ...\Launcher\dowser.exe   */
    if (slash) *slash = '\0';                    /* ...\Launcher              */
    slash = strrchr(self, '\\');                 /* ...\<game root>\Launcher  */
    if (slash) *slash = '\0';                    /* ...\<game root>           */

    char gameExe[MAX_PATH];
    snprintf(gameExe, sizeof(gameExe), "%s\\Cities2.exe", self);

    STARTUPINFOA        si = { sizeof(si) };
    PROCESS_INFORMATION pi = {0};

    /* CREATE_NEW_PROCESS_GROUP so Steam's stop signal reaches the game cleanly. */
    if (!CreateProcessA(gameExe, NULL, NULL, NULL, FALSE,
                        CREATE_NEW_PROCESS_GROUP, NULL, self, &si, &pi)) {
        char msg[MAX_PATH + 64];
        snprintf(msg, sizeof(msg),
                 "Could not launch:\n%s\n\nError %lu", gameExe, GetLastError());
        MessageBoxA(NULL, msg, "dowser passthrough", MB_ICONERROR | MB_OK);
        return 1;
    }
    g_childPid = pi.dwProcessId;

    /* Startup foreground nudges, then hand off and wait. */
    for (DWORD elapsed = 0; elapsed < FOCUS_WINDOW_MS; elapsed += FOCUS_POLL_MS) {
        if (WaitForSingleObject(pi.hProcess, FOCUS_POLL_MS) == WAIT_OBJECT_0)
            break;                              /* game exited early */
        nudge_foreground();
    }

    WaitForSingleObject(pi.hProcess, INFINITE);

    DWORD code = 0;
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return (int)code;
}
