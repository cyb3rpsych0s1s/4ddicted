# CLI

During development you will often have to:

- overwrite mod files in your game folder on each changes
- look at the content of e.g. log files
- and similar tedious tasks like these ...

To make our lives easier, there's many terminal shortcuts commands at our disposal, via a `justfile`:

- first, install [Just](https://just.systems/man/en/chapter_4.html?highlight=brew#packages)
  > `Just` is just a command runner, it makes running commands in the terminal easier, more maintainable and generally more enjoyable
- list all available shortcuts:
  
  ```sh
  just
  ```

  ![just recipes](./pictures/just-recipes.png)

- generally speaking, while coding you will most likely be interested in the following commands:
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

## ℹ️ Coding process

1. build:
   - `archive` can only be reloaded from Wolvenkit GUI's `Hot Reload` (RED Hot Tools required) while game is running.
   - `tweaks`, `scripts` and `mods` can be just copied over to game files.
2. refresh:
   - once done, click in CET console:`archive` for WolvenKit archive, TweakXL `tweaks`, REDscript `scripts` and/or CET `reload all mods`
3. remember that depending on your changes reloading a save is necessary, or the game itself sometimes.

{{#include footer.md}}
