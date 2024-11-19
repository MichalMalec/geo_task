# README

Description:
```
The aim of this task is to build a simple API. The application is able to store geolocation data in the database, based on IP address or URL - https://ipstack.com/ was used to get geolocation data. The API is able to add, delete or provide geolocation data on the base of ip address or URL.
```

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
