cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.2.9"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "b001095808e1f01b45daf53bdf54388d48e7e0afa5a516b59fc31777b1c1ea84",
           intel: "fe7310b5921d9eeea5b1bceec0661e5c3a54eed6a8968dc072ca69ba78d29f2e"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "36123fcdc4d1bf7d5b60cd21ec7c0ddcf7682433a91559f13106b6c21bcd57cb",
           intel: "d81e6bb4702dcec590f9b2a32b1c55b4bb3409821112435c40e3b3526b2f4a7a"

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
