# omc, the Omega compiler, born from the 408-byte hand-written seed of aien-dev/omega-mv.
# The build runs omega-mv's seed/omega-from-seed.sh (seed0 -> hex1 -> asm2 -> om4 -> omc -> omc -> omc)
# using only sh, printf, cat, stat, sed, sha256sum and cmp, then refuses any omc whose sha256 is not
# the pinned one. AArch64 (arm64) Linux only: omc runs on and emits code for that platform alone.
class Omc < Formula
  desc "Omega compiler, born from a 408-byte hand-written seed"
  homepage "https://github.com/aien-dev/omega-mv"
  url "https://github.com/aien-dev/omega-mv/archive/e5b32567a7aff3ce594e3254a622a846a6cd190b.tar.gz"
  version "0.0.0+git.e5b32567"
  sha256 "c621b6cefe728d67a1a253a9d8991495406460d365dd91ea356451eb2254a95c"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :linux

  OMC_SHA256 = "2c82480596bbdc50cda9626866209ef662d5834f278f839ff4ce0250c495029f".freeze

  def install
    system "sh", "seed/omega-from-seed.sh"
    got = Digest::SHA256.file("seed/out/omc").hexdigest
    odie "omc sha256 #{got} is not the pinned #{OMC_SHA256}" if got != OMC_SHA256
    bin.install "seed/out/omc"
  end

  test do
    (testpath/"hello.om").write <<~OM
      note hello: sum 1..10 and print "omega 55" through write
      global out uchar 16
      fn main to int
      s = ulong 0
      for i ulong 11
      s = add s i
      end
      put out 0 111
      put out 1 109
      put out 2 101
      put out 3 103
      put out 4 97
      put out 5 32
      put out 6 uchar add div s 10 48
      put out 7 uchar add rem s 10 48
      put out 8 10
      w = write 1 out 0 9
      ret 0
      end
    OM
    system "sh", "-c", "#{bin}/omc < hello.om > hello"
    chmod 0755, testpath/"hello"
    assert_equal "omega 55\n", shell_output("./hello")
    assert_equal OMC_SHA256, Digest::SHA256.file(bin/"omc").hexdigest
  end
end
