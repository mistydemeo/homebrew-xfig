class Xfig < Formula
  homepage "http://www.xfig.org"
  url "http://downloads.sourceforge.net/mcj/xfig-3.2.7.tar.xz"
  version "3.2.7"
  sha256 "5fe81ce4132b139667fbfaacdf04a026f0313a34d39c7f640024db894cced42a"

  depends_on "fig2dev"
  depends_on "ghostscript"
  depends_on "jpeg"
  depends_on :x11 => "2.7.2"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    assert_match "Xfig #{version}", shell_output("#{bin}/xfig -v 2>&1")
  end
end
