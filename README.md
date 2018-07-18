***Warning: this repository is out-dated and won't work with recent versions of MirageOS and Irmin**


## Examples of Mirage unikernels using Irmin

- `git/` contains a unikernel using `ocaml-git` only.

### Building

To build a Xen unikernel, you need to
cross-compile few C packages to Xen, using the
[mirage-dev](https://github.com/mirage/mirage-dev) packages:

```
opam repo add mirage-dev https://github.com/samoht/mirage-dev.git
opam pin add git --dev -n
```

You should now be able to run:

```shell
cd git/
mirage configure --xen
make
[edit git.xl to uncomment the #vif line]
sudo xl create git.xl
```
