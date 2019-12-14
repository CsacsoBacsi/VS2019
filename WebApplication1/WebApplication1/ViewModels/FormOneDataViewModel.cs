using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace WebApplication1.ViewModels
{
    public class FormOneDataViewModel
    {
        public string TextBoxStringData { get; set; }

        [IntFieldValidation]
        public int TextBoxIntData { get; set; }

        public bool CheckBoxData { get; set; }
    }

    public class IntFieldValidation : ValidationAttribute
    {
        protected override ValidationResult IsValid (object value, ValidationContext validationContext)
        {
            if (value == null) // Checking for Empty Value
            {
                return new ValidationResult ("Please Provide First Name");
            }
            else
            {
                if (int.Parse (value.ToString ()) <= 100)
                {
                    return new ValidationResult ("Must be greater than 100!");
                }
            }
            return ValidationResult.Success;
        }
    }
}