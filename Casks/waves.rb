cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.2.8"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "05ae8f0cb051b3e160950dde9eed7daabf6da83645aa55505e43c33eee0ed1e9",
           intel: "8c9339951a28624ae0220a0f135dcc88f51fd0aacd4f1e489eeee280bcd16a5b"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "233d7f011c121779c23bd4b58e192185663de9ce1689546240128fe51f3c0757",
           intel: "68434af370ff916c5a8b16aacc95fdd1107121deec58184128fb47033639e781"

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
