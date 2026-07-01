class Tuneli < Formula
  desc "macOS menu-bar utility that manages SSH tunnels from ~/.ssh/config"
  homepage "https://github.com/jmpanozzoz/tuneli-macos"
  url "https://github.com/jmpanozzoz/tuneli-macos/releases/download/v1.1.0/tuneli-v1.1.0-macos-arm64.tar.gz"
  sha256 "PLACEHOLDER_FILL_AFTER_RELEASE"
  license "MIT"

  depends_on macos: ">= :sonoma"

  def install
    prefix.install "tuneli.app"
  end

  def caveats
    <<~EOS
      tuneli was installed to #{prefix}/tuneli.app.

      To run it, link the bundle into ~/Applications so LaunchServices
      picks it up:

        ln -sf #{prefix}/tuneli.app ~/Applications/tuneli.app

      Or open it once to register with LaunchServices:

        open #{prefix}/tuneli.app

      The menu bar should show a plug icon within ~2 seconds.
    EOS
  end

  test do
    assert_predicate prefix/"tuneli.app/Contents/MacOS/tuneli", :executable?
    assert_predicate prefix/"tuneli.app/Contents/Info.plist", :exist?
    assert_match "tuneli", File.read(prefix/"tuneli.app/Contents/Info.plist")
  end
end