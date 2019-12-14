using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WebApplication1.Models;

namespace WebApplication1.Controllers
{
    public class AuthController : Controller
    {
        // GET: Authentication
        public ActionResult Login () // To display the login page /Auth/Login will invoke it
        {
            return View () ; // Will invoke Login view (same name as action)
        }

        [HttpPost]
        public ActionResult DoLogin (UserDetails u) // This is to process the click on the login button
        {
            if (ModelState.IsValid)
            {
                goto CheckRole ; // There is an enahnced version of this further below
                if (IsValidUser (u)) // User validation only (without setting the "role" session variable
                {
                    FormsAuthentication.SetAuthCookie (u.UserName, true) ; // Sets an uthentication ticket
                    HttpCookie Cookie = HttpContext.Response.Cookies[FormsAuthentication.FormsCookieName] ;
                    Cookie.Expires = DateTime.Now.Add (new TimeSpan (1, 0, 0, 0));
                    return RedirectToAction ("GetView2", "Test") ;
                }

        CheckRole:
                UserStatus status = GetUserValidity (u) ; // The UserDetails model holds all the login info (User, Pwd)

                bool IsAdmin = false ;
                if (status == UserStatus.AuthenticatedAdmin)
                {
                    IsAdmin = true ;
                }
                else if (status == UserStatus.AuthenticatedUser)
                {
                    IsAdmin = false ;
                }
                else
                {
                    ModelState.AddModelError ("CredentialError", "Invalid Username or Password") ; // ValidationMessage in the Login view displays the error
                    return View ("Login") ;
                }
                FormsAuthentication.SetAuthCookie (u.UserName, false) ;

                HttpCookie myCookie = HttpContext.Response.Cookies[FormsAuthentication.FormsCookieName] ;
                FormsAuthenticationTicket authTicket = FormsAuthentication.Decrypt (myCookie.Value) ;
                
                Session["IsAdmin"] = IsAdmin ; // Sets a session variable (in the Session collection)
                return RedirectToAction ("GetView2", "Test") ; // Test/GetView2 action gets invoked if authenticated successfully
            }
            else
            {
                return View ("Login") ; // Else just redisplay the view
            }

        }

        public bool IsValidUser (UserDetails u) // This has been deprecated
        {
            if (u.UserName == "Admin" && u.Password == "Admin")
            {
                return true ;
            }
            else
            {
                return false ;
            }           
        }

        public UserStatus GetUserValidity (UserDetails u)
        {
            if (u.UserName == "Admin" && u.Password == "Admin") // These hard-coded values could come from a database
            {
                return UserStatus.AuthenticatedAdmin ; // Uses an enum value
            }
            else if (u.UserName == "Csacsi" && u.Password == "Csacsi")
            {
                return UserStatus.AuthenticatedUser ;
            }
            else
            {
                return UserStatus.NonAuthenticatedUser ;
            }
        }

        public ActionResult Logout ()
        {
            FormsAuthentication.SignOut () ; // Erases the cookie authentication ticket
            return RedirectToAction ("Login") ; // Back to the login screen
        }
    }
}