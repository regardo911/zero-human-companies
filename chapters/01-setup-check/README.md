# Chapter 1: check your machine

The reader setup check from chapter 1, as a script. It adds jq (chapters 8, 10 and 11) and bc (chapter 11), which the printed check leaves out.

```bash
./chapters/01-setup-check/check-prereqs.sh
```

On the machine this repo was built on:

```
required
  node     v26.5.0
  python3  Python 3.15.2
  curl     curl 8.7.1 (x86_64-apple-darwin25.0) libcurl/8.7.1 (SecureTransport) LibreSSL/3.3.6 zlib/1.2.12 nghttp2/1.68.1
  git      git version 2.50.1 (Apple Git-155)
  jq       jq-1.7.1-apple
  bc       bc 7.0.3

later chapters (information only)
  hermes   missing  chapter 4 installs it
  docker   missing  optional, chapter 9 (external Postgres)
  ollama   ollama 0.33.2

all six required tools found. next: chapter 4 installs Hermes.
```

Done when it exits 0, which means the six tools exist; it doesn't compare version numbers. A `missing` line comes with the command that installs it; run that and check again. The `hermes` line turns into a version after chapter 4.

Your five decisions from the same section (business model, budget, provider, OS, Docker) still go on paper. Nothing to run there.
