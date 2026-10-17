"""Bounded disposable macOS observer qualification; no application launch sink."""
import errno
import fcntl
import json
import os
from pathlib import Path
import platform
import select
import selectors
import signal
import subprocess
import tempfile
import time

OUTPUT_LIMIT = 16384  # Per fixture; C also caps each process at 64 short events.
SUITE_SECONDS = 150
CASE_SECONDS = 12
WAIT_SECONDS = 3
MAX_FIXTURE_PROCESSES = 2  # Parent and directly spawned helper, serial cases.
# Explicit inspected toolchain avoids the /usr/bin developer-tool trampoline.
# No tool discovery launches Xcode or another installed application.
COMPILER = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
SDK = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
COMPILE_FLAGS = ["-std=c11", "-Wall", "-Wextra", "-Werror", "-O0", "-isysroot", SDK]
SCENARIOS = (
    "normal", "inherit", "cloexec", "wrong_parent", "early_parent",
    "before_ack", "registration_failure", "missing_readiness", "spawn_failure",
    "helper_death", "stale_identity", "readiness_timeout", "unconfirmed_ack", "disarm", "duplicate_arm", "expiry", "pending_parent",
    "force_exit", "unarmed_force", "invalid_target", "duplicate_event",
    "cleanup_error",
)


def bounded_compile(arguments, temporary_root):
    """Bound output while reading, not after an unbounded communicate buffer."""
    process = subprocess.Popen(arguments, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT,
                               env={"LANG": "C", "TMPDIR": str(temporary_root)})
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    output = bytearray()
    deadline = time.monotonic() + 20
    try:
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise RuntimeError("STOP: compiler deadline")
            if not selector.select(remaining):
                raise RuntimeError("STOP: compiler deadline")
            chunk = os.read(process.stdout.fileno(), 4096)
            if not chunk:
                break
            if len(output) + len(chunk) > OUTPUT_LIMIT:
                raise RuntimeError("STOP: compiler output bound")
            output.extend(chunk)
        result = process.wait(timeout=max(0.01, deadline - time.monotonic()))
        return result, bytes(output)
    finally:
        if process.poll() is None:
            process.kill()  # Only the unreaped compiler child owned by Popen.
            process.wait(timeout=WAIT_SECONDS)
        selector.close()
        process.stdout.close()


class CleanupUnknown(RuntimeError):
    pass


def require_cleanup(evidence, injected_error=False):
    """One gate for actual cleanup evidence and injected reporting failure."""
    if injected_error or not all(evidence.values()):
        raise CleanupUnknown("cleanup evidence UNKNOWN/STOP")


class Fixture:
    def __init__(self, executable, directory, scenario):
        self.scenario = scenario
        self.directory = directory
        self.deadline = time.monotonic() + CASE_SECONDS
        self.events = []
        self.buffer = b""
        self.output_bytes = 0
        self.eof = False
        self.helper_pid = None
        self.helper_exited = False
        self.queue = select.kqueue()
        self.selector = selectors.DefaultSelector()
        command_read, self.command_write = os.pipe()
        try:
            self.parent = subprocess.Popen(
                [str(executable), "parent", scenario, str(command_read)],
                cwd=directory, env={"LANG": "C"}, pass_fds=(command_read,),
                stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, close_fds=True,
            )
        finally:
            os.close(command_read)
        os.set_blocking(self.parent.stdout.fileno(), False)
        self.selector.register(self.parent.stdout, selectors.EVENT_READ)

    def parent_command(self, command):
        self.parent.stdin.write(command.encode("ascii"))
        self.parent.stdin.flush()

    def helper_command(self, command):
        os.write(self.command_write, command.encode("ascii"))

    def pump(self, timeout):
        if time.monotonic() >= self.deadline:
            raise AssertionError("fixture deadline")
        for _key, _mask in self.selector.select(timeout):
            block = os.read(self.parent.stdout.fileno(), 4096)
            if not block:
                self.eof = True
                self.selector.unregister(self.parent.stdout)
                continue
            self.output_bytes += len(block)
            if self.output_bytes > OUTPUT_LIMIT:
                raise AssertionError("output bound")
            self.buffer += block
            while b"\n" in self.buffer:
                line, self.buffer = self.buffer.split(b"\n", 1)
                self.events.append(json.loads(line))

    def wait(self, phase, role=None):
        end = min(self.deadline, time.monotonic() + WAIT_SECONDS)
        while True:
            found = [e for e in self.events if e["phase"] == phase
                     and (role is None or e["role"] == role)]
            if found:
                return found[-1]["value"]
            if self.eof or time.monotonic() >= end:
                raise AssertionError("missing phase: " + phase)
            self.pump(min(0.1, max(0, end - time.monotonic())))

    def watch_helper(self):
        self.helper_pid = self.wait("spawned")
        # Child is held on G. Registration precedes any permission to proceed.
        self.queue.control([select.kevent(
            self.helper_pid, filter=select.KQ_FILTER_PROC,
            flags=select.KQ_EV_ADD | select.KQ_EV_ONESHOT,
            fflags=select.KQ_NOTE_EXIT,
        )], 0, 0)

    def observe_helper_exit(self):
        if self.helper_pid is None or self.helper_exited:
            return
        remaining = min(WAIT_SECONDS, self.deadline - time.monotonic())
        if remaining <= 0:
            raise AssertionError("helper cleanup deadline")
        events = self.queue.control(None, 1, remaining)
        assert len(events) == 1, "helper exit UNKNOWN"
        event = events[0]
        assert not event.flags & select.KQ_EV_ERROR, "helper event error"
        assert event.ident == self.helper_pid and event.fflags & select.KQ_NOTE_EXIT
        self.helper_exited = True

    def lock_available(self):
        # Driver is a separate process, opening an independent file description.
        with (self.directory / "fixture.lock").open("rb") as contender:
            try:
                fcntl.flock(contender, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return False
            # Closing this independently acquired description releases it.
            return True

    def finish(self, parent_exited=False):
        self.observe_helper_exit()
        if not parent_exited and self.parent.poll() is None:
            self.parent_command("Q")
        result = self.parent.wait(timeout=WAIT_SECONDS)
        assert result in (0, -signal.SIGKILL), "parent failure: " + str(result)
        end = time.monotonic() + WAIT_SECONDS
        while not self.eof and time.monotonic() < end:
            self.pump(0.05)
        assert self.eof and not self.buffer, "pipe cleanup UNKNOWN"
        assert self.lock_available(), "fixture lock retained"
        assert not any(e["phase"] in ("cleanup_unknown", "lifetime_expired")
                       for e in self.events), "cleanup UNKNOWN"
        self.cleanup_evidence = {
            "helper_exit": self.helper_pid is None or self.helper_exited,
            "parent_reaped": self.parent.returncode is not None,
            "pipe_eof": self.eof,
            "lock_available": self.lock_available(),
        }
        require_cleanup(self.cleanup_evidence)
        return result

    def close(self):
        # Failure cleanup never signals a possibly recycled grandchild PID.
        # Helper has a bounded self-watchdog; independently registered NOTE_EXIT
        # is required. Direct parent identity is held by the unreaped Popen child.
        cleanup_errors = []
        try:
            if self.parent.poll() is None:
                try:
                    self.helper_command("X")
                    self.parent_command("Q")
                except (BrokenPipeError, OSError):
                    pass
                try:
                    self.parent.wait(timeout=WAIT_SECONDS)
                except subprocess.TimeoutExpired:
                    self.parent.kill()
                    self.parent.wait(timeout=WAIT_SECONDS)
            if self.helper_pid is not None and not self.helper_exited:
                # Give the fixture watchdog time to end this exact observed child.
                events = self.queue.control(None, 1, 9)
                if not events or not events[0].fflags & select.KQ_NOTE_EXIT:
                    cleanup_errors.append("helper death unconfirmed")
                else:
                    self.helper_exited = True
        finally:
            os.close(self.command_write)
            self.parent.stdin.close()
            self.parent.stdout.close()
            self.selector.close()
            self.queue.close()
        if cleanup_errors:
            raise RuntimeError("STOP: " + ", ".join(cleanup_errors))


def run_case(executable, directory, scenario):
    fixture = Fixture(executable, directory, scenario)
    parent_exited = False
    expected_sink = 0
    try:
        if scenario == "spawn_failure":
            assert fixture.wait("spawn_error") != 0
            fixture.finish(parent_exited=True)
        else:
            fixture.watch_helper()
            inherited = fixture.wait("lock_descriptor_present")
            assert inherited == int(scenario == "inherit")
            assert not fixture.lock_available(), "parent must still own lock"
            assert fixture.parent.poll() is None
            if scenario == "early_parent":
                fixture.parent_command("E")
                assert fixture.parent.wait(timeout=WAIT_SECONDS) == 0
                parent_exited = True
            fixture.helper_command("G")
            if scenario in ("wrong_parent", "stale_identity", "early_parent", "registration_failure",
                            "helper_death"):
                phase = {"wrong_parent": "parent_mismatch", "stale_identity": "parent_mismatch", "early_parent": "parent_mismatch",
                         "registration_failure": "registration_error",
                         "helper_death": "injected_helper_death"}[scenario]
                value = fixture.wait(phase)
                if scenario == "registration_failure":
                    assert value == errno.EBADF
                if not parent_exited:
                    fixture.parent_command("R")
                    assert fixture.wait("readiness_received") == 0
                fixture.finish(parent_exited=parent_exited)
            else:
                assert fixture.wait("registered") == 1
                if scenario == "before_ack":
                    fixture.parent_command("E")
                    assert fixture.parent.wait(timeout=WAIT_SECONDS) == 0
                    fixture.helper_command("R")
                    fixture.wait("no_readiness")
                    fixture.finish(parent_exited=True)
                else:
                    fixture.parent_command("R")
                    fixture.helper_command("R")
                    if scenario in ("missing_readiness", "readiness_timeout"):
                        fixture.wait("readiness_withheld" if scenario == "missing_readiness"
                                     else "readiness_expired")
                        assert fixture.wait("readiness_received") == 0
                        fixture.finish()
                    elif scenario == "unconfirmed_ack":
                        fixture.wait("ack_not_confirmed")
                        fixture.finish()
                    else:
                        assert fixture.wait("ready") == 1
                        assert fixture.wait("readiness_received") == 1
                        assert fixture.parent.poll() is None
                        assert not any(e["phase"] == "SYNTHETIC_SINK" for e in fixture.events)
                        if scenario != "unarmed_force":
                            fixture.helper_command("A")
                            assert fixture.wait("armed") == 1
                        if scenario == "disarm":
                            fixture.helper_command("D")
                            assert fixture.wait("disarmed") == 0
                        elif scenario == "duplicate_arm":
                            fixture.helper_command("A")
                            assert fixture.wait("duplicate_refused") == 0
                        elif scenario in ("expiry", "pending_parent"):
                            assert fixture.wait("expired") == 0
                            assert fixture.parent.poll() is None
                            assert not fixture.lock_available()
                        elif scenario == "invalid_target":
                            fixture.helper_command("I")
                            assert fixture.wait("eligibility_invalidated") == 0
                        force = scenario in ("force_exit", "unarmed_force")
                        fixture.parent_command("K" if force else "E")
                        result = fixture.parent.wait(timeout=WAIT_SECONDS)
                        assert result == (-signal.SIGKILL if force else 0)
                        assert fixture.wait("note_exit") == 1
                        expected_sink = int(scenario in (
                            "normal", "inherit", "cloexec", "force_exit",
                            "duplicate_event", "cleanup_error",
                        ))
                        assert fixture.wait("SYNTHETIC_SINK" if expected_sink else
                                            "exit_refused") == expected_sink
                        if scenario == "duplicate_event":
                            assert fixture.wait("injected_duplicate_event") == 1
                        if scenario == "inherit":
                            assert not fixture.lock_available(), "negative control lost lock"
                            fixture.helper_command("C")
                            assert fixture.wait("inherited_closed") == 1
                        assert fixture.lock_available(), "excluded descriptor retained lock"
                        fixture.helper_command("X")
                        assert fixture.wait("done") == expected_sink
                        fixture.finish(parent_exited=True)
        sinks = [e for e in fixture.events if e["phase"] == "SYNTHETIC_SINK"]
        assert len(sinks) == expected_sink
        phases = [e["phase"] for e in fixture.events]
        if sinks:
            assert phases.index("note_exit") < phases.index("SYNTHETIC_SINK")
        result = {"scenario": scenario, "phases": phases, "sinks": len(sinks),
                  "observed_helper_exit": fixture.helper_exited,
                  "parent_reaped": fixture.parent.returncode is not None,
                  "timing_category": "deadline_refusal" if scenario in
                  ("expiry", "pending_parent", "readiness_timeout") else "barrier_ordered",
                  "lock_released": True, "pipe_eof": fixture.eof}
        if scenario == "cleanup_error":
            # Exercise the same gate used by finish(), not a parallel classifier.
            try:
                require_cleanup(fixture.cleanup_evidence, injected_error=True)
            except CleanupUnknown:
                result["injected_cleanup_evidence"] = "UNKNOWN/STOP"
            else:
                raise AssertionError("ambiguous cleanup was accepted")
            require_cleanup(fixture.cleanup_evidence)
            result["actual_cleanup"] = "PASS"
        return result
    finally:
        fixture.close()


def main():
    if platform.system() != "Darwin":
        raise SystemExit("STOP: macOS required")
    started = time.monotonic()
    source = Path(__file__).with_name("macos_fresh_launch_probe.c").resolve()
    print(json.dumps({"runtime": platform.platform(), "python": platform.python_version(),
                      "max_fixture_processes": MAX_FIXTURE_PROCESSES}))
    with tempfile.TemporaryDirectory(prefix="ml-exit-probe-") as root:
        executable = Path(root) / "probe"
        compile_exit, diagnostics = bounded_compile(
            [COMPILER, *COMPILE_FLAGS, str(source), "-o", str(executable)], root
        )
        print(json.dumps({"phase": "compile", "flags": COMPILE_FLAGS,
                          "exit": compile_exit, "diagnostic_bytes": len(diagnostics)}))
        if compile_exit or diagnostics:
            print(diagnostics.decode(errors="replace"))
            raise SystemExit("STOP: compilation not warning-free")
        for scenario in SCENARIOS:
            if time.monotonic() - started > SUITE_SECONDS:
                raise SystemExit("STOP: suite deadline")
            directory = Path(root) / scenario
            directory.mkdir()
            result = run_case(executable, directory, scenario)
            (directory / "fixture.lock").unlink()
            directory.rmdir()
            assert not directory.exists()
            result["fixture_removed"] = True
            print(json.dumps(result), flush=True)
    assert not os.path.exists(root)
    print(json.dumps({"cases": len(SCENARIOS), "result": "PASS",
                      "temporary_root_removed": True}))


if __name__ == "__main__":
    main()
