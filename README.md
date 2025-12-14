# OS-9 for Aesthedes 2 on MAME

You need your GH account to know one of your SSH keys. The instructions below assume the private key is in `~/.ssh/id_rsa`.

## Checkout

1. Add this entry to your `~/.ssh/config`:

    ```
    Host github-personal
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly true
    ```

2. Checkout:
    ```
    git clone --recursive https://github.com/biappi/os9-builder.git
    ```
    If already checked out and failed midway, try again with:
    ```
    git submodule update
    ```

## Build

### On Linux

GCC 10 is required (so, Ubuntu 22.04 and not 20.04).

The top-level `Makefile` has recipes for the most common tasks.

1. Install dependencies:
    ```
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt install wine32 libsdl2-dev libsdl2-ttf-dev
    ```
2. Rename `Makefile.conf.sample` to `Makefile.conf`
3. Edit `Makefile.conf`:
    ```
    SDL_PATH=/usr/lib/x86_64-linux-gnu/cmake/SDL2
    ```