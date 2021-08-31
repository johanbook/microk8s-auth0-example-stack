# Build docker images and upload to ctr (microk8s image repository)
build:
	docker build ./services/auth-server -t auth-server:test
	docker build ./services/target-server -t target-server:test

	# NB: Image must be imported into registry before used
	docker save auth-server > auth-server.tar
	microk8s ctr image import auth-server.tar

	docker save target-server > target-server.tar
	microk8s ctr image import target-server.tar

# Install cluster dependencies
install:
	microk8s helm3 repo add traefik https://helm.traefik.io/traefik
	microk8s helm3 repo update
	microk8s helm3 install traefik traefik/traefik

# Create a proxy to Traefik service
proxy:
	sudo microk8s kubectl port-forward `microk8s kubectl get svc --selector "app.kubernetes.io/name=traefik" --output=name` 80:80

# Shutdown cluster. Can also use `microk8s reset` to remove
# helm installs and plugins
shutdown:
	microk8s kubectl delete -R -f manifests/
	microk8s stop

# Start the cluster
start:
	microk8s start
	microk8s enable dashboard dns helm3 registry

# Create external load balancer
start-metallb:
	microk8s enable metallb:192.168.1.105-192.168.1.120

# Get access token to microk8s dashboard
token:
	@bash ./scripts/get_token.sh

# Expose Traefik dashboard
traefik-dashboard:
	echo "Dashboard will be available at http://localhost:9000/dashboard/"
	microk8s kubectl port-forward `microk8s kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name` 9000:9000

# Update cluster
update:
	microk8s kubectl create secret generic auth0-credentials --from-env-file secrets/auth0
	microk8s kubectl apply -R -f manifests/
