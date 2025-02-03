{
  system,

  callPackage,
  writeShellApplication,

  nodejs,
  pnpm,
  bun,
  prisma-factory,
}:
let
  hashesBySystem = {
    x86_64-linux = {
      prisma-fmt-hash = "sha256-4zsJv0PW8FkGfiiv/9g0y5xWNjmRWD8Q2l2blSSBY3s=";
      query-engine-hash = "sha256-6ILWB6ZmK4ac6SgAtqCkZKHbQANmcqpWO92U8CfkFzw=";
      libquery-engine-hash = "sha256-n9IimBruqpDJStlEbCJ8nsk8L9dDW95ug+gz9DHS1Lc=";
      schema-engine-hash = "sha256-j38xSXOBwAjIdIpbSTkFJijby6OGWCoAx+xZyms/34Q=";
    };
    aarch64-linux = {
      prisma-fmt-hash = "sha256-gqbgN9pZxzZEi6cBicUfH7qqlXWM+z28sGVuW/wKHb8=";
      query-engine-hash = "sha256-q1HVbRtWhF3J5ScETrwvGisS8fXA27nryTvqFb+XIuo=";
      libquery-engine-hash = "sha256-oalG9QKuxURtdgs5DgJZZtyWMz3ZpywHlov+d1ct2vA=";
      schema-engine-hash = "sha256-5bp8iiq6kc9c37G8dNKVHKWJHvaxFaetR4DOR/0/eWs=";
    };
    aarch64-darwin = {
      prisma-fmt-hash = "sha256-UPig7U2zXOccalIUE0j07xJdmqAUJ7cpXFTo+2Gbsc8=";
      query-engine-hash = "sha256-ihP1BEAvXQ+5XXHEXCYAVTnuETpfxmdtsIGRTljKtS0=";
      libquery-engine-hash = "sha256-4T63O+OyoEIJ0TLKoOoil06whd+41QxiXXg+0cgpX/8=";
      schema-engine-hash = "sha256-+O4IelHbZt4X+6UWol8TpL+BBDTS5JT+0hQR7ELVmZc=";
    };
  };
  test-npm =
    let
      prisma = (callPackage prisma-factory hashesBySystem.${system}).fromNpmLock ./npm/package-lock.json;
    in
    writeShellApplication {
      name = "test-npm";
      text = ''
        echo "testing npm"
        ${prisma.shellHook}
        cd npm
        ${nodejs}/bin/npm ci
        ./node_modules/.bin/prisma generate
      '';
    };
  test-pnpm =
    let
      prisma = (callPackage prisma-factory hashesBySystem.${system}).fromPnpmLock ./pnpm/pnpm-lock.yaml;
    in
    writeShellApplication {
      name = "test-pnpm";
      runtimeInputs = [ pnpm ];
      text = ''
        echo "testing pnpm"
        ${prisma.shellHook}
        cd pnpm
        pnpm install
        pnpm prisma generate
      '';
    };
  test-bun =
    let
      prisma = (callPackage prisma-factory hashesBySystem.${system}).fromBunLock ./bun/bun.lock;
    in
    writeShellApplication {
      name = "test-bun";
      runtimeInputs = [ bun ];
      text = ''
        echo "testing bun"
        ${prisma.shellHook}
        cd bun
        bun install
        bunx prisma generate
      '';
    };
  test-all = writeShellApplication {
    name = "test";
    runtimeInputs = [
      test-npm
      test-pnpm
      test-bun
    ];
    text = ''
      test-npm
      test-pnpm
      test-bun
    '';
  };
in
{
  inherit
    test-npm
    test-pnpm
    test-bun
    test-all
    ;
}
