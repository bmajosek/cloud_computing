from django.db import models

class Comment(models.Model):
    post_id = models.IntegerField() 
    author = models.CharField(max_length=100, default='Anonymous')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
