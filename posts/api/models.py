from django.db import models

class Post(models.Model):
    username = models.CharField(max_length=255)
    caption = models.TextField(blank=True)
    image = models.ImageField(upload_to="uploads/")
    created_at = models.DateTimeField(auto_now_add=True)
