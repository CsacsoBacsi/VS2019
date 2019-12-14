
function IsValid() {
    var FinalErrorMessage = "Errors:\n" ;

    if (document.getElementById ('TBSD').value == "") {
        FinalErrorMessage += 'Text: should not be empty \n' ;
    }
    if (document.getElementById('TBID').value == "") {
        FinalErrorMessage += 'Number: should not be empty \n' ;
    }
    if (isNaN (document.getElementById('TBID').value)) {
        FinalErrorMessage += 'Number: Enter valid salary \n' ;
    }
    if (document.getElementById('TBID').value <= 1000) {
        FinalErrorMessage += 'Number: must be at least 1000 \n';
    }

    if (FinalErrorMessage != "Errors:\n") {
        alert (FinalErrorMessage) ;
        return false ; // Form does not get submitted
    }
    else {
        return true ;
    }
}