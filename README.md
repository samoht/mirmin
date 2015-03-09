## Examples of Mirage unikernels using Irmin

- `git/` contains a unikernel using `ocaml-git` only.


### Building for Unix

To build a unix or OSX unikernel, you need the followin pins:

```
opam pin add conduit https://github.com/samoht/ocaml-conduit.git#no-resolver-overwrite -n
opam pin add cohttp https://github.com/samoht/ocaml-cohttp.git#git-xen -n
opam pin add mirage-http https://github.com/samoht/mirage-http.git -n
opam pin add git https://github.com/samoht/ocaml-git.git#mirage-io -n
```

You should now be able to run:

```shell
cd git/
mirage configure
make
./main.native
```

### Building for Xen

To build a Xen unikernel, you need to
cross-compile few C packages to Xen, using the
[mirage-dev](https://github.com/mirage/mirage-dev) packages:

```
opam repo add mirage-dev https://github.com/samoht/mirage-dev.git
```

And then add the same pins as in the previous sections:

```
opam pin add conduit https://github.com/samoht/ocaml-conduit.git#no-resolver-overwrite
opam pin add cohttp https://github.com/samoht/ocaml-cohttp.git#git-xen
opam pin add mirage-http https://github.com/samoht/mirage-http.git
opam pin add git https://github.com/samoht/ocaml-git.git#mirage-io
```

You should now be able to run:

```shell
cd git/
mirage configure --xen
make
[edit git.xl to uncomment the #vif line]
sudo xl create git.xl
```
