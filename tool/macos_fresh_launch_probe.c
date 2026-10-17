// Standalone disposable experiment. The sink is a fixed JSON token, never exec.
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <spawn.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/event.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define IO_MS 2000
#define OBSERVE_MS 800
#define LIFE_MS 6000
#define MAX_EVENTS 64
#define MAX_COMMANDS 16
#define WATCHDOG_SECONDS 8

static int event_count;
static const char *role;

static long long now_ms(void) {
  struct timespec value;
  if (clock_gettime(CLOCK_MONOTONIC, &value) != 0) {
    _exit(80);
  }
  return (long long)value.tv_sec * 1000 + value.tv_nsec / 1000000;
}

static void emit(const char *phase, int value) {
  char line[200];
  if (++event_count > MAX_EVENTS) {
    _exit(81);
  }
  int size = snprintf(line, sizeof(line),
                      "{\"role\":\"%s\",\"phase\":\"%s\",\"value\":%d}\n",
                      role, phase, value);
  if (size < 0 || size >= (int)sizeof(line) || write(1, line, (size_t)size) != size) {
    _exit(82);
  }
}

static int byte_until(int fd, long long deadline) {
  while (now_ms() < deadline) {
    long long remaining = deadline - now_ms();
    if (remaining <= 0) {
      return -1;
    }
    struct pollfd item = {fd, POLLIN, 0};
    int result = poll(&item, 1, (int)remaining);
    if (result < 0 && errno == EINTR) {
      continue;
    }
    if (result <= 0) {
      return -1;
    }
    unsigned char byte;
    return read(fd, &byte, 1) == 1 ? byte : -1;
  }
  return -1;
}

static bool same(const char *a, const char *b) { return strcmp(a, b) == 0; }

static void consider_exit(bool *sealed, bool armed, bool eligible,
                          long long deadline, int *sinks) {
  if (!*sealed && armed && eligible && now_ms() < deadline) {
    ++*sinks;
    *sealed = true;
    emit("SYNTHETIC_SINK", *sinks);
  } else if (!*sealed || *sinks == 0) {
    *sealed = true;
    emit("exit_refused", *sinks);
  }
}

static int helper(const char *scenario, pid_t parent, int command, int ack,
                  int lock_fd) {
  role = "helper";
  long long lifetime = now_ms() + LIFE_MS;
  bool inherited = fcntl(lock_fd, F_GETFD) >= 0;
  emit("lock_descriptor_present", inherited);
  if (byte_until(command, now_ms() + IO_MS) != 'G') {
    emit("no_start", 0);
    return 0;
  }
  if (same(scenario, "helper_death")) {
    emit("injected_helper_death", 0);
    return 0;
  }
  pid_t recorded = same(scenario, "wrong_parent") ? parent + 1 : parent;
  if (same(scenario, "stale_identity")) {
    recorded = 1; // Injected mismatch, never registration against this PID.
  }
  if (getppid() != recorded) {
    emit("parent_mismatch", 0);
    return 0;
  }
  emit("parent_before", 1);
  int queue = kqueue();
  if (queue < 0) {
    emit("queue_error", errno);
    return 90;
  }
  struct kevent change;
  EV_SET(&change, (uintptr_t)parent, EVFILT_PROC, EV_ADD | EV_ONESHOT,
         NOTE_EXIT, 0, NULL);
  // Closed/invalid descriptor is a real EBADF response to injected input.
  int result = kevent(same(scenario, "registration_failure") ? -1 : queue,
                      &change, 1, NULL, 0, NULL);
  if (result != 0) {
    emit("registration_error", errno);
    close(queue);
    return same(scenario, "registration_failure") ? 0 : 91;
  }
  if (getppid() != parent) {
    emit("parent_mismatch", 0);
    close(queue);
    return 0;
  }
  emit("registered", 1);
  if (byte_until(command, now_ms() + IO_MS) != 'R' || getppid() != parent) {
    emit("no_readiness", 0);
    close(queue);
    return 0;
  }
  if (same(scenario, "readiness_timeout")) {
    (void)byte_until(command, now_ms() + IO_MS);
    emit("readiness_expired", 0);
    close(queue);
    return 0;
  }
  if (same(scenario, "missing_readiness")) {
    emit("readiness_withheld", 0);
    close(queue);
    return 0;
  }
  if (write(ack, "R", 1) != 1) {
    emit("ack_error", errno);
    close(queue);
    return 92;
  }
  // Writing readiness alone is insufficient: the still-live parent must
  // confirm it actually received this helper's acknowledgment.
  if (byte_until(ack, now_ms() + IO_MS) != 'V' || getppid() != parent) {
    emit("ack_not_confirmed", 0);
    close(ack);
    close(queue);
    return 0;
  }
  close(ack);
  emit("ready", 1);
  EV_SET(&change, (uintptr_t)command, EVFILT_READ, EV_ADD, 0, 0, NULL);
  if (kevent(queue, &change, 1, NULL, 0, NULL) != 0) {
    close(queue);
    return 93;
  }
  bool armed = false, sealed = false, eligible = true, observed = false;
  int arms = 0, sinks = 0, commands = 0;
  long long observation = now_ms() + IO_MS;
  while (now_ms() < lifetime) {
    long long deadline = sealed ? lifetime : observation;
    long long remaining = deadline - now_ms();
    if (remaining <= 0 && !sealed) {
      sealed = true;
      emit("expired", sinks);
      continue;
    }
    if (remaining <= 0) {
      break;
    }
    struct timespec timeout = {remaining / 1000, (remaining % 1000) * 1000000};
    struct kevent events[2];
    int count = kevent(queue, NULL, 0, events, 2, &timeout);
    if (count < 0) {
      if (errno == EINTR) {
        continue;
      }
      emit("observation_error", errno);
      close(queue);
      return 94;
    }
    bool exited = false;
    for (int i = 0; i < count; ++i) {
      if ((events[i].flags & EV_ERROR) != 0) {
        emit("observation_error", (int)events[i].data);
        close(queue);
        return 95;
      }
      if (events[i].filter == EVFILT_PROC && events[i].ident == (uintptr_t)parent &&
          (events[i].fflags & NOTE_EXIT) != 0) {
        exited = true;
      }
    }
    // Consume queued disarm/duplicate/invalidations before considering exit.
    struct pollfd item = {command, POLLIN, 0};
    while (poll(&item, 1, 0) > 0) {
      char byte;
      if (read(command, &byte, 1) != 1) {
        emit("control_closed", sinks);
        close(queue);
        return 0;
      }
      if (++commands > MAX_COMMANDS) {
        close(queue);
        return 96;
      }
      if (byte == 'X') {
        emit("done", sinks);
        close(queue);
        return 0;
      }
      if (byte == 'C' && inherited) {
        close(lock_fd); // Never LOCK_UN on an inherited reference.
        inherited = false;
        emit("inherited_closed", 1);
      } else if (byte == 'A') {
        if (++arms != 1 || sealed) {
          sealed = true;
          emit("duplicate_refused", sinks);
        } else {
          armed = true;
          observation = now_ms() + OBSERVE_MS;
          emit("armed", 1);
        }
      } else if (byte == 'D') {
        sealed = true;
        emit("disarmed", sinks);
      } else if (byte == 'I') {
        eligible = false;
        emit("eligibility_invalidated", 0);
      }
    }
    if (exited) {
      observed = true;
      emit("note_exit", 1);
      consider_exit(&sealed, armed, eligible, observation, &sinks);
      if (same(scenario, "duplicate_event")) {
        // Fault injection re-enters the same gate after a physical NOTE_EXIT.
        consider_exit(&sealed, armed, eligible, observation, &sinks);
        emit("injected_duplicate_event", sinks);
      }
    }
  }
  emit("lifetime_expired", observed);
  close(queue);
  return 97; // Watchdog cleanup is never reported as a successful test.
}

static int bounded_reap(pid_t child) {
  long long deadline = now_ms() + IO_MS;
  struct timespec pause = {0, 10000000};
  while (now_ms() < deadline) {
    int status;
    pid_t result = waitpid(child, &status, WNOHANG);
    if (result == child) {
      emit("child_reaped", WIFEXITED(status) ? WEXITSTATUS(status) : -1);
      return WIFEXITED(status) && WEXITSTATUS(status) == 0 ? 0 : 98;
    }
    if (result < 0) {
      return 99;
    }
    nanosleep(&pause, NULL);
  }
  // Direct child remains unreaped, so its identity cannot have been recycled.
  kill(child, SIGKILL);
  emit("cleanup_unknown", 0);
  return 100;
}

int main(int argc, char **argv) {
  signal(SIGPIPE, SIG_IGN);
  alarm(WATCHDOG_SECONDS);
  if (fcntl(1, F_SETFL, O_NONBLOCK) != 0) {
    return 101;
  }
  if (argc == 7 && same(argv[1], "helper")) {
    return helper(argv[2], (pid_t)atoi(argv[3]), atoi(argv[4]), atoi(argv[5]),
                  atoi(argv[6]));
  }
  role = "parent";
  if (argc != 4 || !same(argv[1], "parent")) {
    return 64;
  }
  const char *scenario = argv[2];
  int command = atoi(argv[3]);
  int lock_fd = open("fixture.lock", O_CREAT | O_EXCL | O_RDWR, 0600);
  if (lock_fd < 0 || flock(lock_fd, LOCK_EX | LOCK_NB) != 0) {
    return 65;
  }
  int ack[2];
  if (socketpair(AF_UNIX, SOCK_STREAM, 0, ack) != 0) {
    return 66;
  }
  bool inherit = same(scenario, "inherit");
  bool cloexec = same(scenario, "cloexec");
  if (cloexec && fcntl(lock_fd, F_SETFD, FD_CLOEXEC) != 0) {
    return 67;
  }
  posix_spawn_file_actions_t actions;
  if (posix_spawn_file_actions_init(&actions) != 0 ||
      posix_spawn_file_actions_addclose(&actions, ack[0]) != 0 ||
      posix_spawn_file_actions_addclose(&actions, 0) != 0 ||
      (!inherit && !cloexec &&
       posix_spawn_file_actions_addclose(&actions, lock_fd) != 0)) {
    return 68;
  }
  char parent_text[32], command_text[32], ack_text[32], lock_text[32];
  snprintf(parent_text, sizeof(parent_text), "%d", getpid());
  snprintf(command_text, sizeof(command_text), "%d", command);
  snprintf(ack_text, sizeof(ack_text), "%d", ack[1]);
  snprintf(lock_text, sizeof(lock_text), "%d", lock_fd);
  char *arguments[] = {argv[0], "helper", argv[2], parent_text, command_text,
                       ack_text, lock_text, NULL};
  char *environment[] = {"LANG=C", NULL};
  pid_t child;
  int spawned = same(scenario, "spawn_failure")
                    ? posix_spawn(&child, "", &actions, NULL, arguments, environment)
                    : posix_spawn(&child, argv[0], &actions, NULL, arguments, environment);
  posix_spawn_file_actions_destroy(&actions);
  close(ack[1]);
  close(command);
  if (spawned != 0) {
    emit("spawn_error", spawned);
    close(ack[0]);
    close(lock_fd);
    return same(scenario, "spawn_failure") ? 0 : 69;
  }
  emit("spawned", child);
  int action = byte_until(0, now_ms() + IO_MS);
  if (action == 'E') {
    return 0; // Deliberate early-exit fixture.
  }
  if (action != 'R') {
    return 70;
  }
  int ready = byte_until(ack[0], now_ms() + IO_MS);
  emit("readiness_received", ready == 'R');
  if (ready == 'R' && !same(scenario, "unconfirmed_ack")) {
    if (write(ack[0], "V", 1) != 1) {
      close(ack[0]);
      return 102;
    }
  }
  close(ack[0]);
  if (ready != 'R') {
    int reaped = bounded_reap(child);
    close(lock_fd);
    return reaped;
  }
  action = byte_until(0, now_ms() + LIFE_MS);
  if (action == 'K') {
    raise(SIGKILL); // Only this disposable process, never a caller-supplied PID.
  }
  if (action == 'E') {
    return 0;
  }
  int reaped = bounded_reap(child);
  close(lock_fd);
  return action == 'Q' ? reaped : 71;
}
