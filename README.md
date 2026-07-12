# homebrew-waves

Homebrew tap for [Waves](https://github.com/iamprivacy/Waves), a native desktop
app for downloading music from your own TIDAL account.

## Install

```
brew tap iamprivacy/waves
brew install --cask waves
```

## Update

```
brew upgrade --cask waves
```

A copy installed through this tap knows it is Homebrew-managed: when a new
version is out, the in-app Update & restart button runs the command above
for you (same one click as any other install) instead of downloading over
the Homebrew copy, so Homebrew's own records stay correct. Third-party
updater tools that track Homebrew or GitHub releases work as usual.

## Note on Gatekeeper

Waves builds are not yet Apple-notarized. This cask clears the quarantine
attribute on install (`xattr -cr`) so macOS does not block the first launch
with an unremovable warning. You are installing an unsigned build; see the
[Waves README](https://github.com/iamprivacy/Waves#readme) if you would
rather verify it yourself first.

This tap only ever points at binaries already published on the
[Waves Releases page](https://github.com/iamprivacy/Waves/releases); it does
not build or host anything itself.
