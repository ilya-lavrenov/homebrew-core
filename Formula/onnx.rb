class Onnx < Formula
  desc "Open standard for machine learning interoperability"
  homepage "https://onnx.ai"
  url "https://github.com/onnx/onnx/archive/refs/tags/v1.14.0.tar.gz"
  sha256 "1b02ad523f79d83f9678c749d5a3f63f0bcd0934550d5e0d7b895f9a29320003"
  license "Apache-2.0"
  head "https://github.com/onnx/onnx.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.11" => [:build, :test]
  depends_on "numpy"
  depends_on "protobuf"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .sort_by(&:version)
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    # Remove git cloned 3rd party to make sure formula dependencies are used
    dependencies = %w[third_party/benchmark
                      third_party/pybind11]
    dependencies.each { |d| (buildpath/d).rmtree }

    cmake_args = std_cmake_args + %w[
      -DONNX_ML=ON
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pythons.each do |python|
      ENV.append "ONNX_ML", "1"
      ENV.append "CMAKE_ARGS", "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
      system python, *Language::Python.setup_install_args(libexec, python)

      site_packages = Language::Python.site_packages(python)
      pth_contents = "import site; site.addsitedir('#{libexec/site_packages}')\n"
      (prefix/site_packages/"homebrew-onnx.pth").write pth_contents
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <onnx/common/version.h>
      int main()
      {
        std::cout << ONNX_NAMESPACE::LAST_RELEASE_VERSION;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++17",
           "-I#{include}", "-L#{lib}", "-lonnx", "-o", "test"
    assert_equal version.to_s, shell_output("./test").chomp

    pythons.each do |python|
      assert_match version.to_s, shell_output("#{python} -c 'import onnx; print(onnx.__version__)'")
    end
  end
end
