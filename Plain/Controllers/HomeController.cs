
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Plain.Models;

namespace Plain.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        [Authorize]
        public IActionResult Windows()
        {
            IndexModel myModel = new IndexModel();
            return Content ("You are " + User.Identity.Name +  "; Authentication Type:" + User.Identity.AuthenticationType );
        }

        [AllowAnonymous]
        public IActionResult Anonymous()
        {
            return Content("You are anonymous");
        }
    }
}
