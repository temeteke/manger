from rest_framework import routers
from .views import VolumeViewSet

router = routers.DefaultRouter()
router.register(r'volumes', VolumeViewSet)
urlpatterns = router.urls
