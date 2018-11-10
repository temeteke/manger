from rest_framework import routers
from .views import AuthorViewSet, TitleViewSet, VolumeViewSet

router = routers.DefaultRouter()
router.register(r'authors', AuthorViewSet)
router.register(r'titles', TitleViewSet)
router.register(r'volumes', VolumeViewSet)
urlpatterns = router.urls
