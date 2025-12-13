# OS-9 for Aesthedes 2 on MAME

You need your GH account to know one of your SSH keys. The instructions below assume the private key is in `~/.ssh/id_rsa`.

To checkout:

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