class Tuneli < Formula
  desc "macOS menu-bar utility that manages SSH tunnels from ~/.ssh/config"
  homepage "https://github.com/jmpanozzoz/tuneli-macos"
  url "https://github.com/jmpanozzoz/tuneli-macos/releases/download/v1.1.1/tuneli-v1.1.1-macos-arm64.tar.gz"
  sha256 "80f32e1680e109bcb1948c221861c63d45dea3a226c3c9b7f11068261119fe29"
  license "MIT"

  def install
    # Homebrew's "tarball with single root dir" handling moves the
    # extracted tuneli.app/ directory INTO a buildpath that is itself
    # named tuneli.app. So cwd when install runs is buildpath, and its
    # direct children are Contents/, MacOS/, Resources/ (the bundle
    # internals). We need to create prefix/tuneli.app/ and install all
    # top-level entries of cwd into it.
    odie "Expected tuneli.app internals (Contents/, MacOS/) in buildpath" \
      unless (buildpath/"Contents").exist? && (buildpath/"MacOS").exist?
    prefix.mkdir
    (prefix/"tuneli.app").install Dir["*"]
  end

  def post_install
    # Brew installs to /opt/homebrew/Cellar/tuneli/1.1.1 by default. Symlink
    # the bundle into ~/Applications so LaunchServices registers it and
    # the user can launch from Finder/Spotlight.
    target = Pathname.new(File.expand_path("~/Applications/tuneli.app"))
    source = prefix/"tuneli.app"
    FileUtils.rm_rf(target)
    FileUtils.ln_s(source, target)
    # Trigger LaunchServices registration.
    system_command "/usr/bin/open", args: [source]
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