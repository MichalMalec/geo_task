# README

Run app:
```
docker-compose up
```

Exemplary requests:
* POST:
```
curl -X POST -H "Content-Type: application/json" -d '{"ip": "134.201.250.155"}' http://localhost:3000/geolocations
```
* GET:
```
curl http://localhost:3000/geolocations/1
```
* DELETE:
```
curl -X DELETE http://localhost:3000/geolocations/1
```

Run tests:
```
bundle exec rspec
```
