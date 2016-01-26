# This is a very simple script that starts the ELK stack + logspout and an nginx for testing

# 1. Start the ELK+logspout services.  
docker run -d --name=myelasticsearch -p 9200:9200 -p 9300:9300 elasticsearch  -Des.network.host=0.0.0.0
docker run -d --name=mylogstash --link myelasticsearch:elasticsearch -v "$PWD":/config-dir -p 5000:5000 logstash logstash -f /config-dir/logstash.conf
docker run -d --name=mykibana --link myelasticsearch:elasticsearch  -p 5601:5601 kibana
docker run -d --name=mylogspout --link mylogstash:logstash --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/logspout syslog://logstash:5000


# 2. Start nginx for testing
docker run --name mynginx -p 80:80 -d nginx
http://141.142.208.121

# If not open, tunnel to 5601
ssh -L 5601:localhost:5601 -i pem core@141.142.208.121
http://localhost:5601

# Refresh things a few times, the logs do appear
