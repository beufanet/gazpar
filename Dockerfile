FROM python:3.8-buster

RUN apt-get update && apt-get install -y cron && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY *.py ./
COPY .params .

CMD ["python3", "./gazinflux.py", "--schedule", "06:00"]