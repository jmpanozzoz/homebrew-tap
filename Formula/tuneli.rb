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
    # Brew installs to /opt/homebrew/Cellar/tuneli/<version>/ by default.
    # Symlink the bundle into ~/Applications so LaunchServices registers
    # it and the user can launch from Finder/Spotlight.
    STDERR.puts "[tuneli post_install] starting, prefix=#{prefix}"
    STDERR.flush
    target = Pathname.new(File.expand_path("~/Applications/tuneli.app"))
    source = prefix/"tuneli.app"
    STDERR.puts "[tuneli post_install] source.exists?=#{source.exist?}, target=#{target}"
    STDERR.flush
    odie "tuneli.app missing at #{source}" unless source.exist?
    FileUtils.rm_rf(target)
    FileUtils.ln_s(source, target)
    ohai "Linked #{target} -> #{source}"
  rescue => e
    STDERR.puts "[tuneli post_install] ERROR: #{e.class}: #{e.message}"
    STDERR.puts e.backtrace.first(20).join("\n")
    STDERR.flush
    raise
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