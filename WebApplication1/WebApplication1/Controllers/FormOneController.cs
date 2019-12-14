using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebApplication1.Controllers
{
    public class FormOneController : Controller
    {
        // GET: FormOne
        public ActionResult Index ()
        {
            return View () ;
        }

        [HttpPost] // Can not be invoked via a URL which is a GET
        public ActionResult FormOneHandlerWT (string TextBoxStringData, int TextBoxIntData, string CheckBoxData) // Weakly typed version
        {
            string sd = TextBoxStringData ; // The fields in the form come one by one. Name must match
            int id = TextBoxIntData ;
            string cd = CheckBoxData ;
            return RedirectToAction ("GetView2", "Test") ;
        }

        [HttpPost] // Can not be invoked via a URL which is a GET
        public ActionResult FormOneHandlerST (WebApplication1.ViewModels.MyView2Bag formData) // Strongly typed version. View is of type MyView2Bag
        {
            int i = formData.FODVM.TextBoxIntData ; // FormOneDataViewModel
            //formData.ELVM.Manager = "Noone" ;
            if (string.IsNullOrEmpty (formData.FODVM.TextBoxStringData))
            {
                ModelState.AddModelError ("TextBoxStringData", "Text data is required") ;
                return View ("MyView2", formData) ;
            }

            return RedirectToAction ("Test/GetView2", "Test") ;
        }
    }
}