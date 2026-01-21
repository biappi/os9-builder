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
2. Configure Wine for 32-bit executables:
    ```
    WINEARCH=win32 winecfg
    ```
3. Create the drive mapping:
    ```
    os9_builder_root=$PWD; (cd ~/.wine/dosdevices/; rm -f m:; ln -s $os9_builder_root m:)
    ```
4. Rename `Makefile.conf.sample` to `Makefile.conf`
5. Edit `Makefile.conf`:
    ```
    SDL_PATH=/usr/lib/x86_64-linux-gnu/cmake/SDL2
    ```
6. Create the hard disk image:
    ```
    make make-cfcard
    ```
7. Build OS-9 and run emulator:
    ```
    make run
    ```

## Run

1. On a terminal, run:

    ```
    make listen-term
    ```

2. On a separate terminal:

    ```
    make run-term
    ```

3. In the debugger window, type `g` to start the machine
4. To be done the first time:
    1. [Toggle UI controls](https://docs.mamedev.org/usingmame/mamemenus.html#introduction). If none of the keys work, try adding `-uimodekey SPACE` in `run-term` recipe in [Makefile](Makefile) then rerun and press space.
    2. Press Tab to show the main menu.
    3. In Machine Configuration, scroll down to `RS-232 Null Modem [root:rs232_a:null_modem]`. Change the settings to:
        * Flow Control: RTS
        * Data Bits: 8
        * Parity: None
        * RX Baud: 19200
        * Stop Bits: 1
        * TX Baud: 19200
    4. Press Esc multiple times to leave the menu
    5. Press F3 to restart the machine.
5. Look at the `listen-term` terminal, you should see the bootloader messages and the OS-9 prompt.

When booted the first time, it will create an empty RBF image at `mame/nvram/fake68/nvram`. One can use an existing RBF image to copy the `CMDS` directory in, e.g. with Toolshed, and start working with the system:

```sh
export SRC=<path-of-source-rbf-image-file>
os9 makdir mame/nvram/fake68/nvram,CMDS

```
