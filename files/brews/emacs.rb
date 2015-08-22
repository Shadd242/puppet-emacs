require 'formula'

class Emacs < Formula
  homepage 'http://www.gnu.org/software/emacs/'
  url 'http://ftpmirror.gnu.org/emacs/emacs-24.4.tar.gz'
  mirror 'http://ftp.gnu.org/pub/gnu/emacs/emacs-24.4.tar.gz'
  sha256 '257a7557a89b9e290ab9eef468c68ef62ed5bd30f350ea028a9a6ac3208be00d'
  version '24.4-boxen5'

  skip_clean 'share/info' # Keep the docs

#option "cocoa", "Build a Cocoa version of emacs"
# option "srgb", "Enable sRGB colors in the Cocoa version of emacs"
# option "with-x", "Include X11 support"
  option "use-git-head", "Use Savannah (faster) git mirror for HEAD builds"
  option "keep-ctags", "Don't remove the ctags executable that emacs provides"
# option "japanese", "Patch for Japanese input methods"

  head do
    url 'http://git.savannah.gnu.org/r/emacs.git/'

    depends_on :autoconf
    depends_on :automake
  end

  stable do
      #if build.include? "cocoa"
      #depends_on :autoconf
      #depends_on :automake
      #end
      url 'http://git.savannah.gnu.org/r/emacs.git/'
      
      depends_on :autoconf
      depends_on :automake
    # Fix default-directory on Cocoa and Mavericks.
    # Fixed upstream in r114730 and r114882.
    #patch :p0, :DATA

    # Make native fullscreen mode optional, mostly from upstream r111679
    #patch do
        #url "https://gist.github.com/scotchi/7209145/raw/a571acda1c85e13ed8fe8ab7429dcb6cab52344f/ns-use-native-fullscreen-and-toggle-frame-fullscreen.patch"
        #sha1 "cb4cc4940efa1a43a5d36ec7b989b90834b7442b"
        #end

    # Fix memory leaks in NS version from upstream r114945
    #patch do
    #url "https://gist.github.com/anonymous/8553178/raw/c0ddb67b6e92da35a815d3465c633e036df1a105/emacs.memory.leak.aka.distnoted.patch.diff"
    #sha1 "173ce253e0d8920e0aa7b1464d5635f6902c98e7"
    #end

    # "--japanese" option:
    # to apply a patch from MacEmacsJP for Japanese input methods
    #patch :p0 do
    #url "http://sourceforge.jp/projects/macemacsjp/svn/view/inline_patch/trunk/emacs-inline.patch?view=co&revision=583&root=macemacsjp&pathrev=583"
    #sha1 "61a6f41f3ddc9ecc3d7f57379b3dc195d7b9b5e2"
    #end if build.include? "cocoa" and build.include? "japanese"
  end

  depends_on 'pkg-config' => :build
#depends_on :x11 if build.with? "x"
  depends_on 'gnutls' => :optional

  fails_with :llvm do
    build 2334
    cause "Duplicate symbol errors while linking."
  end

  # Follow MacPorts and don't install ctags from Emacs. This allows Vim
  # and Emacs and ctags to play together without violence.
  def do_not_install_ctags
    unless build.include? "keep-ctags"
      (bin/"ctags").unlink
      (share/man/man1/"ctags.1.gz").unlink
    end
  end

  def install
      
      args = ["--prefix=#{prefix}",
      "--without-dbus",
      "--enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp",
      "--infodir=#{info}/emacs"]
      
      args << '--with-ns'
      
      system "./autogen.sh" if build.head?
      
      
      args << "--without-x"
      
      system "./configure", *args
      system "make"
      system "make install"
      
      # Don't cause ctags clash.
      do_not_install_ctags
      
  end

  def caveats
    s = ""
    if build.include? "cocoa"
      s += <<-EOS.undent
        A command line wrapper for the cocoa app was installed to:
         #{bin}/emacs
      EOS
      if build.include? "srgb" and build.head?
        s << "\nTo enable sRGB, use (setq ns-use-srgb-colorspace t)"
      end
    end
    return s
  end

  test do
    output = `'#{bin}/emacs' --batch --eval="(print (+ 2 2))"`
    assert $?.success?
    assert_equal "4", output.strip
  end
end

__END__
--- src/emacs.c.orig	2013-02-06 13:33:36.000000000 +0900
+++ src/emacs.c	2013-11-02 22:38:45.000000000 +0900
@@ -1158,10 +1158,13 @@
   if (!noninteractive)
     {
 #ifdef NS_IMPL_COCOA
+      /* Started from GUI? */
+      /* FIXME: Do the right thing if getenv returns NULL, or if
+         chdir fails.  */
+      if (! inhibit_window_system && ! isatty (0))
+        chdir (getenv ("HOME"));
       if (skip_args < argc)
         {
-	  /* FIXME: Do the right thing if getenv returns NULL, or if
-	     chdir fails.  */
           if (!strncmp (argv[skip_args], "-psn", 4))
             {
               skip_args += 1;
