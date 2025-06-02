FROM python:3.10-slim
WORKDIR /app
COPY . .
RUN pip install django djangorestframework
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
