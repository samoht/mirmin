## Examples of Mirage unikernels using Irmin

- `git/` contains a unikernel using `ocaml-git` only.

### Building

You need the followin pins:

```
opam pin add conduit https://github.com/samoht/ocaml-conduit.git#no-resolver-overwrite
opam pin add cohttp https://github.com/mirage/ocaml-cohttp.git
opam pin add mirage-http https://github.com/samoht/mirage-http.git
```