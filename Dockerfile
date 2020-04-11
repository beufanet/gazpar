FROM python:3.8-buster


WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY *.py ./
COPY .params .

RUN echo '0 6 * * * python3 /usr/src/app/gazinflux.py --last > /etc/crontabs/root'

CMD ["python3", "./gazinflux.py", "--last"]