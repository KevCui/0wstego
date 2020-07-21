# 0wstego ![CI](https://github.com/KevCui/0wstego/workflows/CI/badge.svg)

0wstego \ō-ste-gə\ is a script using zero-width characters to hide secret message inside normal message. It's also capable to reveal secret message encoded by itself for sure :simple_smile:.

## How to use

```
Usage:
  ./0wstega.sh [-d|-f <file_path>]

Options:
                   Without any parameters, encode message
  -d               Decode message
  -f <file_path>   Decode message in file
  -h | --help      Display this help message
```

- Encode message, recommend piping output text to clipboard directly using `xclip` or `pbcopy`:

```
~$ ./0wstego.sh | xclip -selection clipboard
Visible message: this is a visible sentence.
Secret message to hide: secret message
```

- Decode message from prompt:

```
~$ ./0wstego.sh -d
Paste encoded message here: <paste>
```

- Decode message from file:

```
~$ ./0wstego.sh -f ~/secret.md
```

## Run tests

```
~$ bats test/0wstego.bats
```

## Related project

0wstego is heavily inspired by [zero-width-detection](https://github.com/umpox/zero-width-detection).
