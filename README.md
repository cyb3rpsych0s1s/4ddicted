# Addicted

An amplifier mod based on core game consumables, and optionally on community mods `Toxicity` (not yet compatible with `WE3D - Drugs in Night City`).

Basically adds a chance to become addicted to substances too frequently consumed, like MAXdoc and the likes, offering additional debuffs and effects in an immersive way.

## Play

Just download the latest release and install like any other mod.

## Contribute

To ease development, a `justfile` is available with the following commands:

- run once on install, to create folders if missing

  ```sh
  just setup
  ```

- copy files to game dir *before launching game*:

  ```sh
  just build
  ```

- copy files to game dir *while game is running* (excluding `archive`, see below):

  ```sh
  just rebuild
  ```

  ℹ️ hot reload `archive` from Wolvenkit GUI's Hot Reload (RED Hot Tools required)
  ℹ️ CET console provide tools to reload `archive`, CET `mods`, TweakXL `tweaks` and REDscript `scripts`

- list all other available commands:

  ```sh
  just
  ```

A lot more informations can be found in the [book](https://cyb3rpsych0s1s.github.io/4ddicted).
