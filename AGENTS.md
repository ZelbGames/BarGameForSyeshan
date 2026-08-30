# AGENTS.md

- **Engine:** Godot 4.6 (Forward Plus), Jolt Physics.
- **Main Scene:** `res://Level/main.tscn` (`uid://u7cs2cr708k7`).
- **Autoloads:** `UiSignals` (`res://UI/UI_Signals.gd`).
- **Input Maps:** `forward` (W), `backwards` (S), `left` (A), `right` (D), `interact` (E), `primary` (LMB), `seconday` (RMB), `sprint` (Shift), `quit` (Esc).
- **Architecture:** PS1 retro style horror/bar game prototype. Uses custom GDShaders (`CRT.gdshader`, `ScreenEffects.gdshader`, etc.) and Jolt physics.
