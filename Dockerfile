FROM python:3.8-buster

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY *.py ./
COPY .params .

CMD ["python3", "./gazinflux.py", "--schedule", "06:00"]
