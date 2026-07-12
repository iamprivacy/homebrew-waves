cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.1.6"
  sha256 arm:   "f10dab19ee7967852bf5485a2e60594d6bde262d31d6713dbd72053783cb425a",
         intel: "006f39cbe93dd25251c02ef71b192ecf0c87c2422ee01642f3cb175a9fb1fc17"

  url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  name "Waves"
  desc "Native desktop app for downloading music from your own TIDAL account"
  homepage "https://github.com/iamprivacy/Waves"

  app "waves.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-cr", "#{appdir}/waves.app"]
  end

  zap trash: [
    "~/.config/Waves",
  ]
end
