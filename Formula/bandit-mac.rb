class BanditMac < Formula
  desc "Switches the Bandit dongle's gesture profile with the app in front"
  homepage "https://github.com/Shlok-Bhakta/homebrew-bandit"
  url "https://github.com/Shlok-Bhakta/homebrew-bandit/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "2c44d1eecd7fb9746af45a39df81ee0e678c5bbb39a0464b4e66b083b7701b4c"
  license "MIT"
  head "https://github.com/Shlok-Bhakta/homebrew-bandit.git", branch: "main"

  depends_on :macos

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/bandit-mac"
  end

  service do
    run [opt_bin/"bandit-mac"]
    keep_alive true
    process_type :interactive
    log_path var/"log/bandit-mac.log"
    error_log_path var/"log/bandit-mac.log"
  end

  def caveats
    <<~EOS
      Start it now and at every login:
        brew services start bandit-mac
      macOS asks once to let bandit-mac use Bluetooth: allow it.
      Profiles pick apps by bundle id ("apps" in the dongle's profile file); `bandit-mac front`
      prints the front app's.
      To buzz the band when GitHub Copilot finishes, asks something or fails:
        bandit-mac copilot install
      Coming from np-appwatch? That also removes its Copilot hooks.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bandit-mac --version")
  end
end
