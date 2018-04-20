class OsrmBackend < Formula
  desc "High performance routing engine"
  homepage "http://project-osrm.org/"
  url "https://github.com/Project-OSRM/osrm-backend/archive/v5.17.2.tar.gz"
  sha256 "7c32926f71e1a34c76ed85609ca6f2e9d4cb1faf81a04b3273ef01f0147417ee"
  head "https://github.com/Project-OSRM/osrm-backend.git"

  bottle do
    cellar :any
    sha256 "5c81936e4bf5c271dd3231f16f29c7bbedce8fc0a735db4f6fac7606b3bba126" => :high_sierra
    sha256 "1cc1b3901fc0f8bda6c7b1e45db7ae2012d447a429486a5350c831939dec3ac1" => :sierra
    sha256 "14791422f5b906938e8dcdf762337d729ddb16e6adacd7b1ee2bdf07abf9113a" => :el_capitan
  end

  # "invalid use of non-static data member 'offset'"
  # https://github.com/Project-OSRM/osrm-backend/issues/3719
  depends_on :macos => :el_capitan

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "libstxxl"
  depends_on "libxml2"
  depends_on "libzip"
  depends_on "lua"
  depends_on "tbb"

  def install
    mkdir "build" do
      system "cmake", "..", "-DENABLE_CCACHE:BOOL=OFF", *std_cmake_args
      system "make"
      system "make", "install"
    end
    pkgshare.install "profiles"
  end

  test do
    (testpath/"test.osm").write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <osm version="0.6">
       <bounds minlat="54.0889580" minlon="12.2487570" maxlat="54.0913900" maxlon="12.2524800"/>
       <node id="1" lat="54.0901746" lon="12.2482632" user="a" uid="46882" visible="true" version="1" changeset="676636" timestamp="2008-09-21T21:37:45Z"/>
       <node id="2" lat="54.0906309" lon="12.2441924" user="a" uid="36744" visible="true" version="1" changeset="323878" timestamp="2008-05-03T13:39:23Z"/>
       <node id="3" lat="52.0906309" lon="12.2441924" user="a" uid="36744" visible="true" version="1" changeset="323878" timestamp="2008-05-03T13:39:23Z"/>
       <way id="10" user="a" uid="55988" visible="true" version="5" changeset="4142606" timestamp="2010-03-16T11:47:08Z">
        <nd ref="1"/>
        <nd ref="2"/>
        <tag k="highway" v="unclassified"/>
       </way>
      </osm>
    EOS

    (testpath/"tiny-profile.lua").write <<~EOS
      function way_function (way, result)
        result.forward_mode = mode.driving
        result.forward_speed = 1
      end
    EOS
    safe_system "#{bin}/osrm-extract", "test.osm", "--profile", "tiny-profile.lua"
    safe_system "#{bin}/osrm-contract", "test.osrm"
    assert_predicate testpath/"test.osrm", :exist?, "osrm-extract generated no output!"
  end
end
