cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.10"
  sha256 arm:   "e3887601e052b34aeb0ba7dd16c68c018f2248c66e7267a7dcebcf3631d4064f",
         intel: "6752f0da0f92ae21467e97b7658e24affc74969005e2da3ee2ca760b75ff40bc"

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
