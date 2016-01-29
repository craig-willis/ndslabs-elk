#!/bin/bash

start_wait ()
{
 echo Starting service $1

 status=`kubectl get pods | grep $1 | awk '{print $3}'`
 if [ "$status" != 'Running' ]; then
   echo "Starting rc for $1"
   #kubectl create -f elasticsearch/es-rc.yaml
   kubectl create -f $2
 
   while [ "$status" != 'Running' ]; do
       echo "Waiting for $1 ($status)"
       status=`kubectl get pods | grep $1 | awk '{print $3}'`
       sleep 5
   done
       echo "Service $1 $status"
 else
   echo "Service $1 $status"
 fi
 
 if ! kubectl get services | grep $1; then 
   echo "Creating $1 service"
   #kubectl create -f elasticsearch/es-svc.yaml
   kubectl create -f $3
 fi
}

start_wait "elasticsearch" "elasticsearch/es-rc.yaml" "elasticsearch/es-svc.yaml"
start_wait "logstash" "logstash/logstash-rc.yaml" "logstash/logstash-svc.yaml"
start_wait "kibana" "kibana/kibana-rc.yaml" "kibana/kibana-svc.yaml"

kubectl create -f logspout/logspout-pod.yaml
kubectl create -f nginx/nginx-pod.yaml

sleep 5
kubectl get pods
kubectl get rc
kubectl get services

NGINX running on `kubectl get pod nginx -o go-template="{{.status.podIP}}"`

#kubectl create -f logstash/logstash-rc.yaml
#kubectl create -f logstash/logstash-svc.yaml
#kubectl create -f kibana/kibana-rc.yaml
#kubectl create -f kibana/kibana-svc.yaml
#kubectl create -f logspout/logspout-pod.yaml
#kubectl create -f kubernetes-nginx-example/nginx-pod.yaml 
#curl `kubectl get pod nginx -o go-template="{{.status.podIP}}"`
#kubectl get services
