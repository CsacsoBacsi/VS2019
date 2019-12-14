using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc ;
using WebApplication1.Models ;
using WebApplication1.ViewModels;
using Oracle.DataAccess.Client ;
using Oracle.DataAccess.Types ;

namespace WebApplication1.Controllers
{
    public class TestController : Controller
    {
        MyView2Bag MV2B = new MyView2Bag () ;
        Boolean fromForm = false ;

        public string GetString () // http://localhost:55777/Test/GetString Use the controller name followed by the action name
        {
            return "Hello World is old now. It’s time for wassup bro ;)";
        }

        public Customer GetCustomer ()
        {
            Customer c = new Customer () ;
            c.CustomerName = "Miss Marple" ;
            c.Address = "15 Agatha Christie avenue" ;
            return c; // Returns WebApplication1.Controllers.Customer which is namespace + classname given by the default ToString () method
        }

        [NonAction]
        public string SimpleMethod () // Non-action method. Can not be called from the URL
        {
            return "Hi, I am not an action method"; // Returns this plain text
        }

        public ActionResult GetView () // ActionResult is abstract, its child is ViewResult and also ContentResult. The latter only returns strings
        {
            Employee emp = new Employee () ;
            emp.FirstName = "Zsurni" ;
            emp.LastName = "Szerelmem" ;
            emp.Salary = 120000 ;
            ViewData ["Employee"] = emp ; // Sends data to the view. Not a recomended method. Instead, use strongly typed views and pass the object that way (as on below line)

            EmployeeViewModel vmEmp = new EmployeeViewModel () ; // With ViewModel
            vmEmp.EmployeeName = emp.FirstName + " " + emp.LastName ; // Logic is moved here from the view
            vmEmp.Salary = emp.Salary.ToString ("C") ;
            if (emp.Salary > 15000) // Logic is now here, not in the view
            {
                vmEmp.SalaryColor = "yellow" ;
            }
            else
            {
                vmEmp.SalaryColor = "green" ;
            }

            vmEmp.UserName = "Admin" ;

            return View ("MyView", vmEmp) ; // Name of the cshtml file in the Views/Test folder. This view belongs to the Test controller. Views in the Shared folder belong to all controllers
        }

        [Authorize] // If there is an authenticated cookie present only then can this execute
        public ActionResult GetView2 ()
        {
            EmployeesDB edb = new EmployeesDB () ; // Holds several Employee instances
            EmployeeViewModel evm; // ViewModel for Employee instances to derive various properties such as EmployeeName and SalaryColor
            EmployeeListViewModel elvm = new EmployeeListViewModel () ; // Holds a List of EmployeeviewModel instances as well as the manager's name
            List<EmployeeViewModel> evml = new List<EmployeeViewModel> () ; // Will hold a list of EmployeeViewModel-s that we use to set the elvm's Employees List property
            Employee empDB ; // Holds an individual Employee

            goto GetFromDB ;

            List<Employee> employees = edb.GetEmployees () ; // Get the list of Employee-s from the DB
            
            foreach (Employee emp in employees) // Turn each Employee into an EmployeeViewModel
            {
                evm = new EmployeeViewModel () ; // Reuse evm. Each time it is a different persistent instance
                evm.EmployeeName = emp.FirstName + " " + emp.LastName ; // Derive full name
                evm.Salary = emp.Salary.ToString ("C") ; // Derive currency equivalent of the salary
                if (emp.Salary > 15000) // Derive Salary color
                {
                    evm.SalaryColor = "yellow" ;
                }
                else
                {
                    evm.SalaryColor = "green" ;
                }
                evml.Add (evm); // Add this EmployeeViewModel instance to the List of EmployeeViewModel-s
            }
            elvm.Employees = evml; // Set the Employees property to the List of EmployeeViewModel-s
            elvm.Manager = "Stuart Brown"; // There is only one Manager per EmployeeListViewModel

 GetFromDB:
            OracleConnection conn = new OracleConnection ("Data Source=pdborcl; User Id=CSACSO; Password=zsurni; ");
            conn.Open ();

            OracleCommand cmd = conn.CreateCommand () ;
            // Fetch the rows from the table
            cmd.CommandText = "SELECT FIRSTNAME, LASTNAME, SALARY FROM CSACSO.EMPLOYEES" ;
            cmd.CommandType = System.Data.CommandType.Text ; // SqlDataSource text

            OracleDataReader dr = cmd.ExecuteReader () ;
            while (dr.Read ())
            {
                evm = new EmployeeViewModel () ; // Reuse evm. Each time it is a different persistent instance
                empDB = new Employee () ;
                empDB.FirstName = dr[0].ToString () ;
                empDB.LastName  = dr[1].ToString () ;
                empDB.Salary    = int.Parse (dr[2].ToString ()) ;

                evm.EmployeeName = empDB.FirstName + " " + empDB.LastName ; // Derive full name
                evm.Salary = empDB.Salary.ToString ("C") ; // Derive currency equivalent of the salary
                if (empDB.Salary > 15000) // Derive Salary color
                {
                    evm.SalaryColor = "yellow" ;
                }
                else
                {
                    evm.SalaryColor = "green" ;
                }

                evml.Add (evm) ; // Add this EmployeeViewModel instance to the List of EmployeeViewModel-s
            }

            conn.Close () ;

            elvm.Employees = evml ; // Set the Employees property to the List of EmployeeViewModel-s
            elvm.Manager = "Stuart Brown" ; // There is only one Manager per EmployeeListViewModel

            MV2B.ELVM = elvm ;

            if (!fromForm) // Comes from a form hadler so do not initialize the value
            {
                MV2B.FODVM = new FormOneDataViewModel () ;
                MV2B.FODVM.TextBoxIntData = 0 ;
            }

            MV2B.ELVM.UserName = User.Identity.Name ;

            elvm.FooterData = new FooterViewModel ();
            elvm.FooterData.CompanyName = "BiXtorp Ltd";//Can be set to dynamic value
            elvm.FooterData.Year = DateTime.Now.Year.ToString ();

            return View ("MyView2", MV2B) ; // Pass this EmployeeListViewModel to the view
        }

        [HttpPost]
        public ActionResult FormOneHandlerST (WebApplication1.ViewModels.MyView2Bag formData) // Strongly typed version
        {
            int i = formData.FODVM.TextBoxIntData ;
            MV2B.FODVM = formData.FODVM ;
            MV2B.FODVM.TextBoxIntData = i * 2 ;
            //formData.ELVM.Manager = "Noone" ;
            if (string.IsNullOrEmpty (formData.FODVM.TextBoxStringData))
            {
                ModelState.AddModelError ("TextBoxStringData", "Text data is required");
            }
            fromForm = true ;
            return GetView2 () ; // Signals that it comes from a form handler
        }

        public ActionResult Admin ()
        {
            if (Convert.ToBoolean (Session["IsAdmin"]))
            {
                return PartialView ("AdminView") ;
            }
            else
            {
                return new EmptyResult () ;
            }
        }
    }

    public class Customer
    {
        public string CustomerName { get; set; }
        public string Address { get; set; }

        public override string ToString () // To override the default behaviour of ToString ()
        {
            return "Customer name: " + this.CustomerName + " and address: " + this.Address ;
        }
    }
}