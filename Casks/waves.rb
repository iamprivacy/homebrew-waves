cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.2.1"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "3b70eaae3ac5f54d375d9d054b43c89c2315ddbbeba43311da8164ee49741cc0",
           intel: "b84a0779c55f39f0eaf1974fc59c094185e4aecaa873ca0edc6b001d6bc4d1d9"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "1839cdb6603e27dc67194ad8d2732ec8ad6640dfb4b27253ac29d9dcca3c463b",
           intel: "6630b07b1392ba91347b56700b5d416cad9c613df4ae27137bd3cedb9b98a2ad"

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
    system_command "/usr/bin/xattr", args: ["-cr", "#{appdir}/waves.app"]
    # Tell the app this copy is Homebrew-managed: its in-app updater then
    # defers to `brew upgrade` instead of writing over the install.
    config_dir = File.expand_path("~/Library/Application Support/Waves")
    FileUtils.mkdir_p(config_dir)
    File.write(File.join(config_dir, "install_channel"), "homebrew-cask\n")
  end

  uninstall_postflight_steps do
    remove "Library/Application Support/Waves/install_channel", base: :home
  end

  zap trash: [
    "~/Library/Application Support/Waves",
    "~/.config/Waves",
  ]
end
