class Xfig < Formula
  homepage "http://www.xfig.org"
  url "http://downloads.sourceforge.net/mcj/xfig.3.2.5c.full.tar.gz"
  version "3.2.5c"
  sha256 "ea628f975b79ab175ab29220cc118274466497f6217f2989928317be2993a1f9"

  depends_on "imake" => :build
  depends_on "transfig"
  depends_on "jpeg"
  depends_on "ghostscript"
  depends_on :x11 => "2.7.2"

  fails_with :clang do
    cause "clang fails to process xfig's imake rules"
  end

  def patches
    # Patches adapted from Macports, to:
    # * Define srandom() correctly on Darwin
    # * Fix incorrect return types on several functions
    # * Ensure that REG_NOERROR is defined in w_keyboard.c
    DATA
  end

  def install
    # Patch file attributs of Library directory
    system "chmod u+x Libraries"
    # Patch file attributes for xfig-title.png
    system "chmod u+r Doc/html/images/xfig-title.png"

    # Patch Imakefile to setup installation and library paths
    inreplace "Imakefile", "XCOMM BINDIR = /usr/bin",
              "BINDIR = #{bin}\n"     # set install dir for bin
    inreplace "Imakefile", "XCOMM XAPPLOADDIR = /home/user/xfig",
              "XAPPLOADDIR = #{lib}/X11/app-defaults\n"+
              "CONFDIR = #{lib}/X11"
    inreplace "Imakefile", "PNGLIBDIR = $(USRLIBDIR)","PNGLIBDIR = #{MacOS::X11.lib}"
    inreplace "Imakefile", "ZLIBDIR = $(USRLIBDIR)", "ZLIBDIR = /usr/lib"
    inreplace "Imakefile", "JPEGLIBDIR = /usr/local/lib", "JPEGLIBDIR = #{HOMEBREW_PREFIX}/lib"
    inreplace "Imakefile", "JPEGINC = -I/usr/include/X11", "JPEGINC = -I#{HOMEBREW_PREFIX}/include"
    inreplace "Imakefile", "XPMLIBDIR = /usr/local/lib", "XPMLIBDIR = #{MacOS::X11.lib}"
    inreplace "Imakefile", "XFIGLIBDIR = $(LIBDIR)/xfig", "XFIGLIBDIR = #{lib}/X11/xfig"
    inreplace "Imakefile", "XFIGDOCDIR = /usr/local/xfig/doc", "XFIGDOCDIR = #{share}/doc/xfig"
    inreplace "Imakefile", "MANDIR = $(MANSOURCEPATH)$(MANSUFFIX)",
              "MANDIR = #{man}$(MANSUFFIX)"

    # make sure that app-defaults directory exists in #{HOMEBREW_PREFIX}/lib/X11
    mkpath "#{HOMEBREW_PREFIX}/lib/X11/app-defaults"

    # build make files
    system "xmkmf"
    system "make clean"

    # w_fontpanel.o must be build without optimization with gcc 4.2
    # see http://old.nabble.com/Fwd%3A-xfig-font-problem-td28885362.html
    if ENV.compiler == :gcc
      system "make CDEBUGFLAGS=-O0 w_fontpanel.o"
    end

    # Makefile still tries to access X11 includes under /usr/include
    inreplace "Makefile", "/usr/include/X11", MacOS::X11.include
    # build xfig
    system "make"

    # patch Makefile to avoid building symlink /usr/local/X11/app-defaults
    inreplace "Makefile", "	  $(LN) $${RELPATH}$(CONFDIR)/app-defaults .;", "	  "

    # install xfig
    system "make install.all"
    system "make install.man"

    # generate launch script to point environment variable XAPPLRESDIR to the app_defaults file for xfig
    mv "#{bin}/xfig",  "#{bin}/../xfig.bin"
    File.open("#{bin}/xfig","w") {|f| f.write("#!/bin/sh\n"+
                                              "export XAPPLRESDIR=#{HOMEBREW_PREFIX}/lib/X11/app-defaults\n"+
                                              "#{bin}/../xfig.bin\n")}
    system "chmod u+x #{bin}/xfig"

    # link fig2dev bitmaps to XFIGLIBDIR
    ln_s "#{HOMEBREW_PREFIX}/opt/transfig/share/bitmaps", "#{lib}/X11/xfig/"
  end
end

__END__
diff --git a/fig.h b/fig.h
index ca00aef..4f5583a 100755
--- a/fig.h
+++ b/fig.h
@@ -375,6 +375,9 @@ extern	double		drand48();
 extern	long		random();
 extern	void		srandom(unsigned int);
 
+#elif defined(__DARWIN__)
+extern  void        srandom();
+
 #elif !defined(__osf__) && !defined(__CYGWIN__) && !defined(linux) && !defined(__FreeBSD__) && !defined(__GLIBC__)
 extern	void		srandom(int);
 
diff --git a/w_export.c b/w_export.c
index 98d0ad0..111d603 100755
--- a/w_export.c
+++ b/w_export.c
@@ -1016,7 +1016,7 @@ toggle_hpgl_pcl_switch(Widget w, XtPointer closure, XtPointer call_data)
     /* set global state */
     print_hpgl_pcl_switch = state;
 
-    return;
+    return 0;
 }
 
 static XtCallbackProc
@@ -1038,7 +1038,7 @@ toggle_hpgl_font(Widget w, XtPointer closure, XtPointer call_data)
     /* set global state */
     hpgl_specified_font = state;
 
-    return;
+    return 0;
 }
 
 void create_export_panel(Widget w)
diff --git a/w_keyboard.c b/w_keyboard.c
index 427d60c..5921379 100755
--- a/w_keyboard.c
+++ b/w_keyboard.c
@@ -45,6 +45,10 @@
 #define REG_NOERROR 0
 #endif
 
+#ifndef REG_NOERROR
+#define REG_NOERROR 0
+#endif
+
 Boolean keyboard_input_available = False;
 int keyboard_x;
 int keyboard_y;
diff --git a/w_print.c b/w_print.c
index 2accfd1..62cf718 100755
--- a/w_print.c
+++ b/w_print.c
@@ -1188,7 +1188,7 @@ switch_print_layers(Widget w, XtPointer closure, XtPointer call_data)
     /* which button */
     which = (intptr_t) XawToggleGetCurrent(w);
     if (which == 0)		/* no buttons on, in transition so return now */
-	return;
+	return 0;
     if (which == 2)		/* "blank" button, invert state */
 	state = !state;
 
@@ -1196,7 +1196,7 @@ switch_print_layers(Widget w, XtPointer closure, XtPointer call_data)
     print_all_layers = state;
     update_figure_size();
 
-    return;
+    return 0;
 }
 
 /* when user toggles between printing all or only active layers */
diff --git a/w_util.c b/w_util.c
index 812834f..f50fc18 100755
--- a/w_util.c
+++ b/w_util.c
@@ -710,7 +710,7 @@ start_spin_timer(Widget widget, XtPointer data, XEvent event)
     /* keep track of which one the user is pressing */
     cur_spin = widget;
 
-    return;
+    return 0;
 }
 
 static XtEventHandler
@@ -718,7 +718,7 @@ stop_spin_timer(int widget, int data, int event)
 {
     XtRemoveTimeOut(auto_spinid);
 
-    return;
+    return 0;
 }
 
 static	XtTimerCallbackProc
@@ -729,7 +729,7 @@ auto_spin(XtPointer client_data, XtIntervalId *id)
     /* call the proper spinup/down routine */
     XtCallCallbacks(cur_spin, XtNcallback, 0);
 
-    return;
+    return 0;
 }
 
 /***************************/
@@ -1412,7 +1412,7 @@ toggle_checkbutton(Widget w, XtPointer data, XtPointer garbage)
     }
     SetValues(w);
 
-    return;
+    return 0;
 }
 
 /* assemble main window title bar with xfig title and (base) file name */
