cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.9"
  sha256 arm:   "fdaa2fd1950ad4dbd4db728c08d8043d4160bf45f1f7526bcdadc5778e71da7e",
         intel: "415c63e56686b19c9990da5a933ae3da433a766adf45dcf0e3909d4190d42bef"

  url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  name "Waves"
  desc "Native desktop app for downloading music from your own TIDAL account"
  homepage "https://github.com/iamprivacy/Waves"

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
