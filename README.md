# Golang 1.5 Builder

Build tiny Docker images from your Go project.

## Static Binaries

The key to a small docker image is to only include what you need. golang15-builder makes the process easy by providing a container-native method for creating both a statically linked binary, and a docker image.

## Requirements

golang15-builder makes a few assumptions about how your project is laid out.

### Project Structure

```
example
├── Dockerfile
├── example.go
├── package_a
│   ├── bar.go
│   └── foo.go
├── package_b
│   ├── baz.go
│   └── volkswagon.go
└── vendor
    └── github.com
        └── christian-blades-cb
            └── dependency
                └── dependency.go
```

The main package should be located at the base of the repo.

### Vendoring

golang15-builder supports [Godep](https://github.com/tools/godep) and the [vendoring experiment](https://docs.google.com/document/d/1Bz5-UB7g2uPBdOx-rw5t9MxJwkfpx90cqG9AFL0JAYo/edit) from Go 1.5. Vendor your dependencies in the usual places.

### Canonical Import Path

You must provide a hint in the form of a [specially formatted comment](https://docs.google.com/document/d/1jVFkZTcYbNLaTxXD9OcGfn7vYv5hWtPx9--lTx1gPMs/edit). This hint allows the source code to be located correctly in the GOPATH so that the go tooling can properly build your project.

```go
package main // import "github.com/christian-blades-cb/desoto"
```

## Usage

```shell
$ docker run --rm -v $(pwd):/src \
    -v /var/run/docker.sock:/var/run/docker.sock \
    christianbladescb/golang15-builder \
    myorg/myimage:mytag
```

golang15-builder expects your source code to be available at /src. Mount your source directory to /src using the '-v' flag in docker.

### Dockerfile

```Dockerfile
FROM scratch
ADD example /
EXPOSE 8000
ENTRYPOINT ["/example"]
```

The dockerfile can be as simple as adding the binary to the filesystem, exposing the correct ports (if needed), and setting the binary as the container entrypoint.

**Note: If the application needs to make SSL connections (https://), you will need to either provide the root certificates, or use a base image which provides them such as [centurylink/ca-certs](https://registry.hub.docker.com/u/centurylink/ca-certs/)**


## Related projects

* [centurylinklabs/golang-builder](https://github.com/CenturyLinkLabs/golang-builder)
