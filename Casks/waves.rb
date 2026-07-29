cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.13"
  sha256 arm:   "afc6c2cbfd410eab10d439aa4c7bcd183e933660be416e329d09809ebe3f446a",
         intel: "dbd8355e3040f1e6a8a5e390774a9796a5b938b54159fcf0ade3d0e58e5421d1"

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
