# posts/api/views.py

from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from .models import Post

@csrf_exempt
def create_post(request):
    if request.method == "POST":
        image = request.FILES.get("image")
        caption = request.POST.get("caption")
        username = request.POST.get("username")

        if not image or not username:
            return JsonResponse({"error": "Missing fields"}, status=400)

        post = Post.objects.create(
            username=username,
            caption=caption,
            image=image
        )

        return JsonResponse({
            "id": post.id,
            "username": post.username,
            "caption": post.caption,
            "image_url": post.image.url,
            "created_at": post.created_at.isoformat(),
        })

def get_posts(request):
    posts = Post.objects.all().order_by('-created_at')
    data = []

    for post in posts:
        data.append({
            'id': post.id,
            'username': post.username,
            'caption': post.caption,
            # 'image_url': f'http://gateway:8000{post.image.url}',
            'image_url': post.image_url,
            'created_at': post.created_at.isoformat(),
        })

    return JsonResponse(data, safe=False)