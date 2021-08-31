# microk8s-auth0-example-stack

This is a [microk8s](https://microk8s.io/) stack that uses Traefik
IngressRoute as ingress controller. Auth0 is used for global authentication,
relying on Traefik's `forwardAuth` middleware.

## Installing

To spin up the cluster, begin by installing microk8s. Then run

```sh
make start
make install
make build
make update
```

Finally, to access the Traefik service, use `make proxy`. This will dynamically
allocate a port on localhost where the edge router is exposed.
