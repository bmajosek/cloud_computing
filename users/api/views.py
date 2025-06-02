from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.contrib.auth import authenticate

class RegisterView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        if not username or not password:
            return Response({'error': 'Missing fields'}, status=400)
        if User.objects.filter(username=username).exists():
            return Response({'error': 'User already exists'}, status=400)
        User.objects.create_user(username=username, password=password)
        return Response({'message': 'User created'}, status=201)

class LoginView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            return Response({'message': 'Login successful'}, status=200)
        return Response({'error': 'Invalid credentials'}, status=401)
