# Homebrew formula for backup-gate. The release workflow fills in 3.2.0 and 7f6ec10c8ae0c4c29ac5a46e3c2701607bd92cb4ef4e2ca9ba829b29231ecaea and
# attaches the result to the GitHub release; copy it to Formula/ in mermoddity/homebrew-backup-gate.
class BackupGate < Formula
  desc "Time Machine backups that pause when macOS persistence points change"
  homepage "https://github.com/mermoddity/backup-gate"
  url "https://github.com/mermoddity/backup-gate/releases/download/v3.2.0/backup-gate-3.2.0.tar.gz"
  sha256 "7f6ec10c8ae0c4c29ac5a46e3c2701607bd92cb4ef4e2ca9ba829b29231ecaea"
  license "MIT"

  # Intel Homebrew owns /usr/local/sbin, and the gate refuses to run from a folder the user can write to.
  depends_on arch: :arm64
  depends_on :macos

  # Nothing is linked into Homebrew's bin on purpose: Homebrew's folders are writable by your
  # user account, so the gate must never run from here as root day to day. install.sh copies
  # it to the root-owned /usr/local/sbin, and that copy is the one that runs. install.sh itself
  # does run from here, as root, when you install or upgrade: like any installer.
  def install
    libexec.install "backup-gate", "install.sh", "uninstall.sh", "config.example", "local.backup-gate.plist"
  end

  def caveats
    <<~EOS
      backup-gate runs as root, so Homebrew only downloads it. To install or upgrade
      (after every `brew upgrade backup-gate` you ran yourself), run:
        #{opt_libexec}/install.sh --check
        sudo #{opt_libexec}/install.sh

      Then use the installed copy, not this one:
        sudo /usr/local/sbin/backup-gate approve

      To remove it, run this before `brew uninstall backup-gate`:
        sudo #{opt_libexec}/uninstall.sh
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{libexec}/backup-gate version")
  end
end
