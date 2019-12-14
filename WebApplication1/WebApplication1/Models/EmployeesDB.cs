using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication1.Models
{
    public class EmployeesDB
    {
        public List<Employee> GetEmployees ()
        {
            Employee emp ;
            List<Employee> employees = new List<Employee> () ; // Generic List of Employee class type
            
            emp = new Employee () ; // Create employees hard-coded
            emp.FirstName = "Csacsi" ;
            emp.LastName = "Riedlinger" ;
            emp.Salary = 14000 ;
            employees.Add (emp) ;

            emp = new Employee () ;
            emp.FirstName = "Zsurni" ;
            emp.LastName = "Fenyvesi" ;
            emp.Salary = 16000 ;
            employees.Add (emp) ;

            emp = new Employee () ;
            emp.FirstName = "Daisy";
            emp.LastName = "Dogie" ;
            emp.Salary = 20000 ;
            employees.Add (emp) ;

            // Fetch employees from DB

            return employees ;
        }
    }
}