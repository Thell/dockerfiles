Dockerfiles
-----------

Check out the `/scripts/ddash` and `apt-out` files. I'm particularly
pleased with how they turned out for making `docker build` faster while
also making the build output more useful by replacing the normal apt
output with status line updates instead of spewing junk or shutting up
entirely.

-----

Numeric prefix dockerfiles are the base dockerfiles.

- `00-apt.dockerfile`  - __Fast__ apt setup and controlled build output.
- `10-cli.dockerfile`  - generic variety of __useful__ base cli tools.
- `20-gui.dockerfile`  - dbus-x11, pulseaudio, terminator __gui term__ and such.
- `30-user.dockerfile` - base user __setup and config__.

These are most easily built using `build-bases` after editing the user info,
and then started using one of the `start` scripts in `/bin`.

```sh
chmod +x ./build-bases
./build-bases
chmod +x ./bin/thell-start
./bin/thell terminator
```

Personally, I rebuild my base containers each time my host system gets a kernel
update, from start to stop this takes ~8 minutes on a [P75-A7200][1] laptop
over wireless without a cache proxy setup.

__Avoid any container in the wild requesting `--privileged` and don't _disable_
your docker apparmor.__

