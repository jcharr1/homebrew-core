class Fetchmail < Formula
  desc "Client for fetching mail from POP, IMAP, ETRN or ODMR-capable servers"
  homepage "https://www.fetchmail.info/"
  url "https://downloads.sourceforge.net/project/fetchmail/branch_6.4/fetchmail-6.4.18.tar.xz"
  sha256 "302dc9bcdc6927dedf375d2baaead2347557faa70d98b1da83f2409fa6fb259f"
  license all_of: [
    "LGPL-2.1-or-later",
    "ISC",
    "BSD-3-Clause",
    :public_domain,
    "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" },
  ]

  livecheck do
    url :stable
    regex(%r{url=.*?/branch_\d+(?:\.\d+)*?/fetchmail[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "69091941fb702f47d95d5dc0b93978df4455c2f4df19382a66ec3d2775c32935"
    sha256 cellar: :any, big_sur:       "18f8ad0233c864ef7df0af47fbd001b7facb0c393666226b70c76077921f52ab"
    sha256 cellar: :any, catalina:      "8bb5a567c7f6a5b9adf489b40dbccdb47b9ecc1a2fbdcb284058751f85fdc5aa"
    sha256 cellar: :any, mojave:        "b41e5ea60d50061719aa5d9366384655bce4e0af4026e9e3b772a0f81a7dc266"
  end

  depends_on "openssl@1.1"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/fetchmail", "--version"
  end
end
