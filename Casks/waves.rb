cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.2.5"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "7b61c59d6c8faba475604a3000c0d25153eaadb83b7cc301bca7a97ecbb6d53a",
           intel: "bd9de391d4acf0361d277c17db7a872b8d147bf4c07b7c8c7741c6c422d31af6"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "822622716d9de88c64c0667565aaeafb9d3f8721523ad97533e4133f15749806",
           intel: "d150ada53735a09acc6ee8bb682cbc27305b4d1a7040548ff460729549c36483"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}_legacy.zip"
  end

  name "Waves"
  desc "Native desktop app for downloading music from your own TIDAL account"
  homepage "https://github.com/iamprivacy/Waves"

  # The legacy bundle runs on macOS 12 Monterey and newer; refuse cleanly
  # below that instead of installing an app that cannot launch.
  depends_on macos: :monterey

  app "waves.app"

  postflight_steps do
    # The builds are not yet notarized; clear quarantine so the first launch
    # is not blocked by Gatekeeper (see the tap README).
    run "/usr/bin/xattr", args: ["-cr", "{{appdir}}/waves.app"], must_succeed: false
    # Tell the app this copy is Homebrew-managed: its in-app updater then
    # defers to `brew upgrade` instead of writing over the install. The
    # folder is created first because the steps sandbox only lets a written
    # file's own folder be written.
    mkdir_p "Library/Application Support/Waves", base: :home
    write_file "Library/Application Support/Waves/install_channel", "homebrew-cask\n", base: :home
  end

  uninstall_postflight_steps do
    remove "Library/Application Support/Waves/install_channel", base: :home, content_contains: "homebrew-cask"
  end

  zap trash: [
    "~/Library/Application Support/Waves",
    "~/.config/Waves",
  ]
end
