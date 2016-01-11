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
update, from start to stop this takes ~8 minutes on a P75-A7200 laptop
over wireless without a cache proxy setup.

-----

The remaining dockerfiles are app specific and are built using the `build-apps`
script.

- `thell-rstudio-base` - RStudio Desktop Preview Release with the minimal extra
  while still providing _full_ feature usage without additional installs is
  great for one-offs, testing external stuff, etc...
- `thell-rstudio-pbsi` - An example of what I do for project specific setup which
  starts a specific project and includes specific dependencies.

The `start` scripts for the apps are just your standard commands put into a script.

-----

__Avoid any container in the wild requesting `--privileged` and don't _disable_
your docker apparmor.__

## Image Notes

### RStudio Image

Of particular interest to authors using Rmarkdown with Mathjax is the setup of
the [MathJax Third Party Extensions][1]. It can be quite a hassle to setup
RStudio, RMarkdown, Mathjax and the third party extensions so that they are
all available with/without internet access or as self-contained/not-self-contained,
with a target of pdf or html, etc... etc...
By using the `RMARKDOWN_MATHJAX_PATH` the local installation can be used and
with the third party extensions installed in that path as `contrib` this little
javascript snippet can be used to switch the path and give access to the extensions.

~~~{js}
<script type="text/x-mathjax-config">
  if (! /latest/.test(MathJax.Hub.config.root)) {
    MathJax.Ajax.config.path["Contrib"] = MathJax.Hub.config.root + "/contrib";
  } else {
    MathJax.Ajax.config.path["Contrib"] = MathJax.Hub.config.root.replace(/[^\/]+latest/, "contrib");
  }
</script>
~~~

For example; to enable a few extensions you might add this to your `Rmarkdown` file.

~~~{js}
<script type="text/x-mathjax-config">
  if (! /latest/.test(MathJax.Hub.config.root)) {
    MathJax.Ajax.config.path["Contrib"] = MathJax.Hub.config.root + "/contrib";
  } else {
    MathJax.Ajax.config.path["Contrib"] = MathJax.Hub.config.root.replace(/[^\/]+latest/, "contrib");
  }
  MathJax.Hub.Config({
    extensions: ["tex2jax.js","[Contrib]/counters/counters.js"],
    jax: ["input/TeX", "output/SVG"],
    TeX: {
      equationNumbers: { autoNumber: "AMS" },
      extensions: ["AMSmath.js","AMSsymbols.js","extpfeil.js","cancel.js","[Contrib]/xyjax/xypic.js"]
    }
  });
</script>
~~~

A problem with doing it directly like this is you'll get a warning/halt when emitting html while
knitting to pdf. To resolve this you might either make a control chunk that emits that javascript
when a particular flag is set, or add `always_allow_html: yes` to the yaml header.

  [1]:https://github.com/mathjax/MathJax-third-party-extensions