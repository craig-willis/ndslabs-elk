#!/bin/bash

#
# Very basic function that waits for a ResourceController to be
# in the "Running" state before starting the associated Service.
#
start_rc_service_wait ()
{
 echo Starting service $1

 status=`kubectl get pods | grep $1 | awk '{print $3}'`
 if [ "$status" != 'Running' ]; then
   echo "Starting rc for $1"
   #kubectl create -f elasticsearch/es-rc.yaml
   kubectl create -f $2
 
   i=0 
   while [ "$status" != 'Running' ]; do
       echo "Waiting for $1 ($status)"
       status=`kubectl get pods | grep $1 | awk '{print $3}'`
       sleep 5
       ((i++))
       if [ $i == 5 ]; then
           echo "Problem starting $1"
           exit 1
       fi
   done
       echo "Service $1 $status"
 else
   echo "Service $1 $status"
 fi
 
 if ! kubectl get services | grep $1; then 
   echo "Creating $1 service"
   kubectl create -f $3
 fi
 echo ""
}


# 1. Start ElasticSearch
start_rc_service_wait "elasticsearch" "elasticsearch/es-rc.yaml" "elasticsearch/es-svc.yaml"
# 2. Start Logstash
start_rc_service_wait "logstash" "logstash/logstash-rc.yaml" "logstash/logstash-svc.yaml"
# 3. Start Kibana
start_rc_service_wait "kibana" "kibana/kibana-rc.yaml" "kibana/kibana-svc.yaml"
# 4. Start logspout
kubectl create -f logspout/logspout-pod.yaml
# 5. Start nginx -- for testing
kubectl create -f nginx/nginx-pod.yaml

sleep 5
kubectl get pods
kubectl get rc
kubectl get services

echo NGINX running on `kubectl get pod nginx -o go-template="{{.status.podIP}}"`

