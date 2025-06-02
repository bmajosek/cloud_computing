import requests
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.conf import settings
import os

POSTS_SERVICE_URL = "http://posts:8000/api/posts/upload/"

@csrf_exempt
def upload(request):
    if request.method == "POST":
        username = request.POST.get("username")
        caption = request.POST.get("caption")
        image = request.FILES.get("image")

        if not image or not username:
            return JsonResponse({"error": "Missing image or username"}, status=400)

        # Zapisz tymczasowo obrazek
        path = default_storage.save(image.name, image)
        full_path = os.path.join(settings.MEDIA_ROOT, path)

        # Wyślij dane do posts service
        with open(full_path, "rb") as f:
            response = requests.post(
                f"{POSTS_SERVICE_URL}",
                data={"username": username, "caption": caption},
                files={"image": f},
            )

        # Usuń lokalny plik
        default_storage.delete(path)

        return JsonResponse(response.json(), status=response.status_code)
