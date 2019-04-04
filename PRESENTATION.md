<!-- .slide: class="center" --> 

# A Comparison of Service Mesh Solutions
### Looking at Istio, Linkerd and Consul Connect - Syed Ahmed, CloudOps

#### Syed Ahmed (sahmed@cloudops.com)

---

<!-- .slide: class="dark center" -->

# A Case for Service Mesh

---

## Monolithic Architecture

<br /><br />
<img class="right-50" src="./images/monolith.png" style="width: 25%; height; 100%">


* Strong Coupling between different modules causing anti-patterns in communicating between different modules
* Difficulties in Scaling
* Updating to new version requires complete re-install
* Problem in one module can cause the whole application to crash
* Difficult to move to a new framework or technology

---

## Microservices Architecture

<br /><br />
<img class="right-50" src="./images/microservices.png" style="width: 32%; height; 150%; margin-top: 2%; margin-left: 2%">

* API contract between different modules/service ensures that each module can be developed and maintained independently 
* Each service can be scaled independently
* Updating to new version requires only updates to a specific services
* Faliures handled locally. Crashing of one microservice does not lead to crash of the whole application
* Allows for easier CI/CD

---

## Evolution of the Ecosystem

<table style="height:100%; margin-top: 15%">
	<tr>
		<td> <img src="./images/docker.png" style="width: 40%"> </td>
		<td> <img src="./images/lxc.png" style="width: 100%"> </td>
	</tr>
	<tr>
		<td> <img src="./images/kubernetes.png" style="width: 50%"> </td>
		<td> <img src="./images/mesos.png" style="width: 100%"> </td>
	</tr>

</table>

---

## Challenges with the Microservices Architecture

<img class="center" src="./images/challenge1.png" style="margin-top: 10%; margin-left: 28%">

---

## Challenges with the Microservices Architecture

<img class="center" src="./images/challenge2.png" style="margin-top: 10%; margin-left: 28%">

---

## Challenges with the Microservices Architecture

<img class="center" src="./images/challenge3.png" style="margin-top: 10%; margin-left: 28%">

---

## Challenges with the Microservices Architecture

<img class="center" src="./images/challenge4.png" style="margin-top: 10%; margin-left: 28%">

---


## Challenges with the Microservices Architecture

<img class="center" src="./images/challenge5.png" style="margin-top: 10%; margin-left: 28%">

---

## Challenges with the Microservices Architecture

<img src="./images/challenge6.png" style="margin-top: 10%; margin-left: 28%">

---

<!-- .slide: class="dark center" -->

# Service Mesh as a Solution

---

## Service Mesh as a Solution

<br>
<br>
<br>
> A Service Mesh is the substrate between different microservices that makes connectivity between different microservices possible. In addition to providing networking, a Service Mesh can also provide other features like Service Discovery, Authentication and Authorization, Monitoring, Tracing and Traffic Shaping.

---

## Sidecar Pattern


<img src="./images/sidecar.png" style="margin-left: 25%; height:10%; width: 40%">

---
<!-- .slide: class="dark center" -->

# Istio

---
## Istio

<img src="./images/istio.png" class="right-25" style="margin-top:10%">

<!-- <div style="margin-top:10%"> -->
<br>
<br>
<br>
* Open Sourced by Google, IBM & Lyft in May 2017
* Service Mesh designed to connect, secure and monitor microservices

<!-- </div> -->

---
## Istio
<br>

* Automatic load balancing for HTTP, gRPC, WebSocket, and TCP traffic.
* Fine-grained control of traffic behavior with rich routing rules, retries, failovers, and fault injection.
* A pluggable policy layer and configuration API supporting access controls, rate limits and quotas.
* Automatic metrics, logs, and traces for all traffic within a cluster, including cluster ingress and egress.
* Secure service-to-service communication in a cluster with strong identity-based authentication and authorization.

---

## Istio Architecture

<img src="./images/istio_arch.png" style="margin-top:0%">

---

## Istio Architecture

<br>
* **Envoy:** high-performance proxy developed in C++ provides Dynamic service discovery, Load balancing, TLS termination, HTTP/2 and gRPC proxies, Circuit breakers, Health checks, Staged rollouts with %-based traffic split, Fault injection, Rich metrics


<br>
* **Pilot:** The core component used for traffic management in Istio is Pilot, which manages and configures all the Envoy proxy instances deployed in a particular Istio service mesh


---
## Istio Architecture

<br>
* **Mixer:** Mixer is a platform independent component. Mixer enforces access
  control and usage policies across the service mesh, and collects telemetry
  data from the Envoy proxy and other services. The proxy extracts request level
  attributes, and sends them to Mixer for evaluation

<br>
* **Citadel:** Citadel provides strong service-to-service and end-user
  authentication with built-in identity and credential management. You can use
  Citadel to upgrade unencrypted traffic in the service mesh. Using Citadel,
  operators can enforce policies based on service identity rather than on network
  controls

---

## Istio Gateway

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "httpbin.example.com"
```
<!-- .element: class="right-50" style="width:50%; margin-top: 10%; margin-left: 2%" -->

<br>
<br>
<br>
**Gateway** describes a load balancer operating at the edge of the mesh receiving
incoming or outgoing HTTP/TCP connections.

<br>

---

## Istio VirtualService

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews-route
spec:
  - route:
    - destination:
        host: reviews.prod.svc.cluster.local
        subset: v2
      weight: 25

    - destination:
        host: reviews.prod.svc.cluster.local
        subset: v1
      weight: 75
```
<!-- .element: class="right-50" style="width:50%; margin-top: 10%; margin-left: 2%" -->

<br>
A **VirtualService** defines a set of traffic routing rules to apply when a host is
addressed. Each routing rule defines matching criteria for traffic of a
specific protocol. If the traffic is matched, then it is sent to a named
destination service (or subset/version of it) defined in the registry.

<br>


---

## Istio DestinationRule

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: bookinfo-ratings
spec:
  host: ratings.prod.svc.cluster.local
  trafficPolicy:
    loadBalancer:
      simple: LEAST_CONN
```
<!-- .element: class="right-50" style="width:50%; margin-top: 15%; margin-left: 2%" -->

<br>
**DestinationRule** defines policies that apply to traffic intended for a
service after routing has occurred. These rules specify configuration for load
balancing, connection pool size from the sidecar, and outlier detection
settings to detect and evict unhealthy hosts from the load balancing pool.

---

<!-- .slide: class="dark center" -->

# Linkerd

---

## Linkerd

<img class="right-50" src="./images/linkerd.png" style="width: 35%; margin-top: 10%; margin-left: 2%">

<br><br><br>
* Initially started as a network proxy (v1.0) for enabling service mesh
* Merged with Conduit to form Linkerd 2.0 in Sept 2018

---
## Linkerd Architecture

<img  src="./images/linkerd_arch.png" >


---
## Linkerd Architecture
<br>
* **Controller:** The controller consists of multiple containers (public-api, proxy-api, destination, tap) that provide the bulk of the control plane’s functionality
* **Web:** The web deployment provides the Linkerd dashboard
* **Prometheus:**  All of the metrics exposed by Linkerd are scraped via Prometheus and stored. An instance of Prometheus that has been configured to work specifically with the data that Linkerd generates is deployed
* **Grafana:** Linkerd comes with many dashboards out of the box. The Grafana component is used to render and display these dashboards. You can reach these dashboards via links in the Linkerd dashboard itself.

---
## Linkerd Capabilities
<br>
<br>
* Linkerd’s philosophy is to be a very lightweight addition on top of existing platform
* No need to be a Platform admin to use linkerd
* Simple installation and CLI tools to get started
* Small sidecar proxy written in Rust
* Can do end-to-end encryption and automatic proxy injection
* Lacks complex routing and tracing capabilities

---
## Linkerd Commands
<br>
**Install:**
```bash
linkerd check --pre
linkerd install | kubectl apply -f -
```


**Inject:**
```bash
kubectl get -n emojivoto deploy -o yaml \
  | linkerd inject - \
  | kubectl apply -f -
```


**Inspect:**
```bash
linkerd -n emojivoto stat deploy
linkerd -n emojivoto top deploy
linkerd -n emojivoto tap deploy/web
```
---

<!-- .slide: class="dark center" -->
# Consul Connect

---

## Consul Connect

<img class="right-50" src="./images/consul.png" style="width: 35%; margin-top: 10%; margin-left: 2%">

<br><br><br>
* Consul is a highly available and distributed service discovery and KV store
* Consul Connect augments Consul and adds Service Mesh Capabilities and was added in July 2018 

---
## Consul Connect Features

<br><br>
* Provides secure service-to-service communication with automatic TLS encryption and identity-based authorization.
* Uses envoy proxy sidecar as the dataplane
* Integration with Vault for certificate and secret management
* Service discovery already provided by Consul
* Useful if you want to use services outside Kubernetes as Consul can do a 2 way sync between k8s services and Consul services
* No routing features. Main focus on service discovery and Service Identity management

---

<!-- .slide: class="dark center" -->
# Conclusion 

---
## Conclusion 

<br><br>
<table>
	<tr>
		<th> Feature </th>
		<th> Istio </th>
		<th> Linkerd </th>
		<th> Consul Connect </th>
	</tr>
	<tr>
		<td> Traffic Redirection <br> (Blue/Green deployments) </td>
		<td> Yes </td>
		<td> No </td>
		<td> No </td>
	</tr>
	<tr>
		<td> Traffic Splitting <br> (Canary deployment) </td>
		<td> Yes </td>
		<td> No </td>
		<td> No </td>
	</tr>
	<tr>
		<td> Attribute Based Routing </td>
		<td> Yes </td>
		<td> No </td>
		<td> No </td>
	</tr>
	<tr>
		<td> Service Identification </td>
		<td> Yes </td>
		<td> No </td>
		<td> Yes </td>
	</tr>
	<tr>
		<td> Auto Proxy Injection </td>
		<td> Yes </td>
		<td> Yes </td>
		<td> Yes </td>
	</tr>
	<tr>
		<td> Per-Service Installation </td>
		<td> No </td>
		<td> Yes </td>
		<td> No </td>
	</tr>

</table>

---
## Conclusion
<br><br>
<table>
	<tr>
		<th> Feature </th>
		<th> Istio </th>
		<th> Linkerd </th>
		<th> Consul Connect </th>
	</tr>
	<tr>
		<td> Built-in Dashboard </td>
		<td> Yes </td>
		<td> Yes </td>
		<td> Yes* </td>
	</tr>
	<tr>
		<td> TLS Termination </td>
		<td> Yes </td>
		<td> Yes </td>
		<td> Yes </td>
	</tr>
	<tr>
		<td> Metrics Collection </td>
		<td> Yes </td>
		<td> Yes </td>
		<td> No </td>
	</tr>
	<tr>
		<td> Tracing </td>
		<td> Yes </td>
		<td> No </td>
		<td> No </td>
	</tr>
	<tr>
		<td> Rate Limiting </td>
		<td> Yes </td>
		<td> No </td>
		<td> No </td>
	</tr>
	<tr>
		<td> External Service Support </td>
		<td> Yes </td>
		<td> No </td>
		<td> Yes </td>
	</tr>
</table>

---
<!-- .slide: class="dark center" -->

# Thank You
### Quesitons?

