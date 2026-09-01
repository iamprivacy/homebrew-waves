cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.26"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "fdc2ec2b9ca03a02d63507c10c198cdf67165e07b0e2a7578284d1cd101ca056",
           intel: "5ba0fde39ffd46189072dee07fdc018663fb20847d529611e25939daa002839e"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "c078e72a77361b6b6698bae656770019756b448357ed04174322f05f36da3e08",
           intel: "13c44b4e72d3cbdb800535e85a4d5dfcf81a55df77278af3e32645e786b6c63c"

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
