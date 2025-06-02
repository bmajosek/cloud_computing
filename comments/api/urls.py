from django.urls import path
from .views import CommentView

urlpatterns = [
    path('<int:post_id>/', CommentView.as_view()),
]
