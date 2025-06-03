FROM python:3.10

WORKDIR /app
COPY . /app

RUN pip install -r requirements.txt
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
