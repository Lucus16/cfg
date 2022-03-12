## Deploying a new machine

To deploy a new machine B from an existing machine A, first install NixOS on B.
Then:

    a$ vim cfg/dev/b.nix
    a$ vim cfg/dev/configs.nix
    b$ curl https://github.com/Lucus16.keys > /root/.ssh/authorized_keys
    a$ nixos-deploy switch b
    b$ rm /root/.ssh/authorized_keys

    a$ gpg --export lars > lars.gpg
    a$ scp lars.gpg b:
    b$ gpg --import < lars.gpg
    b$ git clone a:cfg
    a$ scp -r cfg/secrets b:cfg
    b$ cfg/bin/activate
