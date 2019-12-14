"""
Definition of views.
"""

from django.http import HttpRequest
from django.http import HttpResponse
from django.template import RequestContext
from datetime import datetime
from . import forms
from django.shortcuts import render, redirect, HttpResponseRedirect
import SudokuSolver.code.SudokuEnginePy as se
import SudokuSolver.code.Globals as Globals
from SudokuSolver.models import saveGrid, getUserList, getGridList, retrieveGridHeader, retrieveGridCells, checkConn, getUserName, deleteGridHeader
import random
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
import cx_Oracle
from django.urls import reverse

# Sign up new users
def signup (request):
    if request.method == 'POST':
         form = UserCreationForm (request.POST)
         if form.is_valid ():
             user = form.save ()
             #  log the user in
             login (request, user)
             return redirect ('SudokuSolver:home')
    else:
        form = UserCreationForm()
    return render(request, 'Signup.html', { 'form': form })

# Login
def sudoku_login (request):
    request.session ['message'] = ""
    if request.method == 'POST':
        form = AuthenticationForm (data=request.POST)

        if form.is_valid():
            # Log the user in
            user = form.get_user ()

            retval = checkConn ()
            if retval != 0:
                request.session ['message'] = "Oracle database connection problem!"
                request.session.modified = True
                return redirect ('SudokuSolver:home')

            csr = Globals.db.cursor ()
            sqlrowcnt = csr.var (cx_Oracle.NUMBER)
            retval  = csr.var (cx_Oracle.NUMBER)
            params = csr.callproc ('PCK_SUDOKU_SOLVER.insertUser', (user.username, sqlrowcnt, retval)) # Returns all IN and OUT params in params as a list (or tuple)

            if params[2] == -1: # User already exists, do nothing
                pass
            elif params[2] != 0:
                Globals.oraError = str (params[2])
                request.session ['message'] = "Database error: " + Globals.oraError
                return redirect ('SudokuSolver:home')
            
            login (request, user)
            Globals.user = user.username
            if 'next' in request.POST:
                return redirect (request.POST.get('next'))
            else:
                return redirect ('SudokuSolver:home')
    else:
        form = AuthenticationForm ()
    return render (request, 'Login.html', { 'form': form })

# About page (todo)
def about (request):
    """Renders the about page."""
    assert isinstance(request, HttpRequest)
    return render(request,  'SudokuSolver/about.html', {'title':'About', 'message':'Your application description page.', 'year':datetime.now().year,})

# Home page
def home (request):
    Globals.user = request.user.username

    # ********** POST Solve **********
    if request.method == 'POST' and 'solveit' in request.POST:
        request.session ['message'] = ""
        form = forms.GridForm (request.POST)
        if form.is_valid(): # If gridlist is empty, the form is not valid. This field is required!
            inputGrid = [0,]
            for i in range (1, 82, 1):
                if ('scell%02d' % i) in form.cleaned_data:
                    if form.cleaned_data ['scell%02d' % i] != "":
                        inputGrid.append (int (form.cleaned_data ['scell%02d' % i]))
                    else:
                        inputGrid.append (0)
            form.data = form.data.copy () # It is non-mutable so needs copying first
            if se.SuDoKuEngine (inputGrid) == 0:
                for i in range (1, 82, 1):
                    form.data ['tcell%02d' % i] = Globals.gridArea [i]
                    if form.cleaned_data ['scell%02d' % i] != "":
                        form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
            else:
                for i in range (1, 82, 1):
                    if inputGrid [i] != 0:
                        form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
                request.session ['message'] = "The grid is invalid!"
            request.session ['home_grid_data'] = inputGrid # Add form data to session
            request.session ['home_created_datetime'] = datetime.now ().strftime ("%Y-%m-%d %H:%M:%S")
            request.session ['home_time_taken'] = "%f" % ((int (Globals.timeEnd - Globals.timeStart)) / 1000000000)
            form.data['time_taken'] = request.session ['home_time_taken']
            form.data['created_datetime'] = request.session ['home_created_datetime'] 
            #sess_age = request.session.get_expiry_age () # Get the expiry
            #sess_exp = request.session.get_expire_at_browser_close ()
            form.data['log_window']=Globals.log
    # Reset grids
    elif request.method == 'POST' and 'resetit' in request.POST: # The reset button was clicked
        request.session ['message'] = ""
        form = forms.GridForm (request.POST)
        form.data = form.data.copy () # The data is not mutable, has to be copied
        for i in range (1, 82, 1):
            form.data ['scell%02d' % i] = ""
        for i in range (1, 82, 1):
            form.data ['tcell%02d' % i] = ""
        form.data ['log_window']=""
    # Hun lang
    elif request.method == 'POST' and 'langhun' in request.POST: # The Hungarian flag was clicked
        request.session ['message'] = ""
        form = forms.GridForm (request.POST)
        form.data = form.data.copy () # It is non-mutable so needs copying first
        Globals.langCode = 1
        if len (Globals.gridArea) != 0:
            for i in range (1, 82, 1):
                form.data ['tcell%02d' % i] = Globals.gridArea [i]
                if form.data ['scell%02d' % i] != "":
                    form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
        form.fields ['title'].widget.attrs ['placeholder'] = "Egy már előzőleg megoldott rács elnevezése"
        form.fields ['comment'].widget.attrs ['placeholder'] = "A Sudoku rács alkotójának megjegyzései"                                                                                            
        form.fields ['log_window'].widget.attrs ['placeholder'] = "********************* SuDoKu megoldó napló ******************\n**** Applikáció ami próbálgatást és visszalépést használ ****\n*** Technológia Python 3.7, Django 2.1 és cx_Oracle 6.4.1 ***\n"
    # Eng lang
    elif request.method == 'POST' and 'langeng' in request.POST: # The Hungarian flag was clicked
        request.session ['message'] = ""
        form = forms.GridForm (request.POST)
        form.data = form.data.copy () # It is non-mutable so needs copying first
        Globals.langCode = 0
        if len (Globals.gridArea) != 0:
            for i in range (1, 82, 1):
                form.data ['tcell%02d' % i] = Globals.gridArea [i]
                if form.data ['scell%02d' % i] != "":
                    form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
        form.fields ['title'].widget.attrs ['placeholder'] = "The title of a previously saved grid"
        form.fields ['comment'].widget.attrs ['placeholder'] = "Sudoku grid creator's comment"
        form.fields ['log_window'].widget.attrs ['placeholder'] = "********************** SuDoKu Solver log ********************\n****** Application using brute force and backtracking *******\n*** Powered by Python 3.7, Django 2.1 and cx_Oracle 6.4.1 ***\n"
    # Logout
    elif request.method == 'POST' and 'logout' in request.POST:
        request.session ['message'] = ""
        form = forms.GridForm (request.POST)

        form.fields['title'].initial = request.session ['home_title']
        form.fields['created_datetime'].initial = request.session ['home_created_datetime']
        form.fields['time_taken'].initial = request.session ['home_time_taken']
        form.fields['comment'].initial = request.session ['home_comment']
        grid = request.session['home_grid_data']

        if len (grid) != 0:
            for i in range (1, 82, 1):
                if grid[i] != 0:
                    form.fields ['scell%02d' % i].initial=str (grid[i])
        if len (Globals.gridArea) == 82 :
            for i in range (1, 82, 1):
                form.fields ['tcell%02d' % i].initial = Globals.gridArea [i]
                if form.fields ['scell%02d' % i].initial != None:
                    form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'

        # Save session variables as logout clears them
        temp_sess = {}
        temp_sess ['home_title'] = request.session ['home_title']
        temp_sess ['home_created_datetime'] = request.session ['home_created_datetime']
        temp_sess ['home_time_taken'] = request.session ['home_time_taken']
        temp_sess ['home_comment'] = request.session ['home_comment']
        temp_sess ['home_grid_data'] = request.session ['home_grid_data']
        
        logout (request)

        # Restore all session variables because logout flushes the session data
        request.session ['home_grid_data'] = temp_sess ['home_grid_data']
        request.session ['home_title'] = temp_sess ['home_title']
        request.session ['home_created_datetime'] = temp_sess ['home_created_datetime']
        request.session ['home_time_taken'] = temp_sess ['home_time_taken']
        request.session ['home_comment'] = temp_sess ['home_comment']
        if Globals.langCode == 0:
            request.session ['message'] = "User " + Globals.user + " logged out"
        else:
            request.session ['message'] = "Felhasználó " + Globals.user + " kijelentkezve"
        Globals.user = ""
        
    elif request.method == 'POST' and 'login' in request.POST:
        return redirect ('SudokuSolver:login')

    # ********** GET **********
    else:
        form = forms.GridForm ()
        referer = request.META.get ('HTTP_REFERER')
        # Grid loaded
        if referer and referer[referer.rfind ('/') +1:] == 'load' and 'loaded_grid_data' in request.session and request.session['load_it'] == True: # The home page was invoked by the load page so there is a loaded grid here
            grid_cells = request.session ['loaded_grid_data']
            #for i in range (1, 82, 1): # Erase previous grid if any
            #    form.data['scell%02d' % i] = ""
            inputGrid = []
            for i in range (0, 82, 1):
                inputGrid.append (0)
            for this_cell in grid_cells: # Fill in with the retrieved cell values
                form.fields['scell%02d' % this_cell [1]].initial = str (this_cell [2])
                inputGrid[this_cell [1]] = str (this_cell [2])
            request.session ['home_grid_data'] = inputGrid
            form.fields ['title'].initial = request.session ['loaded_title']
            request.session ['home_title'] = request.session ['loaded_title']
            form.fields ['created_datetime'].initial = request.session ['loaded_created_datetime']
            request.session ['home_created_datetime'] = request.session ['loaded_created_datetime']
            form.fields ['time_taken'].initial = request.session ['loaded_time_taken']
            request.session ['home_time_taken'] = request.session ['loaded_time_taken']
            form.fields ['comment'].initial = request.session ['loaded_comment']
            request.session ['home_comment'] = request.session ['loaded_comment']
            request.session ['load_it'] = False

            request.session ['loaded_grid_data'] = ""
            request.session ['loaded_title'] = ""
            request.session ['loaded_created_datetime'] = ""
            request.session ['loaded_time_taken'] = ""
            request.session ['loaded_comment'] = ""
            if Globals.langCode == 0:
                request.session ['message'] = "Grid loaded successfully"
            else:
                request.session ['message'] = "A rács sikeresen betöltve"
            Globals.gridArea = []
        # Grid saved
        elif referer and referer[referer.rfind ('/') +1:] == 'save' and 'saved_it' in request.session and request.session['saved_it'] == True: # The home page was invoked by the save page so there is a saved grid here
            form.fields ['title'].initial = request.session ['saved_title']
            form.fields ['created_datetime'].initial = request.session ['home_created_datetime']
            form.fields ['time_taken'].initial = request.session ['home_time_taken']
            form.fields ['comment'].initial = request.session ['saved_comment']
            grid = request.session['home_grid_data']
            if len (grid) != 0:
                for i in range (1, 82, 1):
                    if grid[i] != 0:
                        form.fields ['scell%02d' % i].initial=str (grid[i])
            if len (Globals.gridArea) == 82 :
                for i in range (1, 82, 1):
                    form.fields ['tcell%02d' % i].initial = Globals.gridArea [i]
                    if form.fields ['scell%02d' % i].initial != None:
                        form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
            request.session['saved_it'] = False

            request.session ['saved_title'] = ""
            request.session ['saved_comment'] = ""
            request.session ['message'] = ""

        # Clicked on the Home button
        elif referer and (referer[referer.rfind ('/') +1:] == 'load' or referer[referer.rfind ('/') +1:] == 'save' or referer[referer.rfind ('/') -5:] == 'login/'):
            form.fields ['title'].initial = request.session ['home_title']
            form.fields ['created_datetime'].initial = request.session ['home_created_datetime']
            form.fields ['time_taken'].initial = request.session ['home_time_taken']
            form.fields ['comment'].initial = request.session ['home_comment']
            grid = request.session['home_grid_data']
            if len (grid) != 0:
                for i in range (1, 82, 1):
                    if grid[i] != 0:
                        form.fields ['scell%02d' % i].initial=str (grid[i])
            if len (Globals.gridArea) == 82 :
                for i in range (1, 82, 1):
                    form.fields ['tcell%02d' % i].initial = Globals.gridArea [i]
                    if form.fields ['scell%02d' % i].initial != None:
                        form.fields ['tcell%02d' % i].widget.attrs ['class']='c b x'
            if referer[referer.rfind ('/') +1:] == 'load' or referer[referer.rfind ('/') +1:] == 'save':
                request.session ['message'] = ""
        else: # Home page loaded the first time. Create session keys
            request.session ['home_grid_data'] = []
            request.session ['home_title'] = ""
            request.session ['home_created_datetime'] = ""
            request.session ['home_time_taken'] = ""
            request.session ['home_comment'] = ""
            request.session ['message'] = ""

    Globals.randomVal = random.randint (1, 1000000)
    return render (request, 'SudokuSolver/HomePage.html', {'form': form, 'language':Globals.langCode, 'random': Globals.randomVal})

# ***** Load the grid *****
@login_required (login_url="login/")
def load (request):
    request.session ['message'] = ""
    request.session ['load_it'] = False
    if request.method == 'POST' and 'retrieveit' in request.POST:
        form = forms.LoadForm (request.POST, request.FILES)
        if form.is_valid ():
            grid_id = form.cleaned_data ['gridlist']
            grid_header = retrieveGridHeader (grid_id) # Fetch the header info from the Oracle db

            if type (grid_header) is not tuple:
                if grid_header [0] == '2':
                    request.session ['message'] = "Database error: " + Globals.oraError
            else:
                form.data = form.data.copy ()
                form.data['title'] = grid_header [1]
                form.data['created_datetime'] = grid_header[2]
                form.data['time_taken'] = grid_header [3]
                form.data['comment'] = grid_header [4]

                grid_cells = retrieveGridCells (grid_id) # Fetch the grid cell values from the oracle db

                if type (grid_cells) is not list:
                    if grid_cells [0] == '2':
                        request.session ['message'] = "Database error: " + Globals.oraError
                else:
                    for i in range (1, 82, 1): # Erase previous grid if any
                        form.data['scell%02d' % i] = ""
                    for this_cell in grid_cells: # Fill in with the retrieved cell values
                        form.data['scell%02d' % this_cell [1]] = str (this_cell [2])
                    request.session ['loaded_grid_data'] = grid_cells
                    request.session ['loaded_title'] = grid_header [1]
                    request.session ['loaded_created_datetime'] = str (grid_header [2])
                    request.session ['loaded_time_taken'] = grid_header [3]
                    request.session ['loaded_comment'] = grid_header [4]
                    if Globals.langCode == 0:
                        request.session ['message'] = "Grid info fetched successfully"
                    else:
                        request.session ['message'] = "Rács adatok sikeresen betöltve"
    elif request.method == 'POST' and 'loadit' in request.POST:
        form = forms.LoadForm (request.POST, request.FILES)
        request.session ['load_it'] = True
        if Globals.langCode == 0:
            request.session ['message'] = "Grid loaded successfully"
        else:
            request.session ['message'] = "Rács sikeresen betöltve"
        return HttpResponseRedirect('/Sudoku/home')
    else:
        form = forms.LoadForm ()
        if Globals.langCode == 1:
            form.fields ['title'].widget.attrs ['placeholder'] = "Egy már előzőleg megoldott rács elnevezése"
            form.fields ['comment'].widget.attrs ['placeholder'] = "A Sudoku rács alkotójának megjegyzései"
        else:
            form.fields ['title'].widget.attrs ['placeholder'] = "The title of a previously saved grid"
            form.fields ['comment'].widget.attrs ['placeholder'] = "Sudoku grid creator's comment"
    
    gridlist = getGridList (Globals.user) # Load from Oracle using model method
    if type (gridlist) is not list:
        if gridlist [0] == '1':
            request.session ['message'] = Globals.oraError
            request.session ['message'] = request.session ['message'].replace ('\n', ' * ')
        elif gridlist [0] == '2':
            request.session ['message'] = "Database error: " + Globals.oraError
        elif gridlist [0] == '3':
            request.session ['message'] = Globals.oraError
        elif gridlist [0] == '4':
            if Globals.langCode == 0:
                request.session ['message'] = 'No grid has yet been saved!'
            else:
                request.session ['message'] = 'Nincs még elmentett rács!'
        else:
            request.session ['message'] = ""
        return render (request, 'SudokuSolver/LoadGrid.html', {'form': form, 'language':Globals.langCode, 'random':Globals.randomVal})
    Globals.grid_list = gridlist
    if request.session ['message'] == "":
        if Globals.langCode == 0:
            request.session ['message'] = "List of saved grids fetched sucessfully"
        else:
            request.session ['message'] = "Ay elmentett rácsok listája betöltve"
    form.fields['gridlist'].widget.choices = Globals.grid_list # Fill in the drop-down list with the possible choices

    return render (request, 'SudokuSolver/LoadGrid.html', {'form': form, 'language':Globals.langCode, 'random':Globals.randomVal})

# ***** Save the grid *****
@login_required (login_url="login/")
def save (request):
    request.session ['message'] = ""
    if request.method == 'POST':
        form = forms.SaveForm (request.POST, request.FILES)
        if form.is_valid ():
            inputGrid = [0,]
            for i in range (1, 82, 1):
                if ('scell%02d' % i) in form.cleaned_data:
                    if form.cleaned_data ['scell%02d' % i] != "":
                        inputGrid.append (int (form.cleaned_data ['scell%02d' % i]))
                    else:
                        inputGrid.append (0)
            saveGrid (Globals.user, form.data['title'], form.data['created_datetime'], form.data['time_taken'], form.data['comment'], inputGrid)
            request.session ['saved_title'] = form.data ['title']
            request.session ['saved_comment'] = form.data ['comment']
            request.session ['saved_it'] = True
            if Globals.langCode == 0:
                request.session ['message'] = "Grid saved successfully"
            else:
                request.session ['message'] = "A rács sikeresen el lett mentve'"
    else:
        form = forms.SaveForm ()
        grid = request.session ['home_grid_data']
        if len (grid) != 0:
            for i in range (1, 82, 1):
                if grid[i] != 0:
                    form.fields ['scell%02d' % i].initial=str (grid[i])
            form.fields ['time_taken'].initial = request.session ['home_time_taken']
        if request.session ['home_created_datetime'] == "":
            form.fields ['created_datetime'].initial= datetime.now ().strftime ("%Y-%m-%d %H:%M:%S")
        else:
            form.fields ['created_datetime'].initial = request.session ['home_created_datetime']
        if Globals.langCode == 1:
            form.fields ['title'].widget.attrs ['placeholder'] = "Egy már előzőleg megoldott rács elnevezése"
            form.fields ['comment'].widget.attrs ['placeholder'] = "A Sudoku rács alkotójának megjegyzései"
        else:
            form.fields ['title'].widget.attrs ['placeholder'] = "The title of a previously saved grid"
            form.fields ['comment'].widget.attrs ['placeholder'] = "Sudoku grid creator's comment"

    return render(request, 'SudokuSolver/SaveGrid.html', {'form': form, 'language':Globals.langCode})

# ***** Delete the grid *****
@login_required (login_url="login/")
def delete (request):
    request.session ['message'] = ""
    Globals.user_change = False
    grid_deleted = False
    # User list selection changed
    if request.method == 'POST' and 'submit_param' in request.POST and request.POST ['submit_param'] == 'user_changed':
        Globals.user_change = True
        form = forms.DeleteForm (request.POST, request.FILES)
        if form.is_valid () or True : # If there is no saved grid yet for a given user, the dropdown is empty and therefore invalid as it is a required field
            Globals.selected_user = int (form.cleaned_data ['userlist']) - 1
            Globals.selected_username = getUserName (Globals.selected_user + 1)
            gridlist = getGridList (Globals.selected_username) # Load from Oracle using model method
            if type (gridlist) is not list:
                if gridlist [0] == '1':
                    request.session ['message'] = Globals.oraError
                    request.session ['message'] = request.session ['message'].replace ('\n', ' * ')
                elif gridlist [0] == '2':
                    request.session ['message'] = "Database error: " + Globals.oraError
                elif gridlist [0] == '3':
                    request.session ['message'] = Globals.oraError
                elif gridlist [0] == '4':
                    if Globals.langCode == 0:
                        request.session ['message'] = Globals.selected_username + ' has no saved grid!'
                    else:
                        request.session ['message'] = Globals.selected_username + ': nincs elmentett rácsa!'
                    form.data = form.data.copy () # It is non-mutable so needs copying first
                    form.data ['title'] = ''
                    form.data ['created_datetime'] = ''
                    form.data ['time_taken'] = ''
                    form.data ['comment'] = ''
                    for i in range (1, 82, 1): # Erase grid
                         form.data ['scell%02d' % i] = ""
            else:
                grid_id = gridlist[0][0]
                grid_header = retrieveGridHeader (grid_id) # Fetch the header info from the Oracle db

                if type (grid_header) is not tuple:
                    if grid_header [0] == '2':
                        request.session ['message'] = "Database error: " + Globals.oraError
                else:
                    form.data = form.data.copy ()
                    form.data ['title'] = grid_header [1]
                    form.data ['created_datetime'] = grid_header[2]
                    form.data ['time_taken'] = grid_header [3]
                    form.data ['comment'] = grid_header [4]

                    grid_cells = retrieveGridCells (grid_id) # Fetch the grid cell values from the oracle db

                    if type (grid_cells) is not list:
                        if grid_cells [0] == '2':
                            request.session ['message'] = "Database error: " + Globals.oraError
                    else:
                        for i in range (1, 82, 1): # Erase previous grid if any
                            form.data ['scell%02d' % i] = ""
                        for this_cell in grid_cells: # Fill in with the retrieved cell values
                            form.data ['scell%02d' % this_cell [1]] = str (this_cell [2])
                        #request.session ['message'] = "Grid info fetched successfully"

    # Grid list selection changed
    elif request.method == 'POST' and 'submit_param' in request.POST and request.POST ['submit_param'] == 'list_changed':
        form = forms.DeleteForm (request.POST, request.FILES)
        if form.is_valid ():
            Globals.selected_user = int (form.cleaned_data ['userlist']) - 1
            grid_id = form.cleaned_data ['gridlist']
            grid_header = retrieveGridHeader (grid_id) # Fetch the header info from the Oracle db

            if type (grid_header) is not tuple:
                if grid_header [0] == '2':
                    request.session ['message'] = "Database error: " + Globals.oraError
            else:
                form.data = form.data.copy ()
                form.data ['title'] = grid_header [1]
                form.data ['created_datetime'] = grid_header[2]
                form.data ['time_taken'] = grid_header [3]
                form.data ['comment'] = grid_header [4]

                grid_cells = retrieveGridCells (grid_id) # Fetch the grid cell values from the oracle db

                if type (grid_cells) is not list:
                    if grid_cells [0] == '2':
                        request.session ['message'] = "Database error: " + Globals.oraError
                else:
                    for i in range (1, 82, 1): # Erase previous grid if any
                        form.data ['scell%02d' % i] = ""
                    for this_cell in grid_cells: # Fill in with the retrieved cell values
                        form.data ['scell%02d' % this_cell [1]] = str (this_cell [2])

                    #request.session ['message'] = "Grid info fetched successfully"
    # Delete button clicked
    elif request.method == 'POST' and 'deleteit' in request.POST:
        form = forms.DeleteForm (request.POST, request.FILES)
        if form.is_valid ():
            grid_id = form.cleaned_data ['gridlist']
            retval = deleteGridHeader (grid_id)
            if retval == '1':
                request.session ['message'] = Globals.oraError
                request.session ['message'] = request.session ['message'].replace ('\n', ' * ')
            elif retval == '3':
                request.session ['message'] = Globals.oraError
            elif retval == '5':
                if Globals.langCode == 0:
                    request.session ['message'] = "Grid could not be deleted"
                else:
                     request.session ['message'] = "A rácsot nem sikerült eltörölni"
            elif retval == '2':
                request.session ['message'] = "Database error: " + Globals.oraError
            else:
                if Globals.langCode == 0:
                    request.session ['message'] = "Grid deleted successfully"
                else:
                    request.session ['message'] = "A rács eltörölve sikeresen"
                grid_deleted = True
                form.data = form.data.copy () # It is non-mutable so needs copying first
                form.data ['title'] = ''
                form.data ['created_datetime'] = ''
                form.data ['time_taken'] = ''
                form.data ['comment'] = ''
                for i in range (1, 82, 1): # Erase grid
                    form.data ['scell%02d' % i] = ""

    else:
        form = forms.DeleteForm ()
        if Globals.langCode == 1:
            form.fields ['title'].widget.attrs ['placeholder'] = "Egy már előzőleg megoldott rács elnevezése"
            form.fields ['comment'].widget.attrs ['placeholder'] = "A Sudoku rács alkotójának megjegyzései"
        else:
            form.fields ['title'].widget.attrs ['placeholder'] = "The title of a previously saved grid"
            form.fields ['comment'].widget.attrs ['placeholder'] = "Sudoku grid creator's comment"
    
    # Fetch and populate the user list
    userlist = getUserList () # Load from Oracle using model method
    if type (userlist) is not list:
        if userlist [0] == '1':
            request.session ['message'] = Globals.oraError
            request.session ['message'] = request.session ['message'].replace ('\n', ' * ')
        elif userlist [0] == '2':
            request.session ['message'] = "Database error: " + Globals.oraError
        elif userlist [0] == '3':
            request.session ['message'] = Globals.oraError
        elif userlist [0] == '4':
            if Globals.langCode == 0:
                request.session ['message'] = 'No user found!'
            else:
                request.session ['message'] = 'Nincs egy felhasználó sem!'
        else:
            request.session ['message'] = ""
        return render (request, 'SudokuSolver/DeleteGrid.html', {'form': form, 'language':Globals.langCode, 'random':Globals.randomVal})
    Globals.user_list = userlist
    form.fields ['userlist'].widget.choices = Globals.user_list # Fill in the drop-down list with the possible choices

    # Fetch and populate the grid list of the user
    if request.method == 'GET': # GET request, first time here
        gridlist = getGridList (userlist[0][1]) # Load from Oracle using model method
        Globals.selected_username = userlist[0][1]
    else:
        gridlist = getGridList (Globals.selected_username)
    if type (gridlist) is not list:
        if gridlist [0] == '1':
            request.session ['message'] = Globals.oraError
            request.session ['message'] = request.session ['message'].replace ('\n', ' * ')
        elif gridlist [0] == '2':
            request.session ['message'] = "Database error: " + Globals.oraError
        elif gridlist [0] == '3':
            request.session ['message'] = Globals.oraError
        elif gridlist [0] == '4':
            if Globals.langCode == 0:
                request.session ['message'] = Globals.selected_username + ' has no saved grid!'
            else:
                request.session ['message'] = Globals.selected_username + ': nincs elmentett rácsa!'
            form.data = form.data.copy () # It is non-mutable so needs copying first
            form.data ['title'] = ''
            form.data ['created_datetime'] = ''
            form.data ['time_taken'] = ''
            form.data ['comment'] = ''
            for i in range (1, 82, 1): # Erase grid
                form.data ['scell%02d' % i] = ""
        else:
            request.session ['message'] = ""
        return render (request, 'SudokuSolver/DeleteGrid.html', {'form': form, 'language':Globals.langCode, 'random':Globals.randomVal})
    Globals.grid_list = gridlist

    grid_id = gridlist [0][0]
    grid_header = retrieveGridHeader (grid_id) # Fetch the header info from the Oracle db

    if type (grid_header) is not tuple:
        if grid_header [0] == '2':
            request.session ['message'] = "Database error: " + Globals.oraError
    else:
        if grid_deleted:
            grid_deleted = False
            form.data = form.data.copy () # It is non-mutable so needs copying first
            form.data ['title'] = grid_header [1]
            form.data ['created_datetime'] = grid_header[2]
            form.data ['time_taken'] = grid_header [3]
            form.data ['comment'] = grid_header [4]

            grid_cells = retrieveGridCells (grid_id) # Fetch the grid cell values from the oracle db

            if type (grid_cells) is not list:
                if grid_cells [0] == '2':
                     request.session ['message'] = "Database error: " + Globals.oraError
            else:
                for i in range (1, 82, 1): # Erase previous grid if any
                    form.data ['scell%02d' % i] = ""
                for this_cell in grid_cells: # Fill in with the retrieved cell values
                    form.data ['scell%02d' % this_cell [1]] = str (this_cell [2])

        else:
            form.fields ['title'].initial = grid_header [1]
            form.fields ['created_datetime'].initial = grid_header[2]
            form.fields ['time_taken'].initial = grid_header [3]
            form.fields ['comment'].initial = grid_header [4]

            grid_cells = retrieveGridCells (grid_id) # Fetch the grid cell values from the oracle db

            if type (grid_cells) is not list:
                if grid_cells [0] == '2':
                     request.session ['message'] = "Database error: " + Globals.oraError
            else:
                for i in range (1, 82, 1): # Erase previous grid if any
                    form.fields ['scell%02d' % i].initial = ""
                for this_cell in grid_cells: # Fill in with the retrieved cell values
                    form.fields ['scell%02d' % this_cell [1]].initial = str (this_cell [2])

    if request.session ['message'] == "":
        pass
        #request.session ['message'] = "List of saved grids fetched sucessfully"
    form.fields ['gridlist'].widget.choices = Globals.grid_list # Fill in the drop-down list with the possible choices

    return render (request, 'SudokuSolver/DeleteGrid.html', {'form': form, 'language':Globals.langCode, 'random':Globals.randomVal})

# Test. To understand HTML positioning 
def test1 (request):
    return render (request, 'SudokuSolver/Test.html', {})

def test2 (request):
    return render (request, 'SudokuSolver/Test2.html', {})
