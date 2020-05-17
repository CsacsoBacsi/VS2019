"""
Definition of urls for RestTutorial.
"""

from datetime import datetime
import django.contrib.auth.views
import app.forms
import app.views
from django.conf.urls import url, include
from rest_framework import routers
from quickstart import views
from django.views.generic import RedirectView

router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)

# Uncomment the next lines to enable the admin:
# from django.conf.urls import include
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = [
    # Examples:
    url(r'^$', app.views.home, name='home'),
    url(r'^contact$', app.views.contact, name='contact'),
    url(r'^about', app.views.about, name='about'),
    url(r'^login/$',
        django.contrib.auth.views.LoginView,
        {
            'template_name': 'app/login.html',
            'authentication_form': app.forms.BootstrapAuthenticationForm,
            'extra_context':
            {
                'title': 'Log in',
                'year': datetime.now().year,
            }
        },
        name='login'),
    url(r'^logout$',
        django.contrib.auth.views.LogoutView,
        {
            'next_page': '/',
        },
        name='logout'),
    url(r'^', include (router.urls)),
    url(r'^api-auth/', include ('rest_framework.urls', namespace='rest_framework')),
     url(r'^favicon\.ico$',RedirectView.as_view(url='/static/favicon.gif'))
]


    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
