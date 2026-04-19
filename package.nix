{
  lib,
  stdenv,
  cmake,
  openssl,
  boost,
  fmt_11,
  nlohmann_json,
  lz4,
  zlib,
  zstd,
  enet,
  libopus,
  vulkan-headers,
  vulkan-utility-libraries,
  spirv-tools,
  spirv-headers,
  simpleini,
  discord-rpc,
  cubeb,
  vulkan-memory-allocator,
  vulkan-loader,
  libusb1,
  pkg-config,
  gamemode,
  stb,
  SDL2,
  glslang,
  python3,
  httplib,
  cpp-jwt,
  ffmpeg-headless,
  qt6,
  fetchFromGitHub,
  unordered_dense,
  xbyak,
  zydis,
}:
let
  version = "0.2.0-rc2";

  inherit (qt6)
    qtbase
    qtmultimedia
    qtwayland
    wrapQtAppsHook
    qttools
    qtwebengine
    qt5compat
    qtcharts
    ;

  quazip = stdenv.mkDerivation {
    pname = "quazip";
    version = "1.5-qt6";
    src = fetchFromGitHub {
      owner = "crueter-archive";
      repo = "quazip-qt6";
      rev = "f838774d6306eb5a500af9ab336ec85f01ebd7ec";
      hash = "sha256-Jp+v7uwoPxvarzOclgSnoGcwAPXKnm23yrZKtjJCHro=";
    };
    nativeBuildInputs = [
      cmake
      wrapQtAppsHook
    ];
    buildInputs = [
      qtbase
      qtmultimedia
      qtwayland
      qttools
      qtwebengine
      qt5compat
    ];
  };

  mcl = stdenv.mkDerivation {
    pname = "mcl";
    version = "7b08d83";
    src = fetchFromGitHub {
      owner = "azahar-emu";
      repo = "mcl";
      rev = "7b08d83418f628b800dfac1c9a16c3f59036fbad";
      hash = "sha256-uTOiOlMzKbZSjKjtVSqFU+9m8v8horoCq3wL0O2E8sI=";
    };
    nativeBuildInputs = [ cmake ];
    buildInputs = [ fmt_11 ];
  };

  sirit =
    let
      rev = "v1.0.2";
    in
    stdenv.mkDerivation {
      pname = "sirit";
      version = "1.0.2";
      src = fetchFromGitHub {
        owner = "eden-emulator";
        repo = "sirit";
        inherit rev;
        hash = "sha256-0wjpQm8tWHeEebSiRGs7b8LYcA2d4MEbHuffP2eSNGU=";
      };
      nativeBuildInputs = [
        pkg-config
        cmake
      ];
      buildInputs = [ spirv-headers ];
      cmakeFlags = [ (lib.cmakeBool "SIRIT_USE_SYSTEM_SPIRV_HEADERS" true) ];
    };

  nx_tzdb =
    let
      tzdbVersion = "121125";
    in
    fetchTarball {
      url = "https://git.crueter.xyz/misc/tzdb_to_nx/releases/download/${tzdbVersion}/${tzdbVersion}.tar.gz";
      sha256 = "sha256-6+qt4yzisNx8cAOrWVS+g/GCeTD37iejQN06Ij6OMxU=";
    };

  xbyak_new = xbyak.overrideAttrs (_: {
    version = "7.22";
    src = fetchFromGitHub {
      owner = "herumi";
      repo = "xbyak";
      rev = "4e44f4614ddbf038f2a6296f5b906d5c72691e0f";
      hash = "sha256-ZmdOjO5MbY+z+hJEVgpQzoYGo5GAFgwAPiv4vs/YMUA=";
    };
  });

  frozen =
    let
      rev = "61dce5ae18ca59931e27675c468e64118aba8744";
    in
    stdenv.mkDerivation {
      pname = "frozen";
      version = builtins.substring 0 7 rev;
      src = fetchFromGitHub {
        owner = "serge-sans-paille";
        repo = "frozen";
        inherit rev;
        hash = "sha256-zIczBSRDWjX9hcmYWYkbWY3NAAQwQtKhMTeHlYp4BKk=";
      };
      nativeBuildInputs = [ cmake ];
    };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "eden";
  inherit version;
  src = fetchTree {
    type = "git";
    url = "https://git.eden-emu.dev/eden-emu/eden.git";
    ref = "v${version}";
    rev = "f0a4ac7359b6de6d6f1926c795831de01d4119d5";
    submodules = true;
  };

  patches = [ ./discord-rpc-compat.patch ];

  nativeBuildInputs = [
    cmake
    glslang
    pkg-config
    python3
    qttools
    wrapQtAppsHook
    # mcl provides cmake modules consumed at configure time
    mcl
    frozen
  ];

  buildInputs = [
    # Qt
    qtbase
    qtmultimedia
    qtwayland
    qtwebengine
    qt5compat
    qtcharts
    quazip
    # Vulkan
    vulkan-headers
    vulkan-memory-allocator
    vulkan-utility-libraries
    spirv-tools
    spirv-headers
    sirit
    # Audio / input
    cubeb
    enet
    libopus
    SDL2
    # Networking
    openssl
    httplib
    cpp-jwt
    # Media
    ffmpeg-headless
    # Utilities
    boost
    fmt_11
    nlohmann_json
    unordered_dense
    lz4
    zlib
    zstd
    zydis
    stb
    simpleini
    libusb1
    # Eden-specific
    discord-rpc
    gamemode
    # mcl also linked at runtime
    mcl
    # Timezone data (path, referenced by YUZU_TZDB_PATH)
    nx_tzdb
    xbyak_new
  ];

  __structuredAttrs = true;
  cmakeFlags = [
    (lib.cmakeBool "YUZU_ENABLE_LTO" true)
    (lib.cmakeBool "YUZU_TESTS" false)
    (lib.cmakeBool "DYNARMIC_TESTS" false)

    (lib.cmakeBool "ENABLE_QT6" true)
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)

    # "external" = from the externals/ directory in source; false = use system
    (lib.cmakeBool "YUZU_USE_EXTERNAL_SDL2" false)
    (lib.cmakeBool "YUZU_USE_EXTERNAL_VULKAN_HEADERS" false)
    (lib.cmakeBool "YUZU_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES" false)
    (lib.cmakeBool "YUZU_USE_EXTERNAL_VULKAN_SPIRV_TOOLS" false)
    (lib.cmakeBool "CPMUTIL_FORCE_SYSTEM" true)

    (lib.cmakeFeature "YUZU_TZDB_PATH" "${nx_tzdb}")
    (lib.cmakeBool "YUZU_CHECK_SUBMODULES" false)

    (lib.cmakeBool "YUZU_USE_QT_WEB_ENGINE" true)
    (lib.cmakeBool "YUZU_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "USE_DISCORD_PRESENCE" true)

    (lib.cmakeBool "YUZU_ENABLE_COMPATIBILITY_REPORTING" false)
    (lib.cmakeBool "ENABLE_COMPATIBILITY_LIST_DOWNLOAD" true)

    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "eden | {} (nix)")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "eden | {} (nix)")

    (lib.cmakeBool "SIRIT_USE_SYSTEM_SPIRV_HEADERS" true)
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-Wno-error -Wno-array-parameter -Wno-stringop-overflow")
  ];

  env.NIX_CFLAGS_COMPILE = "-msse4.2";

  qtWrapperArgs = [ "--prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib" ];

  preConfigure = ''
    export SOURCE_DATE_EPOCH=${toString finalAttrs.src.lastModified}
    echo "${finalAttrs.version}" > GIT-REFSPEC
    echo "${finalAttrs.src.rev}" > GIT-COMMIT
    echo "${finalAttrs.version}" > GIT-TAG
  '';

  postInstall = ''
    install -Dm44 $src/dist/72-yuzu-input.rules $out/lib/udev/rules.d/72-yuzu-input.rules
  '';

  meta = {
    description = "Nintendo Switch video game console emulator";
    homepage = "https://eden-emu.dev/";
    downloadPage = "https://eden-emu.dev/download";
    changelog = "https://github.com/eden-emulator/Releases/releases";
    mainProgram = "eden";
    desktopFileName = "dist/dev.eden_emu.eden.desktop";
  };
})
