from django.http import HttpResponse
import requests
from django.core.paginator import Paginator
from django.shortcuts import render, redirect
from django.contrib.auth import logout
from django.views.decorators.csrf import csrf_exempt

COMMENTS_URL = 'http://comments:8000/api/comments/'
USERS_URL = "http://users:8000/api"
POSTS_URL = "http://posts:8000/api/posts/"
WRITE_URL = "http://write:8000/api"

import logging
logger = logging.getLogger(__name__)

def feed(request):
    res = requests.get(POSTS_URL)
    posts = res.json() if res.status_code == 200 else []

    paginator = Paginator(posts, 3) 
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)

    for post in page_obj:
        logger.info(f"Post: {post}")
        comment_res = requests.get(f'{COMMENTS_URL}{post["id"]}/')
        post["comments"] = comment_res.json() if comment_res.status_code == 200 else []

    return render(request, 'feed.html', {'page_obj': page_obj})

def login_view(request):
    error = None
    next_url = request.GET.get("next", "/")

    if request.method == "POST":
        data = {"username": request.POST["username"], "password": request.POST["password"]}
        res = requests.post(f"{USERS_URL}/login/", data=data)
        if res.status_code == 200:
            request.session["username"] = request.POST["username"]
            return redirect(next_url)
        error = "Invalid credentials"

    return render(request, "login.html", {"error": error})


def register_view(request):
    error = None
    if request.method == "POST":
        data = {"username": request.POST["username"], "password": request.POST["password"]}
        res = requests.post(f"{USERS_URL}/register/", data=data)
        if res.status_code == 201:
            return redirect("/login/")
        error = res.json().get("error", "Registration failed.")
    return render(request, "register.html", {"error": error})

def upload(request):
    if request.method == "POST":
        if not request.session.get("username"):
            return redirect("/login/")
        files = {"image": request.FILES.get("image")}
        data = {
            "caption": request.POST.get("caption"),
            "username": request.session["username"]
        }
        requests.post(f"{WRITE_URL}/upload/", data=data, files=files)
        return redirect("/")
    return render(request, "upload.html")

@csrf_exempt
def post_comment(request, post_id):
    print("POST SESSION:", dict(request.session))
    print("POST COOKIES:", request.COOKIES)
    print("POST username:", request.session.get("username"))

    if not request.session.get("username"):
        return HttpResponse("NO SESSION FOUND", status=401)

    if request.method == "POST":
        comment = request.POST.get("comment")
        if comment:
            requests.post("http://comments:8000/api/comments/", data={
                "post_id": post_id,
                "text": comment,
                "username": request.session["username"]  
            })
    return redirect("/")



def logout_view(request):
    logout(request)
    return redirect('/')
