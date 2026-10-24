# Fonts

Font files for the Ink and Paper type system (`prd/02-design-spec.md`,
`prd/12-phase-2-tokens-api.md`). They are not declared in the tokens
pubspec on purpose: each app declares the plain family names
(`PlusJakartaSans`, `IBMPlexMono`) so a family never registers as
`packages/just_ui_tokens/...`. Today `apps/showcase` uses them through the
`apps/showcase/assets/fonts` symlink.

They live outside `lib/` so the CLI binary (RustEmbed of `tokens/lib`)
does not ship them.

## Sources

Downloaded from the upstream GitHub releases on 2026-10-24 and copied
unmodified.

| Files | Release | Archive SHA-256 |
| ----- | ------- | --------------- |
| `PlusJakartaSans-{Regular,Medium,SemiBold,Bold}.ttf`, `PlusJakartaSans-OFL.txt` (from `OFL.txt`) | https://github.com/tokotype/PlusJakartaSans/releases/tag/2.7.1, `PlusJakartaSans-2.7.1.zip`, folder `ttf/` | `4bfc5cdf97d750423bb3d1d40ed8e529bc92288924d9c65e18ff486acefac66c` |
| `IBMPlexMono-{Regular,Medium}.ttf`, `IBMPlexMono-OFL.txt` (from `LICENSE.txt`) | https://github.com/IBM/plex/releases/tag/%40ibm%2Fplex-mono%402.5.0, `ibm-plex-mono.zip`, folder `fonts/complete/ttf/` | `6d23f01257663d8cc49a0d64c22ced630b79e0e2a0ac08a0da86e9a38bbc481c` |

Both families are licensed under the SIL Open Font License 1.1 (see the
`*-OFL.txt` files).

## File SHA-256

`apps/showcase/test/fonts_integrity_test.dart` checks these values.

```
98fbd727aae340b236955879dabed4d991aac9e8e90b3b2a67ce4a59221cc97c  IBMPlexMono-Medium.ttf
7c6fbddca4b700be918f5f6183d9bd4464fa427fe435f0b480d77fe2bb8c5a43  IBMPlexMono-Regular.ttf
14972f80fb151f32fb7129c6ad1893f6dd2a9d8bac30c40508c99e7f289b6682  PlusJakartaSans-Bold.ttf
8e60a920af7fcc9d9e2768aaa51c8595a1c72a9ff3da87c216a319023158ebf2  PlusJakartaSans-Medium.ttf
6bcfbb10639b8a206b4f8a0a1a29459e7255b1481c95e20d587dd1f1a4b24646  PlusJakartaSans-Regular.ttf
de75ddb3917c5a3f2b7d0cd65fcf63795710f2e1fd944199a73a01731e66fd43  PlusJakartaSans-SemiBold.ttf
7e6b2818edbd8f6a01ae80641cc8f16a51080d08fb4e532be3a0b6f74adb07da  IBMPlexMono-OFL.txt
995c7199cab65954f545996326755daee7b63cc6b42b06c13da1f9502ab08a99  PlusJakartaSans-OFL.txt
```
