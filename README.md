# HTTPLens

A Swift port of [`tower-http`](https://docs.rs/tower-http) plus
[`axum::middleware`](https://docs.rs/axum/latest/axum/middleware/): ready-made
HTTP middleware expressed as `Layer`s from
[`http-prism`](https://github.com/akvilary/http-prism) (the Swift `tower` port).

Direct ports of the tower-http / axum middleware you'd recognise:

- `CompressionLayer` — gzip (`Content-Encoding: gzip`), auto by `Accept-Encoding`
- `CorsLayer` — CORS preflight + header injection
- `TraceLayer` — request/response logging (configurable target)
- `TimeoutLayer` — per-request wall-clock cap → `504 Gateway Timeout`
- `RateLimitLayer` — per-peer token bucket → `429 Too Many Requests`
- `from_fn` — wrap an `(request, next) -> response` closure into a `Layer`

Built on [`http`](https://github.com/akvilary/http) for the message types and
[`http-prism`](https://github.com/akvilary/http-prism) for `Service` / `Layer`.

## Status

Early / experimental. Currently used by:

- [`starlight`](https://github.com/akvilary/starlight) — Swift port of axum (exposes these layers on its `Router` via `.layer(...)`).

## Platform

Linux primary; gzip is backed by zlib through a small C wrapper target
(`CLens`, linked against `libz`). Other layers are pure Swift and portable.

## Installation

```swift
.package(url: "https://github.com/akvilary/http-lens.git", from: "0.1.1")
```

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "HTTPLens", package: "http-lens"),
])
```

## Overview

Each `*Layer` is a concrete struct that becomes a `Layer<Request, Response>` via
`.asLayer()`. Compose them around a service with `ServiceBuilder`
([http-prism](https://github.com/akvilary/http-prism)); layers apply
outermost-first — the first one wraps everything below:

```swift
import HTTPLens
import HTTPPrism
import HTTP

let svc = ServiceBuilder()
    .layer(CompressionLayer().asLayer())                    // gzip by Accept-Encoding
    .layer(TraceLayer(config: .stderr).asLayer())           // request logging
    .layer(CorsLayer().asLayer())                           // CORS headers
    .layer(TimeoutLayer(duration: .seconds(30)).asLayer())  // → 504 on timeout
    .layer(RateLimitLayer(limiter: RateLimiter(maxRequests: 100)).asLayer())  // → 429
    .service(innerService)   // innerService: Service<HTTP.Request, HTTP.Response>
```

> In [`starlight`](https://github.com/akvilary/starlight) the same layers are
> applied directly on a `Router` via `.layer(...)` / `.route_layer(...)` — the
> `Router` itself is a `Service`, so this is the same composition, one level up.

### `from_fn` — write middleware inline

The `axum::middleware::from_fn` shape: an async closure receives the request and
a `Next` handle to call the rest of the chain:

```swift
let trace = from_fn { request, next in
    print("→ \(request.uri.pathString)")
    let response = try await next.run(request)
    print("← \(response.status)")
    return response
}

app.layer(trace)
```

## Contents

```
Sources/
├── CLens/              C wrapper around zlib (deflate/inflate)
│   ├── include/
│   └── wrapper.c
└── HTTPLens/
    ├── Compression.swift   CompressionLayer (gzip)
    ├── Cors.swift          CorsLayer
    ├── from_fn.swift       axum::middleware::from_fn + Next
    ├── RateLimit.swift     RateLimitLayer + RateLimiter
    ├── Timeout.swift       TimeoutLayer
    └── Trace.swift         TraceLayer
```

## Why a separate package?

The same split as Rust: tower-http is its own crate so middleware is reusable
across any `tower::Service`-based framework, independent of the router and
server. Keeping the layers here (rather than inside `starlight`) means a future
non-axum framework built on `http-prism` can use the same gzip/CORS/trace
middleware verbatim.

## License

MIT — see [LICENSE](LICENSE).
