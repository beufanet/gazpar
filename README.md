# gazinflux

## Externals / Thanks

The project has been inspired by job done by [empierre](https://github.com/empierre) on project [domoticz_gazpar available on Github](https://github.com/empierre/domoticz_gaspar). I modified a bit the code to work and fit my needs

## Grafana example

![Grafana Dashboard](https://raw.githubusercontent.com/beufanet/gazpar/master/grafana.png)

## Requirements

## Python3 and libs

`python3` with its dependencies:
- `pip install -r requirements.txt`

If you want to debug, please set level=logging.INFO to level=logging.DEBUG

### GRDF / GazPAr

Verify you have gazpar data available on [GRDF Portal](https://monespace.grdf.fr/monespace/particulier/consommation/tableau-de-bord)

Please also remember data provided is per day, if you want to improve with timed consumption and premium account, please submit MR with cool code. 

Remember, kWh provided is conversion factor dependant. Please verify it's coherent with your provider bills.

### InfluxDB

#### Create database

Create d
```
> CREATE DATABASE gazpar
> CREATE USER "gazpar" WITH PASSWORD [REDACTED]
> GRANT ALL ON "gazpar" TO "gazpar"
```

#### Alter default retention and tune it as you want

Example : 5 years (1825d)
```
> ALTER RETENTION POLICY "autogen" ON "gazpar" DURATION 1825d SHARD DURATION 7d DEFAULT
```

#### DataPoints Format

```
{
  "measurement": "conso_gaz",
    "tags": {
      "fetch_date" :        /DATE WHEN VALUE WHERE FETCH FROM API GRDF/
    },
    "time": '%Y-%m-%dT%H:%M:%SZ',
    "fields": {
      "kwh":               /VALUE IN kWh (see warning about convertion factor/,
      "mcube":             /VALUE IN m3/,
    }
}
```

#### Configure your own parameters

#### By supplying it via docker environment variables

It is possible to supply the configuration when launching the docker container, _ie_:

```bash
docker run -e GRDF_USERNAME=test@email.com -e GRDF_PASSWORD=password -e INFLUXDB_HOST=192.168.1.99 -e INFLUXDB_DATABASE=gazpar -e INFLUXDB_USERNAME=user -e INFLUXDB_PASSWORD=password -e INFLUXDB_SSL=false -e INFLUXDB_VERIFY_SSL=false gazpar:latest
```

It is also possible (and easier) to put the configuration in the `docker-compose.yml` file.

#### By modifying the .params file

Well, yes it is dirty, but ... you can perhaps improve using vault or anything related to secret storage :D Please do an MR or fork if you have any better idea.

Copy .params.example to .params and fill with your own values :

- `grdf` : username and password for API GRDF
- `influx` : your InfluxDB database

```
{
    "grdf":
    {
        "username": 	  "",
        "password": 	  ""
    },
    "influx":
    {
        "host": 	      "",
        "port": 	      8086,
        "db": 		      "",
        "username":     "",
        "password":     "",
        "ssl":		      true,
        "verify_ssl": 	true
    }
}
```

### Grafana

You just have to create dashboard with kind of queries :

```
SELECT mean("kwh") FROM "conso_gaz" WHERE $timeFilter GROUP BY time($__interval)

SELECT mean("mcube") FROM "conso_gaz" WHERE $timeFilter GROUP BY time($__interval)
```

### Script usage

#### Test it manually

You should run by hand for filling the first time and using --last for the next ones
```
# python3 gazinflux.py --days=5
```

If you want it to be scheduled, you can run the script like this (for it to be scheduled at 06:00 everyday):
```bash
python3 gazinflux.py --last --schedule 06:00
```

#### Launching with docker

You can either use the `docker-compose.yml` file to run the script:

```bash
docker-compose up -d --build
```

Or run the container manually:

```bash
#Build the image
docker build -t gazpar:latest .
#Run it
docker run -d gazpar:latest
```
