from django.urls import path
from . import views
from .views import feed, logout_view
from .comment import post_comment

urlpatterns = [
    path('', feed),
    path('comment/<int:post_id>/', post_comment, name='comment'),
    path('login/', views.login_view),
    path('register/', views.register_view),
    path('upload/', views.upload),
    path('logout/', views.logout_view),
]
