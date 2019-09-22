FROM python:3-alpine


COPY ./ /app

WORKDIR /app

RUN pip install -r docker/requirements.txt


CMD ["python", "./back/app.py"]