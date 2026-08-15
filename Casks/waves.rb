cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.21"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "64e73cf08c66b76c827facd6b1c76cceb24d4bdb63b2358abb7176601f2d5378",
           intel: "052dba7384b28b8081ba71d6556ec74057e6b30fa02e6bf3c5d04a0ad7798d83"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "5efe362b8e2ee1b3f41de4ca09b2ea7ba13733a3911b732f5dc1f16aeaf8ff12",
           intel: "db47250f3fe2ba44fbc574cfa7326f861e51f8759877c045415ad8c63766d9d1"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}_legacy.zip"
  end

  name "Waves"
  desc "Native desktop app for downloading music from your own TIDAL account"
  homepage "https://github.com/iamprivacy/Waves"

  # The legacy bundle runs on macOS 12 Monterey and newer; refuse cleanly
  # below that instead of installing an app that cannot launch.
  depends_on macos: ">= :monterey"

  app "waves.app"

  postflight do
    # The builds are not yet notarized; clear quarantine so the first launch
    # is not blocked by Gatekeeper (see the tap README).
    system_command "/usr/bin/xattr", args: ["-cr", "#{appdir}/waves.app"]
    # Tell the app this copy is Homebrew-managed: its in-app updater then
    # defers to `brew upgrade` instead of writing over the install.
    config_dir = File.expand_path("~/Library/Application Support/Waves")
    FileUtils.mkdir_p(config_dir)
    File.write(File.join(config_dir, "install_channel"), "homebrew-cask\n")
  end

  uninstall_postflight do
    FileUtils.rm_f(File.expand_path("~/Library/Application Support/Waves/install_channel"))
  end

  zap trash: [
    "~/Library/Application Support/Waves",
    "~/.config/Waves",
  ]
end
