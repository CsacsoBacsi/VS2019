from django.conf.urls import url
from . import views

app_name = "SudokuSolver"

urlpatterns = [
    url(r'^signup/$', views.signup, name="signup"),
    url(r'^login/$', views.sudoku_login, name="login"),
    url(r'^logout/$', views.logout, name="logout"),
    url (r'^home$', views.home, name='home'),
    url (r'^load$', views.load, name='load'),
    url (r'^save$', views.save, name='save'),
    url (r'^delete$', views.delete, name='delete'),
    url (r'^test$', views.test1, name='test'),
    url (r'^test2$', views.test2, name='test2'),
    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
]
