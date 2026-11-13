# Working on this fork

Lorenzo's crates.io snapshot of Zed's GPUI (`gpui-pre`, library name `gpui`), used by GPUI Kit on Android. The default branch is `mobile-lab`. The Zed revision is `zed-rev` under `[package.metadata.gpui-pre]` in `Cargo.toml`. Windowing backends live in `gpui_platform`, not here. Lib tests use `TestPlatform` and do not need a display.

These rules are the line. A coding agent follows them the same way a person does.

## One fix, one branch

Start from `mobile-lab`. One fix or feature on its own branch, named for that change (`touch-pinch`, `touch-axis`, `drag-handle`, `autoscroll`, `text-input-purpose`). Open the PR against `mobile-lab`. Unmodified crates.io imports stay on `0.3.x`; do not mix a snapshot bump and a behavior change in one branch.

Keep the PR small enough to read in one sitting. If the description needs "and also", split it.

## One open PR

Do not open another branch or PR while your previous one is still open and unmerged, unless Lorenzo asks. Finish it, fix it, or close it first. `mobile-lab` is where finished branches are combined, not where new work starts.

## Tests before you push

Use current stable Rust (edition 2024, 1.85 or newer). From the repo root:

```sh
bash ci/place-test-fonts.sh
cargo test --locked --lib --features test-support <filter>
```

Run the modules you touched, not a guess:

| Change | Filter |
| --- | --- |
| Touch pans, pinch, drag handling in the recognizer | `gestures` |
| Pinch delivery, drag handles, touch drags through the window | `window::` |
| Scroll axis, autoscroll on a `div` | `elements::div` |
| Accessibility tree | `window::a11y` |
| Text-field purpose / keyboard configuration | `input::tests` |

Put the command and the pass/fail line in the PR. CI runs `cargo check --locked --lib`, `cargo test --locked --test action_macros`, then the same suite with no filter.

Two Zed pieces are not in this snapshot, and the suite does not compile without them:

- `src/style.rs` uses `#[perf]` from `util_macros`. `ci/util_macros` is a path dev-dependency that only adds `#[test]`, which is what upstream does when the perf harness is off. Do not grow it.
- `src/svg_renderer.rs` includes IBM Plex Sans and Lilex at the monorepo path `../../../assets/fonts/...` (outside this checkout). `ci/place-test-fonts.sh` downloads those two files from `zed-rev` and checks their sha256. Do not commit the fonts and do not rewrite the include paths.

## Stop when it fails twice

If CI or these tests fail twice in a row on the same change, stop. Report the cause: the error, what you already tried, and what you think is wrong. Do not push a third time hoping it goes green.

Do not edit `.github/workflows` unless Lorenzo explicitly asks. A red job is a reason to stop and report, not a reason to weaken the workflow.

## Phone before merge

Touch, scroll, pinch, drag, the on-screen keyboard, and accessibility are not finished when `cargo test` is green. Before merge, a person has to try the change on a real phone, with their hands. The PR says how: device, build, what was done, what happened. `adb input` cannot do two fingers, so a pinch is not verified until a hand does it (see [Gpui-android#108](https://github.com/Bombatomica64/Gpui-android/pull/108)). If that has not happened, write **UNTESTED** and do not merge.

## What diverges from upstream

Say so in the commit and the PR when a change should not land in Zed as written. The image-decoder size experiment on `mobile-lab-image-formats` is the pattern: label it, and do not present it as an upstream patch.

On a snapshot refresh, keep the fork-only pieces and re-apply them on top of the unmodified `0.3.x` import: `ci/util_macros`, the `util_macros` dev-dependency in `Cargo.toml`, `ci/place-test-fonts.sh`, `.github/workflows/test.yml`, and this file.

## Pull requests

Title commits and PRs the way the history does: `gpui: <what changed>`. In the body, say why, the test command and result, and the phone check or **UNTESTED**. Link the GPUI Kit or Gpui-android issue the change belongs to.
