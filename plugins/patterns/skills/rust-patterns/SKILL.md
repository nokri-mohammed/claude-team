---
name: rust-patterns
description: House rules for writing clear, explicit Rust that a developer new to Rust (coming from JS/TypeScript) can read line by line. No shorthand, comments above the code, generic plumbing in small services/ structs with unit tests. Use when writing, refactoring or reviewing any Rust code in projects that install the patterns plugin.
metadata:
  origin: this hub (owner feedback from the pi-homelab-dashboard refactor)
---

# Rust Patterns

The reader of this code is learning Rust and comes from JS/TypeScript. Write code that reads
top to bottom with no hidden control flow. Being explicit beats being short. Each rule below
comes from feedback the owner gave during a real refactor.

## When to Activate

- Writing new Rust code or tests
- Refactoring Rust code (extracting services, renaming, splitting files)
- Reviewing a Rust diff

## Rule 1: no shorthand

Every fallible call is two steps: store the result, then `match` on it. Plain `if` on a `bool`
is fine.

Not allowed: `if let`, `while let`, `?`, `.expect(...)`, `unwrap_or`, `unwrap_or_else`,
`map_or`, long iterator chains (`.iter().map().filter().collect()`), closures where a loop
works, struct field init shorthand.

One exception: destructuring a pattern keeps the short form. When unpacking a struct or enum
variant in a `match` arm or `let`, write `Command::Report { daemon, device_id }`, not
`{ daemon: daemon, device_id: device_id }`. Rust's own `non_shorthand_field_patterns` warning
flags the long form, and CI treats warnings as errors. Building a struct still uses the long
form (`Foo { bar: bar }`).

`.unwrap()` is allowed in tests only.

Bad:

```rust
let socket = UdpSocket::bind(addr).await.expect("bind udp");
if let Some((bytes, peer)) = server.receive().await { handle(bytes, peer); }
let path = env::var("SOCKET_PATH").unwrap_or_else(|_| DEFAULT_SOCKET_PATH.to_string());
UnixSocketServer { listener }
```

Good:

```rust
// bind the socket; fatal if it fails
let bound = UdpSocket::bind(addr).await;
let socket = match bound {
    Ok(s) => s,
    Err(e) => panic!("bind udp {addr}: {e}"),
};

let received = server.receive().await;
let (bytes, peer) = match received {
    Some(x) => x,
    None => continue,
};

let socket_path_read = env::var("SOCKET_PATH");
let socket_path = match socket_path_read {
    Ok(v) => v,
    Err(_) => DEFAULT_SOCKET_PATH.to_string(),
};

UnixSocketServer { listener: listener }
```

To ignore an error on purpose, still match, with both arms empty:

```rust
// clear stale socket file left behind by a previous run
let removed = std::fs::remove_file(socket_path);
match removed {
    Ok(_) => {}
    Err(_) => {}
}
```

## Rule 2: loops and ifs instead of iterator chains

Bad:

```rust
let statuses: Vec<DeviceStatus> = snapshot
    .values()
    .map(|(report, last_seen)| DeviceStatus {
        report: report.clone(),
        online: now.duration_since(*last_seen) < OFFLINE_AFTER,
    })
    .collect();
```

Good:

```rust
// build each device's status (online if seen recently) into one list
let mut statuses: Vec<DeviceStatus> = Vec::new();
for (report, last_seen) in snapshot.values() {
    let silent_for = now.duration_since(*last_seen);

    let online;
    if silent_for < OFFLINE_AFTER {
        online = true;
    } else {
        online = false;
    }

    let status = DeviceStatus {
        report: report.clone(),
        online: online,
    };
    statuses.push(status);
}
```

The same goes for "find the first match, else a fallback": write a `for` loop that returns
early, then the fallback after the loop.

## Rule 3: comments go above the code, short

- One short line above the block it describes. Never a trailing comment at the end of a line.
- One comment covers the whole block, not every line.
- When a comment needs more than one line (a function summary plus its parameters), use a
  `/* */` block, not stacked `//` lines.
- Example commands go in a comment above the line that parses them.

Bad:

```rust
let ip = client.local_ip(); // get our ip
// sends stats to the daemon
// daemon: the address
// interval_secs: seconds between reports
fn run(daemon: &str, device_id: &str, label: &str, interval_secs: u64) {
```

Good:

```rust
/*
 * sends this machine's stats to the daemon every few seconds, forever
 *
 * daemon: daemon address, e.g. 192.168.1.50:8765
 * device_id: stable id the dashboard tracks this device by, e.g. pi-zero
 * label: short name shown on the dashboard, e.g. Pi
 * interval_secs: seconds to wait between reports
 */
fn run(daemon: &str, device_id: &str, label: &str, interval_secs: u64) {

// e.g. reporter run --daemon 192.168.1.50:8765 --device-id pi-zero --label Pi --interval 4
let cli = Cli::parse();
```

## Rule 4: generic plumbing in services/, project logic in main

- `services/` holds small, generic structs ("classes") that wrap one piece of plumbing:
  a socket, a channel, a stats reader. A service must make sense in any other project.
- Name services after what they wrap, never after this project. `UnixSocketServer`, not
  `DashboardSocket`.
- A service has few methods and hides the repeated error handling (the bind/accept/write plus
  match), nothing more.
- The orchestration stays in `main.rs`: loops, timers, `tokio::spawn`, which channel feeds
  which socket, what the bytes mean.
- When code is shared by two binaries, put it in one file in the library crate, not two copies.
  `services/udp.rs` holds both `UdpSocketServer` and `UdpClient`.

Bad (the service owns project policy: who subscribes, what gets broadcast, the spawn loop):

```rust
pub struct DashboardSocket { listener: UnixListener, tx: broadcast::Sender<String> }
impl DashboardSocket {
    pub async fn run_relay(&self) { loop { /* accept, spawn, forward every status */ } }
}
```

Good (the service only wraps accept and write; main decides the rest):

```rust
pub struct UnixSocketServer { listener: UnixListener }
impl UnixSocketServer {
    // accepts one connection; logs and returns None on error
    pub async fn subscribe(&self) -> Option<Subscriber> { /* accept + match */ }
}

pub struct Subscriber { stream: UnixStream }
impl Subscriber {
    // writes bytes to this client; false once the client is gone
    pub async fn broadcast(&mut self, bytes: &[u8]) -> bool { /* write_all + match */ }
}
```

Keep the API symmetric. Do not mix a static `Type::broadcast(&mut stream, ..)` with an
instance `server.subscribe()`. If a value (like the stream) is always needed, let a small
struct own it and expose instance methods.

## Rule 5: errors in services

- Setup failures (bind, connect, bad address) panic with a message that names the input:
  `panic!("bind udp {addr}: {e}")`.
- Failures inside a running loop do not panic. The service logs with a short prefix
  (`udp:`, `daemon:`) and returns `Option` or `bool`, so the caller decides to `continue` or
  `break`.

```rust
// waits for one packet; logs and returns None on error
pub async fn receive(&mut self) -> Option<(&[u8], SocketAddr)> {
    let received = self.socket.recv_from(&mut self.buf).await;
    match received {
        Ok((len, peer)) => Some((&self.buf[..len], peer)),
        Err(e) => {
            eprintln!("udp: recv error: {e}");
            None
        }
    }
}
```

## Rule 6: names say what the code does, and the loop stays visible

- A function name is a verb phrase for what one call does: `broadcast_statuses`, not
  `tick_loop`.
- Do not hide a forever loop or a timer inside a helper. Put the loop where the reader can see
  it, and let the helper do one pass.

Bad:

```rust
tick_loop(&state, &broadcaster).await; // loops forever inside
```

Good:

```rust
// every second, build a status summary and broadcast it
async {
    let mut interval = tokio::time::interval(Duration::from_secs(1));
    loop {
        // wait for the next 1-second tick
        interval.tick().await;
        broadcast_statuses(&state, &broadcaster).await;
    }
},
```

## Rule 7: every service gets unit tests for the edge cases

- A `#[cfg(test)] mod tests` at the bottom of each service file.
- Cover the happy path and the edges: empty input, input too big, nobody listening, invalid
  address (`#[should_panic(expected = "...")]`), address in use, disconnected peer, stale files.
- Pure logic (pick the root disk, pick the CPU sensor) goes in a plain function that takes
  plain data, so tests can feed it fake readings without real hardware.
- Tests clean up after themselves (delete socket files, use short unique `/tmp` paths: Linux
  caps Unix socket paths at about 108 characters).

```rust
#[test]
#[should_panic(expected = "bind udp")]
fn invalid_address_panics() {
    let runtime = tokio::runtime::Runtime::new().unwrap();
    let _guard = runtime.enter();
    runtime.block_on(UdpSocketServer::new("not-an-address"));
}
```

## Rule 8: small explicit details

- Write `.clone()` where ownership needs it, for example before moving a struct whose field you
  still need: `let device_id = report.device_id.clone();`.
- Release locks early with an explicit `drop(guard);` and a comment saying why.
- Gate platform-only modules: `#[cfg(unix)] pub mod unix_socket;` so a Windows build still
  compiles.

## How to work with the owner

- When asked "what did you understand", explain the plan in a few lines before writing code.
- Explain Rust concepts with JS/TS comparisons, in plain words. "In short" means one or two
  sentences.
- Never use em dashes in comments, docs or replies.
- Run `cargo test --workspace` after every change and report the real result.
