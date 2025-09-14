#!/usr/bin/env python3

import json
import subprocess
import sys


def get_player_info():
    try:
        # Get current player status
        status_result = subprocess.run(
            ["playerctl", "status"], capture_output=True, text=True
        )
        if status_result.returncode != 0:
            return None

        status = status_result.stdout.strip()
        if status not in ["Playing", "Paused"]:
            return None

        # Get metadata
        artist = subprocess.run(
            ["playerctl", "metadata", "artist"], capture_output=True, text=True
        ).stdout.strip()
        title = subprocess.run(
            ["playerctl", "metadata", "title"], capture_output=True, text=True
        ).stdout.strip()
        player = subprocess.run(
            ["playerctl", "metadata", "mpris:trackid"], capture_output=True, text=True
        ).stdout.strip()

        # Format output
        if artist and title:
            text = f"{artist} - {title}"
        elif title:
            text = title
        else:
            text = "Unknown"

        # Truncate if too long
        if len(text) > 35:
            text = text[:32] + "..."

        # Determine icon based on player
        icon = "spotify" if "spotify" in player.lower() else "default"

        return {
            "text": text,
            "class": status.lower(),
            "alt": status,
            "tooltip": f"Player: {status}\n{artist}\n{title}",
            "icon": icon,
        }

    except Exception as e:
        return None


if __name__ == "__main__":
    player_info = get_player_info()
    if player_info:
        print(json.dumps(player_info))
    else:
        print(json.dumps({"text": "", "class": "stopped"}))
