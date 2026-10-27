# homebrew-omega

My Homebrew tap for `omc`, the Omega compiler. The formula does not download a binary. It downloads
the omega-mv source at a pinned commit and **births `omc` from a 408-byte hand-written seed**
(`seed0 → hex1 → asm2 → om4 → omc → omc → omc`) with nothing but `sh`, `printf`, `cat`, `stat`, `sed`,
`sha256sum` and `cmp`. Then it refuses to install unless the result's sha256 is exactly
`2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f` (325524 bytes).

```sh
brew install --build-from-source aien-dev/omega/omc
brew test omc
```

**Honest limits.** This works on **Homebrew on Linux, arm64** only. `omc` runs on and emits code for
AArch64 Linux; there is no macOS build, and the formula says so (`depends_on :linux`,
`depends_on arch: :arm64`) instead of failing halfway. The version `0.0.0+git.e5b32567` means "the
compiler at omega-mv commit `e5b32567`"; omega-mv has not tagged a release yet.

Try it:

```sh
curl -fsSLO https://raw.githubusercontent.com/aien-dev/omega-packages/main/examples/hello.om
omc < hello.om > hello && chmod +x hello && ./hello     # omega 55
```

[CI](.github/workflows/ci.yml) installs Homebrew on GitHub's `ubuntu-24.04-arm` runner, runs exactly the
two commands above, and runs a negative control: a copy of the formula with a wrong pinned hash must fail
to install.

## Connected repos

- Parent: [aien-dev/omega-mv](https://github.com/aien-dev/omega-mv), pinned at `e5b32567a7aff3ce594e3254a622a846a6cd190b`.
- [aien-dev/omega-packages](https://github.com/aien-dev/omega-packages): the same build for Nix, Guix, AUR, `.deb` and a container image, with attested releases.

## Foreign dependencies

Packaging glue, not part of Omega; none of it writes a byte of `omc`.

| dependency | version | what it does here |
| --- | --- | --- |
| Homebrew | current `Homebrew/install` (CI) | downloads and checks the source archive, installs into the prefix |
| POSIX sh, printf, cat, stat, sed, sha256sum, cmp | host's (GNU coreutils) | run the seed chain |
| Ruby (Homebrew's portable Ruby) | Homebrew's | evaluates the formula and the sha256 check |

## License

Apache-2.0 WITH LLVM-exception (see `LICENSE`). omega-mv itself is Apache-2.0.
