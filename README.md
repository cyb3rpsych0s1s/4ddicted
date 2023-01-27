# Addicted

An amplifier mod based on core game consumables, and optionally on community mods `Toxicity` (not yet compatible with `WE3D - Drugs in Night City`).

Basically adds a chance to become addicted to substances too frequently consumed, like MAXdoc and the likes, offering additional debuffs and effects in an immersive way.

## Play

Just download the latest release and install like any other mod.

## Contribute

To ease development, a `justfile` is available with the following commands:

- first, install [Just](https://just.systems/man/en/chapter_4.html?highlight=brew#packages)
- then you can list all available commands:
  ```sh
  just
  ```
- generally speaking, while coding you will most likely be interested in these commands:
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

### ℹ️ Coding process
1. build:
   - `archive` can only be reloaded from Wolvenkit GUI's Hot Reload (RED Hot Tools required) while game is running.
   - `tweaks`, `scripts` and `mods` can be just copied over to game files.
2. refresh:
   - once done, click in CET console:`archive` for WolvenKit archive, TweakXL `tweaks`, REDscript `scripts` and CET `reload all mods`
3. remember that depending on what you changed reloading a save is necessary, or the game itself sometimes.

A lot more informations can be found in the [book](https://cyb3rpsych0s1s.github.io/4ddicted).
