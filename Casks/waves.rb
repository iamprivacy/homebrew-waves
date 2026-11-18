cask "waves" do
  arch arm: "apple-silicon", intel: "intel"

  version "0.2.7"

  # Two macOS flavors from v0.1.16 on (issue #14: the bundled Qt's newer
  # releases require macOS 15): machines on Sequoia and newer get the regular
  # bundle, and Monterey through Sonoma get a legacy bundle built on the last
  # Qt that still runs there. Homebrew picks the block at install time. The
  # release workflow bumps version and all four sha256s; keep the two block
  # openers at this exact two-space indent and the "arm:   " / "intel: "
  # spacing, its seds are anchored to them.
  on_sequoia :or_newer do
    sha256 arm:   "baadc8619c677d4b4e704c1a67419afc25e251ac8c730b24f6ef666b421bf6b7",
           intel: "0d42dcbc3dc2ade9c8abca7215d55302bb6aa83ff76f85ad13ed85f3b8ed0284"

    url "https://github.com/iamprivacy/Waves/releases/download/v#{version}/waves_macos-#{arch}.zip"
  end
  on_sonoma :or_older do
    # Placeholder until the first dual release publishes the legacy assets.
    sha256 arm:   "c152aa239dc41b3f5db465bcb8f70c2bbc45f939bc8d40e3eba8c13957bb0272",
           intel: "cb1f1494c9c5a315b4b67c99f15e177e4b687c5150bd035ed4b959b0634ba7c8"

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
