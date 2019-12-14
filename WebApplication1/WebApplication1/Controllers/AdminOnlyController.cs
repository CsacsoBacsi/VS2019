using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApplication1.Filters ;

namespace WebApplication1.Controllers
{
    public class AdminOnlyController : Controller
    {
        // Using a filter. Created under the Filters folder
        [AdminFilter]
        public ActionResult Index () // Can not be accessed by /AdminOnly/Index
        {
            return View ("AdminOnly") ; // Without the name, a view called Index would be searched
        }
    }
}