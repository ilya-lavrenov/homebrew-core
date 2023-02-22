class Fastfetch < Formula
  desc "Like neofetch, but much faster because written in C"
  homepage "https://github.com/LinusDierheimer/fastfetch"
  url "https://github.com/LinusDierheimer/fastfetch/archive/refs/tags/1.10.1.tar.gz"
  sha256 "3741521d265ac948cbf0fe3a098b3296d1b18d16f3a159fd6669794ef720525b"
  license "MIT"
  head "https://github.com/LinusDierheimer/fastfetch.git", branch: "dev"

  bottle do
    sha256 arm64_ventura:  "79cffd18a5efb891cf52448d30744b5c1da9d62ec1b266de50026db66d157786"
    sha256 arm64_monterey: "287fc2200dadf5543fe3aa85b64f5e21e3e98730befbad76c05da442f8c1f143"
    sha256 arm64_big_sur:  "45906d10c7942c164bcae699eed615368a88b083ac01b6cb26a1fcd4931b141b"
    sha256 ventura:        "adc1892a507ee706ad51fc55b869f34cc51419a27a6e8c02d67a1848d3af6172"
    sha256 monterey:       "380019f80a806b1d4b32ede394099c59d4c43d618693e478a5ac2a779a297fcf"
    sha256 big_sur:        "aa72c9d126369f65ab162663764d810c4841008ab0a017e6c408b637d142380e"
    sha256 x86_64_linux:   "8bb712471c70ad058a4dea142aeda071e0340b29975381cccf1aac5e8a7a934c"
  end

  depends_on "chafa" => :build
  depends_on "cmake" => :build
  depends_on "glib" => :build
  depends_on "imagemagick" => :build
  depends_on "pkg-config" => :build
  depends_on "vulkan-loader" => :build

  uses_from_macos "zlib" => :build

  # Fix build on macOS < 12. Remove when merged and released.
  # PR: https://github.com/LinusDierheimer/fastfetch/pull/425
  patch do
    url "https://github.com/LinusDierheimer/fastfetch/commit/6983c165ee8bb6860640cde1a333e77b9b736529.patch?full_index=1"
    sha256 "b0da380a16fcaf3aec06bf8127dd3913583b424d54d602cc765c44687b884195"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_INSTALL_SYSCONFDIR=#{etc}", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match "fastfetch", shell_output("#{bin}/fastfetch --version")
    assert_match "OS", shell_output("#{bin}/fastfetch --structure OS --logo none --hide-cursor false")
  end
end
