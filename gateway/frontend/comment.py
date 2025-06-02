import requests
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required

COMMENTS_URL = 'http://comments:8000/api/comments/'

@login_required
def post_comment(request, post_id):
    if request.method == 'POST':
        content = request.POST.get('content')
        if content:
            requests.post(f'{COMMENTS_URL}{post_id}/', data={
                'author': request.user.username,
                'content': content
            })
    return redirect('/')
