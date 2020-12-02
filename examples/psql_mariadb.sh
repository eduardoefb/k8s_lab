
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install psql-cluster bitnami/postgresql-ha



ssh root@10.5.0.30 'rm -rfv /srv/k8s_volume/psql_0 && mkdir -pv /srv/k8s_volume/psql_0 && chmod -R 777 /srv/k8s_volume/psql_0'
ssh root@10.5.0.31 'rm -rfv /srv/k8s_volume/psql_1 && mkdir -pv /srv/k8s_volume/psql_1 && chmod -R 777 /srv/k8s_volume/psql_1'


cat << EOF > pv_ha_0.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-ha-0
  labels:
    app.kubernetes.io/component: postgresql
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/name: postgresql-ha  
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /srv/k8s_volume/psql_0
    server: 10.5.0.30
EOF

cat << EOF > pv_ha_1.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-ha-1
  labels:
    app.kubernetes.io/component: postgresql
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/name: postgresql-ha  
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /srv/k8s_volume/psql_1
    server: 10.5.0.31
EOF

kubectl apply -f pv_ha_0.yml
kubectl apply -f pv_ha_1.yml

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default psql-cluster-postgresql-ha-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
export REPMGR_PASSWORD=$(kubectl get secret --namespace default psql-cluster-postgresql-ha-postgresql -o jsonpath="{.data.repmgr-password}" | base64 --decode)

kubectl run psql-cluster-postgresql-ha-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql-repmgr:11.9.0-debian-10-r65 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
    --command -- psql -h psql-cluster-postgresql-ha-pgpool -p 5432 -U postgres -d postgres

kubectl port-forward --namespace default svc/psql-cluster-postgresql-ha-pgpool 5432:5432 &
psql -h 127.0.0.1 -p 5432 -U postgres -d postgres
