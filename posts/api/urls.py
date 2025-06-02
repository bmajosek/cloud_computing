from django.urls import path
from .views import get_posts, create_post

urlpatterns = [
    path('', get_posts), 
    path('upload/', create_post), 
]