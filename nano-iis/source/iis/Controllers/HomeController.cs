
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Plain.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        [Authorize(Roles = "Domain Admins")]
        public IActionResult Windows()
        {
            
            return Content ("You are " + User.Identity.Name +  "; Authentication Type:" + User.Identity.AuthenticationType );
        }
        [Authorize(Roles = "Domain Users")]
        public IActionResult Users()
        {

            return Content("You are " + User.Identity.Name + "; Authentication Type:" + User.Identity.AuthenticationType);
        }

        public IActionResult LocalUsers()
        {

            return Content("You are " + User.Identity.Name + "; Authentication Type:" + User.Identity.AuthenticationType);
        }

        [AllowAnonymous]
        public IActionResult Anonymous()
        {
            return Content ("You are " + User.Identity.Name +  "; Authentication Type:" + User.Identity.AuthenticationType );;
        }
    }
}
