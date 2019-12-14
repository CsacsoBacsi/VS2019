"""
Definition of urls for SudokuWeb.
"""

from datetime import datetime
from django.conf.urls import url
import django.contrib.auth.views
from django.urls import include, path
from django.contrib import admin

import SudokuSolver.forms
import SudokuSolver.views

# Uncomment the next lines to enable the admin:
# from django.conf.urls import include
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    #url(r'^$', SudokuSolver.views.home, name='home'),
    url(r'^about$', SudokuSolver.views.about, name='about'),
    #url(r'^home', include ('SudokuSolver.urls')),
    url(r'^Sudoku/', include ('SudokuSolver.urls')),
    #url (r'^test$', SudokuSolver.views.test1, name='test'),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
]
