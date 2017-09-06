using Microsoft.AspNetCore.Mvc.RazorPages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Plain.Models
{
    public class IndexModel : PageModel
    {
        public string Message { get; private set; } = "In page model: ";

        public void OnGet()
        {
            Message += User.Identity.Name;
        }
    }
}
