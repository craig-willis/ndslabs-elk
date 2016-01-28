## ElasticSearch/LogStash/Kibana 

Simple Docker, Docker Compose and Kubernetes implementations of the ELK+logspout stack.


### Basic docker
To get started, here are a set of basic docker commands to start and test the ELK+logspout containers.

Start ElasticSearch:
```
docker run -d --name=nds-elasticsearch -p 9200:9200 -p 9300:9300 elasticsearch  -Des.network.host=0.0.0.0
```

Start Logstash, linking to the previous elasticsearch continer, listening for syslog events:
```
docker run -d --name=nds-logstash --link nds-elasticsearch:elasticsearch -p 5000:5000 logstash logstash -e 'output { elasticsearch { hosts => "elasticsearch" } } input { tcp { port => 5000 type => syslog } udp { port => 5000 type => syslog } }'
```

Start Kibana, connecting the the previous elasticsearch container:
```
docker run -d --name=nds-kibana --link nds-elasticsearch:elasticsearch  -p 5601:5601 kibana
```

Start Logspout, which will monitor /var/log on all host containers and forward to logstash:
```
docker run -d --name=nds-logspout --link nds-logstash:logstash --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/logspout syslog://logstash:5000
```

Start an nginx instance for testing:
```
docker run --name nds-nginx -p 80:80 -d nginx
curl `docker inspect  -f '{{.NetworkSettings.IPAddress}}' nds-nginx`
```

Open Kibana in a browser (http://<host>:5601).  If the server is not in the open security group, tunnel via ssh:
```
docker inspect  -f '{{.NetworkSettings.IPAddress}}' nds-kibana
```
ssh -L 5601:<kibana container ip>:5601 -i pem core@<host>
```
Now goto http://localhost:5601

### Kubernetes

Start elasticsearch resource controller and service. Remember to wait for the resource controller before starting the service:
```
kubectl create -f elasticsearch/es-rc.yaml
kubectl create -f elasticsearch/es-svc.yaml
```

Start logstash:
```
kubectl create -f logstash/logstash-rc.yaml
kubectl create -f logstash/logstash-svc.yaml
```

Start kibana:
```
kubectl create -f kibana/kibana-rc.yaml
kubectl create -f kibana/kibana-svc.yaml
```

Start logspout:
```
kubectl create -f logspout/logspout-pod.yaml
```

As above, open a browser to http://<host>:5601, tunneling if necessary
