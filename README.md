# crew

[!! under construction !!]

NAME
----
crew -- package manager for Cygwin similar to brew for Mac OS

SYNOPSIS
--------
crew <command\> <packages\>

ESSENTIAL COMMANDS
------------------

- `install <package>`
    - Install package
- `remove <package>`
    - Uninstall package
- `update`
    - Fetch the newest version of setup.ini
- `list`
    - List all installed packages
- `search` [wip]
    - \--

COMMANDS
--------

- `config`
    - Show crew and system configuration
- `cleanup [<packages>]` [wip]
    - For all installed or specific packages, remove any older versions from the cellar.
- `deps <packages>`
    - Show dependencies for package.
- `desc <packages>`
    - Display package's name and one-line description.
- `doctor` [wip]
    - Check your system for potential problems.
- `fetch <packages>`
    - Download the source packages for the given package.
- `info <packages>`
    - Display information about package.
- `install <packages>`
    - Install packages. Similar to `fetch` + `link`.
- `link <packages>`
    - Symlink all of packages' installed files into the Homebrew prefix.
      This is done automatically when you install packages 
      but can be useful for DIY installations.
- `list`
    - List all installed packages.
- `outdated` [wip]
    - Show packages that have an updated version available.
- `pin <packages>` [wip]
    - Pin the specified packages, preventing them from being upgraded
      when issuing the crew upgrade command. See also unpin.
- `prune` [wip]
    - Remove dead symlinks from the crew dir prefix. This is generally
      not needed, but can be useful when doing DIY installations.
- `search text|/text/` [wip]
    - Perform a substring search of package names for text. If text is
      surrounded with slashes, then it is interpreted as a regular
      expression.
- `switch <package> <version>` [wip]
    - Symlink all of the specific version of package's install to crew
      dir prefix.
- `unlink <packages>`
    - Remove symlinks for package from the crew dir prefix. This can
      be useful for temporarily disabling a package.
- `unpin <packages>` [wip]
    - Unpin packages, allowing them to be upgraded by `crew upgrade`.
      See also pin.
- `update`
    - Fetch the newest version of setup.ini
- `upgrade [<packages>]` [wip]
    - Upgrade outdated, unpinned packages.


