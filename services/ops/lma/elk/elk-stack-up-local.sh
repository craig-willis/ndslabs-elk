# This very simple script starts the ELK stack + logspout and nginx for basic testing.

# 1. Start the ELK+logspout services.  
docker run -d --name=nds-elasticsearch -p 9200:9200 -p 9300:9300 elasticsearch  -Des.network.host=0.0.0.0
docker run -d --name=nds-logstash --link nds-elasticsearch:elasticsearch -p 5000:5000 logstash logstash -e 'output { elasticsearch { hosts => "elasticsearch" } } input { tcp { port => 5000 type => syslog } udp { port => 5000 type => syslog } }'

docker run -d --name=nds-kibana --link nds-elasticsearch:elasticsearch  -p 5601:5601 kibana
docker run -d --name=nds-logspout --link nds-logstash:logstash --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/logspout syslog://logstash:5000


# 2. Start nginx for testing
docker run --name nds-nginx -p 80:80 -d nginx
curl `docker inspect  -f '{{.NetworkSettings.IPAddress}}' nds-nginx`

# If not open, tunnel to 5601
docker inspect  -f '{{.NetworkSettings.IPAddress}}' nds-kibana
# ssh -L 5601:<ip>:5601 -i pem core@<host>
# http://localhost:5601
