class Tuneli < Formula
  desc "macOS menu-bar utility that manages SSH tunnels from ~/.ssh/config"
  homepage "https://github.com/jmpanozzoz/tuneli-macos"
  url "https://github.com/jmpanozzoz/tuneli-macos/releases/download/v1.1.1/tuneli-v1.1.1-macos-arm64.tar.gz"
  sha256 "80f32e1680e109bcb1948c221861c63d45dea3a226c3c9b7f11068261119fe29"
  license "MIT"

  def install
    # Homebrew's tarball-with-single-root-dir handling strips out the
    # Contents/, MacOS/, Resources/, Info.plist from buildpath, leaving
    # just the empty tuneli.app/ wrapper. To work around that, extract
    # the tarball ourselves into the keg.
    tarball_dir = cached_download
    odie "Tarball not found at #{tarball_dir}" unless tarball_dir.exist?
    system "tar", "-xzf", tarball_dir.to_s, "-C", buildpath.to_s
    # buildpath/tuneli.app/ should now contain Contents/, MacOS/, etc.
    (prefix/"tuneli.app").install Dir.children(buildpath/"tuneli.app")
  end

  def post_install
    # We intentionally do NOT symlink into ~/Applications here: brew's
    # post_install runs in a sandbox where ~ is a tmpdir, not the real
    # home, so any symlink into a real-user path would fail with ENOENT.
    # The user runs the one-line command from `caveats` to do the
    # symlink themselves; this is the standard pattern for macOS .app
    # bundles installed via brew formulae.
    ohai "tuneli installed to #{prefix}/tuneli.app"
    ohai "Run the command from the caveats block to symlink it into ~/Applications"
  end

  def caveats
    <<~EOS
      tuneli was installed to #{prefix}/tuneli.app.

      To run it, symlink the bundle into ~/Applications so LaunchServices
      picks it up:

        ln -sf #{prefix}/tuneli.app ~/Applications/tuneli.app

      Or just open it directly:

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