set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load

# default to steam default game dir
DEFAULT_GAME_DIR := join("C:\\", "Program Files (x86)", "Steam", "steamapps", "common", "Cyberpunk 2077")
game             := env_var_or_default("GAME_DIR", DEFAULT_GAME_DIR)

# list all commands
default:
  @just --list --unsorted
  @echo "⚠️ on Windows, paths defined in .env must be double-escaped:"
  @echo 'e.g. RED_CLI=C:\\somewhere\\on\\my\\computer\\redscript-cli.exe'

@archive TO=game:
    just recipes/archive/install '{{TO}}'

@audioware TO=game LOCALE='en-us':
    just recipes/audioware/install '{{TO}}' '{{LOCALE}}'

@cet TO=game:
    just recipes/cet/install '{{TO}}'

@redscript TO=game:
    just recipes/red/install '{{TO}}'

@tweak TO=game:
    just recipes/tweak/install '{{TO}}'

@build TO=game LOCALE='en-us': (archive TO) (audioware TO LOCALE)

@reload TO=game: (cet TO) (redscript TO) (tweak TO)

@dev: (build) (reload)

@ci TO: (archive absolute_path(TO)) (reload absolute_path(TO))

@bundle TO LOCALE: (audioware absolute_path(TO) LOCALE)

@uninstall FROM=game:
    just recipes/archive/uninstall '{{FROM}}'
    just recipes/cet/uninstall '{{FROM}}'
    just recipes/red/uninstall '{{FROM}}'
    just recipes/tweak/uninstall '{{FROM}}'
    just recipes/audioware/uninstall '{{FROM}}'

# 🧹 clear current cache (r6/cache is not used, only r6/cache/modded matters)
[windows]
@clear:
    just recipes/swap "{{ join(game, 'r6', 'cache', 'final.redscripts.bk') }}" "{{ join(game, 'r6', 'cache', 'final.redscripts') }}"

# 📖 read book directly
@read:
    cd book; mdbook build --open

# 🖊️  book with live hot reload
@draft:
    cd book; mdbook watch --open

# 📕 assemble book (for release in CI)
@assemble:
    cd book; mdbook build

@cr2w LOCALE='en-us':
    just recipes/archive/cr2w '{{LOCALE}}'

@encode LOCALE='en-us' OVERWRITE='false':
  just recipes/audioware/encode '{{LOCALE}}' '{{OVERWRITE}}'

# 🧹 strip comments and logs (for release in CI)
@sweep:
  just recipes/red/sweep
