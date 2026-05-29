"""Thin subprocess wrapper for MCP stdio communication."""

import subprocess

_proc = None


def start(cmd_list):
    """Launch a subprocess with stdin/stdout/stderr pipes."""
    global _proc
    kwargs = {
        "stdin": subprocess.PIPE,
        "stdout": subprocess.PIPE,
        "stderr": subprocess.PIPE,
    }
    if hasattr(subprocess, "CREATE_NO_WINDOW"):
        kwargs["creationflags"] = subprocess.CREATE_NO_WINDOW
    _proc = subprocess.Popen(list(cmd_list), **kwargs)


def write_line(text):
    """Write a line of text to subprocess stdin."""
    _proc.stdin.write((str(text) + "\n").encode("utf-8"))
    _proc.stdin.flush()


def read_line():
    """Read one line from subprocess stdout."""
    return _proc.stdout.readline().decode("utf-8")


def poll():
    """Return process exit code, or None if still running."""
    return _proc.poll()


def get_stderr():
    """Read stderr output."""
    return _proc.stderr.read().decode("utf-8")


def terminate():
    """Terminate the subprocess."""
    try:
        _proc.stdin.close()
    except Exception:
        pass
    _proc.terminate()
    _proc.wait()
