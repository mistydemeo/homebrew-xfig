require 'formula'

class Transfig < Formula
  homepage 'http://www.xfig.org'
  url 'http://downloads.sourceforge.net/mcj/transfig.3.2.5e.tar.gz'
  version '3.2.5e'
  sha1 '27aa9691bf84f8775db9be39c453a8132148bad1'

  depends_on 'imake' => :build
  depends_on 'jpeg'
  depends_on 'ghostscript'
  depends_on :x11 => '2.7.2'

  fails_with :clang do
    cause "clang fails to process xfig's imake rules"
  end

  def install
    # transfig does not like to execute makefiles in parallel
    ENV.deparallelize

    # Patch tranfig/Imakefile
    inreplace "transfig/Imakefile", "XCOMM BINDIR = /usr/bin/X11",
              "BINDIR = #{bin}\n"+     # set install dir for bin
              "USRLIBDIR = #{lib}\n"  # set install dir for lib
    inreplace "transfig/Imakefile", "XCOMM MANDIR = $(MANSOURCEPATH)$(MANSUFFIX)",
              "MANDIR = #{man}$(MANSUFFIX)"
    inreplace "transfig/Imakefile", "XCOMM USELATEX2E = -DLATEX2E",
              "USELATEX2E = -DLATEX2E"

    # Patch fig2dev/Imakefile
    inreplace "fig2dev/Imakefile", "XCOMM BINDIR = /usr/bin/X11",
              "BINDIR = #{bin}\n"+     # set install dir for bin
              "USRLIBDIR = #{lib}\n"  # set install dir for lib
    inreplace "fig2dev/Imakefile", "XCOMM MANDIR = $(MANSOURCEPATH)$(MANSUFFIX)",
              "MANDIR = #{man}$(MANSUFFIX)"
    inreplace "fig2dev/Imakefile", "XFIGLIBDIR =	/usr/local/lib/X11/xfig",
              "XFIGLIBDIR = #{share}"
    inreplace "fig2dev/Imakefile","XCOMM USEINLINE = -DUSE_INLINE",
              "USEINLINE = -DUSE_INLINE"
    inreplace "fig2dev/Imakefile", "RGB = $(LIBDIR)/rgb.txt", "RGB = #{MacOS::X11.share}/X11/rgb.txt"
    inreplace "fig2dev/Imakefile", "PNGINC = -I/usr/include/X11","PNGINC = -I#{MacOS::X11.include}"
    inreplace "fig2dev/Imakefile", "PNGLIBDIR = $(USRLIBDIR)","PNGLIBDIR = #{MacOS::X11.lib}"
    inreplace "fig2dev/Imakefile", "ZLIBDIR = $(USRLIBDIR)", "ZLIBDIR = /usr/lib"
    inreplace "fig2dev/Imakefile", "XPMLIBDIR = $(USRLIBDIR)", "XPMLIBDIR = #{MacOS::X11.lib}"
    inreplace "fig2dev/Imakefile", "XPMINC = -I/usr/include/X11", "XPMINC = -I#{MacOS::X11.include}/X11"
    inreplace "fig2dev/Imakefile", "XCOMM DDA4 = -DA4", "DDA4 = -DA4"
    inreplace "fig2dev/Imakefile", "FIG2DEV_LIBDIR = /usr/local/lib/fig2dev",
              "FIG2DEV_LIBDIR = #{lib}/fig2dev"

    # Patch fig2dev/dev/genibmgl.c
    inreplace "fig2dev/dev/genibmgl.c", "static set_width(w)", "static void set_width(w)"

    # generate Makefiles
    system "make clean"
    system "xmkmf"
    system "make Makefiles"

    # build everything
    system "make"

    # install everything
    system "make install"
    system "make install.man"
  end
end
