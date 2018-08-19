from django.shortcuts import render
from rest_framework import viewsets
from .models import Question, Choice
from .serializers import QuestionSerializer

class QuestionViewSet(viewsets.ModelViewSet):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
