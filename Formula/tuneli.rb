class Tuneli < Formula
  desc "macOS menu-bar utility that manages SSH tunnels from ~/.ssh/config"
  homepage "https://github.com/jmpanozzoz/tuneli-macos"
  url "https://github.com/jmpanozzoz/tuneli-macos/releases/download/v1.1.1/tuneli-v1.1.1-macos-arm64.tar.gz"
  sha256 "80f32e1680e109bcb1948c221861c63d45dea3a226c3c9b7f11068261119fe29"
  license "MIT"

  def install
    prefix.install "tuneli.app"
  end

  def caveats
    <<~EOS
      tuneli was installed to #{prefix}/tuneli.app.

      To run it, symlink the bundle into ~/Applications so LaunchServices
      picks it up:

        ln -sf #{prefix}/tuneli.app ~/Applications/tuneli.app

      Or just open it once to register it with LaunchServices:

        open #{prefix}/tuneli.app

      The menu bar should show a plug icon within ~2 seconds.

      Your existing state at ~/.tuneli/state.json (if any) is preserved —
      brew install doesn't touch it.
    EOS
  end

  test do
    assert_predicate prefix/"tuneli.app/Contents/MacOS/tuneli", :executable?
    assert_predicate prefix/"tuneli.app/Contents/Info.plist", :exist?
    assert_match "tuneli", File.read(prefix/"tuneli.app/Contents/Info.plist")
  end
end