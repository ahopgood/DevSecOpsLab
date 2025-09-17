#!/usr/bin/env bash

kubectl -n argocd patch secret argocd-secret \
       -p '{"stringData": {
       "admin.password":
       "$2a$12$/2iVO1MQbAr6aO8riTk.MO3/S5y3BG1cJ1v7MC8J0IisBJV8NcuSa",
       "admin.passwordMtime": "'$(date +%FT%T%Z)'"
       }}'