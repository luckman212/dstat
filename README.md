<img src="./icon.png" width="128">

# dstat

This is a small Objective-C program that reports the current sleeping/awake status of the screen or locked/unlocked status of the login session. It's self-contained Universal Binary that runs on Apple Silicon and Intel-based Macs.

It requires a single argument (`-s`/`--sleep`, or `-l`/`--lock`) to select which detail to query. The program does not produce any output, instead it returns an exit code to indicate the status. This makes it well-suited for integration with shell scripts.

The meaning of the exit codes are as follows:

|exit code|meaning|
|:---:|:---|
|0|display is sleeping or locked|
|1|display is NOT sleeping or locked|
|2|invalid commandline argument|
|3|error querying display status|
|4|no login session (cannot operate in this condition)|

### Install

1. Download the latest [release](https://github.com/luckman212/dstat/releases)
2. Unzip `dstat.zip` and copy the `dstat` program to a directory in your `$PATH` — if you're unsure, `/usr/local/bin` is a solid choice.
3. Execute `dstat <arg>` from your shell or scripting environment (bash, zsh, etc)

### Usage

Show help:
```bash
dstat -h
```

Example #1
```bash
dstat --lock 2>/dev/null
case $? in
  0) echo "screen is locked";;
  1) echo "screen is unlocked";;
  *) echo "something went pear shaped";;
esac
```

Example #2
```bash
dstat -l && echo "screen is locked"
```

Example #3
```bash
if dstat --sleep; then
  # display is sleeping
  say "time for bed"
fi
```

### Caveats

The tool uses APIs that interact with the active login session. Thus, it cannot function if there's nobody logged in to the system. An error code of `4` is returned in that scenario, so it can at least be detected by your script. If anyone knows of a way to query for the sleep status of the display while in a logged out state, please file a PR! :pray:

Please report any bugs or issues you encounter. This idea was inspired by [this AskDifferent post][1], and is a somewhat more efficient followup to an earlier solution I came up with: [display-is-sleeping][2].

[1]: https://apple.stackexchange.com/questions/466236/check-if-display-sleep-on-apple-silicon-in-bash
[2]: https://github.com/luckman212/display-is-sleeping
