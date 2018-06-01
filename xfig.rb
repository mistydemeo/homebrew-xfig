class Xfig < Formula
  desc "Interactive drawing tool for X"
  homepage "https://mcj.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcj/xfig-3.2.7a.tar.xz"
  sha256 "ca89986fc9ddb9f3c5a4f6f70e5423f98e2f33f5528a9d577fb05bbcc07ddf24"

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
