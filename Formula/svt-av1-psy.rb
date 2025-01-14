class SvtAv1Psy < Formula
  desc "Perceptual AV1 Encoder"
  homepage "https://svt-av1-psy.com"
  url "https://github.com/gianni-rosato/svt-av1-psy/archive/refs/tags/v2.3.0-A.tar.gz"
  sha256 "96d4fbec8fb1ef679f5445e47a93ae9f8622cb181571e24deac8f80344927a44"
  license "BSD-3-Clause"
  head "https://github.com/gianni-rosato/svt-av1-psy.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "nasm" => :build

  def install
    extra_cmake_args = %W[-DCMAKE_INSTALL_RPATH=#{rpath}]

    # Explicitly disable ARM NEON I8MM extension on Apple Silicon: upstream
    # build script attempts to detect CPU features via compiler flags, which
    # are stripped by brew's compiler shim. The M1 chip does not support the
    # I8MM extension (hw.optional.arm.FEAT_I8MM).
    extra_cmake_args << "-DENABLE_NEON_I8MM=OFF" if OS.mac?
    system "cmake", "-S", ".", "-B", "build", *extra_cmake_args, "-DSVT_AV1_LTO=ON", *std_cmake_args
    system "cmake", "--build", "build", "--parallel"
    system "cmake", "--install", "build"
  end

  test do
    resource "homebrew-testvideo" do
      url "https://github.com/grusell/svt-av1-homebrew-testdata/raw/main/video_64x64_yuv420p_25frames.yuv"
      sha256 "0c5cc90b079d0d9c1ded1376357d23a9782a704a83e01731f50ccd162e246492"
    end

    testpath.install resource("homebrew-testvideo")
    system bin/"SvtAv1EncApp", "-w", "64", "-h", "64", "--tune", "3", "-i", "video_64x64_yuv420p_25frames.yuv", "-b", "output.ivf"
    assert_predicate testpath/"output.ivf", :exist?
  end
end
