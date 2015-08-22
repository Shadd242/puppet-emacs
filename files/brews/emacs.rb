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


  def install
      
      args = ["--with-ns"]
      
      system "./configure", *args
      system "make"
      system "make install"
      
  end

end

__END__