"""
Definition of forms.
"""

from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.utils.translation import ugettext_lazy as _
from . import models
import SudokuSolver.code.Globals as Globals

# Grid form
class GridForm(forms.Form):
    def __init__(self, *args, **kwargs):
        super ().__init__(*args, **kwargs)
        count = 0
        bg = "#ffff99"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#c5c5c5"
            elif count == 54:
                bg = "#ffff99"
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#c5c5c5":
                    bg = "#ffff99"
                    three = 1
                elif three == 4 and bg == "#ffff99":
                    bg = "#c5c5c5"
                    three = 1
                self.fields["scell%02d" % count] = forms.CharField (max_length=1, required=False, widget=forms.TextInput (attrs={'style': 'background-color:' + bg, 'pattern': '[0-9]', 'class':'c b', 'celltype':'s', 'onKeyPress':'return (event.charCode >= 49 && event.charCode <= 57) or event.charCode = 8 event.charCode = 127'}))
        count = 0
        bg = "#c5c5c5"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#ffff99"
            elif count == 54:
                bg = "#c5c5c5"
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#ffff99":
                    bg = "#c5c5c5"
                    three = 1
                elif three == 4 and bg == "#c5c5c5":
                    bg = "#ffff99"
                    three = 1
                self.fields["tcell%02d" % count] = forms.CharField (max_length=1, required=False, widget=forms.TextInput (attrs={'style': 'background-color:' + bg, 'pattern': '[0-9]', 'class':'c b', 'celltype':'t', 'readonly':'True'}))

    title = forms.CharField (max_length=50, required=False, widget=forms.TextInput (attrs={'size':'54', 'class':'fieldwidget', 'placeholder':'The title of a previously saved grid', 'readonly':'True'})) # Default: required = True
    created_datetime = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget','readonly':'True'}))
    time_taken = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget', 'readonly':'True'}))
    comment = forms.CharField (max_length=50, required=False, widget=forms.Textarea (attrs={'class':'fieldwidget','readonly':'True', 'rows':3, 'cols':41, 'placeholder':'Sudoku grid creator\'s comment'}))
    log_window = forms.CharField (required=False, widget=forms.Textarea (attrs={'class':'console', 'rows':30, 'cols':59, 'readonly':'True', 'placeholder': '********************** SuDoKu Solver log ********************\n****** Application using brute force and backtracking *******\n*** Powered by Python 3.7, Django 2.1 and cx_Oracle 6.4.1 ***\n'}))

# Load form
class LoadForm (forms.Form):
    def __init__(self, *args, **kwargs):
        super ().__init__(*args, **kwargs)
        count = 0 # Create a chequered design to highlight 9-number groups in the grid
        bg = "#ffff99"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#c5c5c5" # Light yellow
            elif count == 54:
                bg = "#ffff99" # Grey
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#c5c5c5":
                    bg = "#ffff99"
                    three = 1
                elif three == 4 and bg == "#ffff99":
                    bg = "#c5c5c5"
                    three = 1
                self.fields["scell%02d" % count] = forms.CharField (max_length=1, required=False, widget=forms.TextInput (attrs={'style': 'background-color:' + bg, 'pattern': '[0-9]', 'class':'c b', 'celltype':'s', 'onKeyPress':'return event.charCode >= 49 && event.charCode <= 57'}))

    
    gridlist = forms.CharField (label='Load one of your saved grids', widget = forms.Select (attrs={'style':'width:295px'}, choices=Globals.grid_list))
    title = forms.CharField (max_length=50, required=False, widget=forms.TextInput (attrs={'size':'54', 'class':'fieldwidget', 'placeholder':'The title of a previously saved grid', 'readonly':'True'})) # Default: required = True
    created_datetime = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget','readonly':'True'}))
    time_taken = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget', 'readonly':'True'}))
    comment = forms.CharField (max_length=50, required=False, widget=forms.Textarea (attrs={'class':'fieldwidget','readonly':'True', 'rows':3, 'cols':41, 'placeholder':'Sudoku grid creator\'s comment'}))

# Save form
class SaveForm (forms.Form):
    def __init__(self, *args, **kwargs):
        super ().__init__(*args, **kwargs)
        count = 0 # Create a chequered design to highlight 9-number groups in the grid
        bg = "#ffff99"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#c5c5c5" # Light yellow
            elif count == 54:
                bg = "#ffff99" # Grey
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#c5c5c5":
                    bg = "#ffff99"
                    three = 1
                elif three == 4 and bg == "#ffff99":
                    bg = "#c5c5c5"
                    three = 1
                self.fields["scell%02d" % count] = forms.CharField (max_length=1, required=False, widget=forms.TextInput (attrs={'style': 'background-color:' + bg, 'pattern': '[0-9]', 'class':'c b', 'celltype':'s', 'onKeyPress':'return event.charCode >= 49 && event.charCode <= 57'}))

    if Globals.langCode == 0:
        title = forms.CharField (max_length=50, required=True, widget=forms.TextInput (attrs={'size':'54', 'class':'fieldwidget', 'placeholder':'Please give a title to this grid'})) # Default: required = True
    else:
        title = forms.CharField (max_length=50, required=True, widget=forms.TextInput (attrs={'size':'54', 'class':'fieldwidget', 'placeholder':'Adja meg ennek a rácsnak a címét'})) # Default: required = True
    
    created_datetime = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget','readonly':'True'}))
    time_taken = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget', 'readonly':'True'}))
    comment = forms.CharField (max_length=50, required=True, widget=forms.Textarea (attrs={'class':'fieldwidget', 'rows':3, 'cols':41, 'placeholder':'Sudoku grid creator\'s comment'}))
 
    def clean(self):
        cleaned_data = super ().clean()
        title = cleaned_data.get('title')
        if title: # Not a NoneType
            if len (title) < 5:
                raise forms.ValidationError ({'title': 'Must be at least 5 chars!'}) # Field specific error
        comment = cleaned_data.get ('comment')
        if comment: # Not a NoneType
            if len (comment) < 5:
                raise forms.ValidationError({'comment': 'Add some meaningful comment please!'}) # Field specific error
        if (not title) or (not comment):
            raise forms.ValidationError ('Please correct the below issues before saving the grid!') # This is going to be a non-field error

# Delete form
class DeleteForm (forms.Form):
    def __init__(self, *args, **kwargs):
        super ().__init__(*args, **kwargs)
        count = 0 # Create a chequered design to highlight 9-number groups in the grid
        bg = "#ffff99"
        for j in range (1, 10, 1):
            three = 0
            if count == 27:
                bg = "#c5c5c5" # Light yellow
            elif count == 54:
                bg = "#ffff99" # Grey
            for i in range (0, 9, 1):
                count += 1
                three += 1
                if three == 4 and bg == "#c5c5c5":
                    bg = "#ffff99"
                    three = 1
                elif three == 4 and bg == "#ffff99":
                    bg = "#c5c5c5"
                    three = 1
                self.fields["scell%02d" % count] = forms.CharField (max_length=1, required=False, widget=forms.TextInput (attrs={'style': 'background-color:' + bg, 'pattern': '[0-9]', 'class':'c b', 'celltype':'s', 'onKeyPress':'return event.charCode >= 49 && event.charCode <= 57'}))

    
    userlist = forms.CharField (label='Users', widget = forms.Select (attrs={'style':'width:295px', 'onChange':'document.forms[0].submit_param.value = "user_changed";this.form.submit  ()'}, choices=Globals.user_list))
    gridlist = forms.CharField (label='Load user\'s grids', widget = forms.Select (attrs={'style':'width:295px', 'onChange':'document.forms[0].submit_param.value = "list_changed";this.form.submit  ()'}, choices=Globals.grid_list))
    title = forms.CharField (max_length=50, required=False, widget=forms.TextInput (attrs={'size':'54', 'class':'fieldwidget', 'placeholder':'The title of a previously saved grid', 'readonly':'True'})) # Default: required = True
    created_datetime = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget','readonly':'True'}))
    time_taken = forms.CharField (required=False, widget=forms.TextInput (attrs={'class':'fieldwidget', 'readonly':'True'}))
    comment = forms.CharField (max_length=50, required=False, widget=forms.Textarea (attrs={'class':'fieldwidget','readonly':'True', 'rows':3, 'cols':41, 'placeholder':'Sudoku grid creator\'s comment'}))
