class Xfig < Formula
  desc "Interactive drawing tool for X"
  homepage "https://mcj.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcj/xfig-3.2.8a.tar.xz"
  sha256 "ba43c0ea85b230d3efa5a951a3239e206d0b033d044c590a56208f875f888578"

  depends_on "fig2dev"
  depends_on "ghostscript"
  depends_on "jpeg"
  depends_on "libxaw3d"

  def install
    # Inexplicably fails to link against JPEG while building its jpeg library
    # Makefile bug? Who knows
    ENV.append "LDFLAGS", "-ljpeg"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make", "install"
  end

  test do
    assert_match "Xfig #{version}", shell_output("#{bin}/xfig -v 2>&1")
  end
end
