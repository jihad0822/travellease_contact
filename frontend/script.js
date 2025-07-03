document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("inquiryForm")
  const submitBtn = form.querySelector(".submit-btn")
  const btnText = submitBtn.querySelector(".btn-text")
  const btnLoading = submitBtn.querySelector(".btn-loading")
  const successMessage = document.getElementById("successMessage")

  // API Gateway URL
  // Hardcoded for development
  const apiGatewayUrl = ""

  // Form validation rules
  const validationRules = {
    firstName: {
      required: true,
      minLength: 2,
      message: "First name must be at least 2 characters long",
    },
    lastName: {
      required: true,
      minLength: 2,
      message: "Last name must be at least 2 characters long",
    },
    email: {
      required: true,
      pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: "Please enter a valid email address",
    },
    phone: {
      required: true,
      pattern: /^[+]?[1]?[\s\-.]?[$$]?[0-9]{3}[$$]?[\s\-.]?[0-9]{3}[\s\-.]?[0-9]{4}$/,
      message: "Please enter a valid Canadian phone number",
    },
    inquiryType: {
      required: true,
      message: "Please select your reason for contact",
    },
  }

  // Add real-time validation
  Object.keys(validationRules).forEach((fieldName) => {
    const field = document.getElementById(fieldName)
    if (field) {
      field.addEventListener("blur", () => validateField(field, validationRules[fieldName]))
      field.addEventListener("input", () => clearFieldError(field))
      if (field.type === "checkbox") {
        field.addEventListener("change", () => validateField(field, validationRules[fieldName]))
      }
    }
  })

  // Form submission handler
  form.addEventListener("submit", (e) => {
    e.preventDefault()

    if (validateForm()) {
      submitForm()
    }
  })

  function validateField(field, rules) {
    const value = field.type === "checkbox" ? field.checked : field.value.trim()
    let isValid = true
    let errorMessage = ""

    // Clear previous errors
    clearFieldError(field)

    // Required field validation
    if (rules.required) {
      if (field.type === "checkbox" && !field.checked) {
        isValid = false
        errorMessage = rules.message
      } else if (field.type !== "checkbox" && !value) {
        isValid = false
        errorMessage = `${getFieldLabel(field)} is required`
      }
    }
    // Pattern validation (for non-checkbox fields)
    else if (field.type !== "checkbox" && value && rules.pattern && !rules.pattern.test(value)) {
      isValid = false
      errorMessage = rules.message
    }
    // Minimum length validation (for non-checkbox fields)
    else if (field.type !== "checkbox" && value && rules.minLength && value.length < rules.minLength) {
      isValid = false
      errorMessage = rules.message
    }

    if (!isValid) {
      showFieldError(field, errorMessage)
    }

    return isValid
  }

  function validateForm() {
    let isFormValid = true

    Object.keys(validationRules).forEach((fieldName) => {
      const field = document.getElementById(fieldName)
      if (field && !validateField(field, validationRules[fieldName])) {
        isFormValid = false
      }
    })

    return isFormValid
  }

  function showFieldError(field, message) {
    field.classList.add("error")

    // Remove existing error message
    const existingError = field.parentNode.querySelector(".error-message")
    if (existingError) {
      existingError.remove()
    }

    // Add new error message
    const errorDiv = document.createElement("div")
    errorDiv.className = "error-message"
    errorDiv.textContent = message
    field.parentNode.appendChild(errorDiv)
  }

  function clearFieldError(field) {
    field.classList.remove("error")
    const errorMessage = field.parentNode.querySelector(".error-message")
    if (errorMessage) {
      errorMessage.remove()
    }
  }

  function getFieldLabel(field) {
    const label = field.parentNode.querySelector("label")
    return label ? label.textContent.replace(" *", "") : field.name
  }

  function packageFormDataAsJSON() {
    const formData = new FormData(form)
    const jsonData = {

      // Name
      firstName: formData.get("firstName")?.trim() || "",
      lastName: formData.get("lastName")?.trim() || "",

      // Email
      email: formData.get("email")?.trim() || "",

      // Phone
      phone: formData.get("phone")?.trim() || "",

      // Inquiry Details
      inquiryDetails: {
        inquiryType: formData.get("inquiryType") || "",
        propertyValue: formData.get("propertyValue") || "",
        loanAmount: formData.get("loanAmount") || "",
        creditScore: formData.get("creditScore") || "",
        timeframe: formData.get("timeframe") || "",
        propertyLocation: formData.get("propertyLocation")?.trim() || "",
        province: formData.get("province") || "",
        currentSituation: formData.get("currentSituation") || "",
        mortgageType: formData.get("mortgageType") || "",
      },

      // Communication Preferences
      communicationPreferences: {
        preferredContact: formData.get("preferredContact") || "",
        bestTimeToCall: formData.get("bestTimeToCall") || "",
        additionalDetails: formData.get("additionalDetails")?.trim() || "",
      },

      // Metadata
      metadata: {
        submittedAt: new Date().toISOString(),
        userAgent: navigator.userAgent,
        referrer: document.referrer || "direct",
        formVersion: "1.0",
        leadSource: "contact-form",
        country: "Canada",
        currency: "CAD",
      },
    }

    return jsonData
  }

  async function submitForm() {
    // Show loading state
    submitBtn.disabled = true
    btnText.style.display = "none"
    btnLoading.style.display = "inline"

    try {
      // Package form data as JSON
      const jsonPayload = packageFormDataAsJSON()

      // Log the JSON payload (for debugging)
      console.log("Canadian Mortgage Inquiry JSON Payload:", JSON.stringify(jsonPayload, null, 2))

      // Make API call
      const response = await fetch(apiGatewayUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(jsonPayload),
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const result = await response.json()
      console.log("API Response:", result)

      // Show success message
      form.style.display = "none"
      successMessage.style.display = "block"
      successMessage.scrollIntoView({ behavior: "smooth" })
    } catch (error) {
      console.error("Submission error:", error)

      // Show error message to user
      showSubmissionError(error.message)
    } finally {
      // Reset loading state
      submitBtn.disabled = false
      btnText.style.display = "inline"
      btnLoading.style.display = "none"
    }
  }

  function showSubmissionError(errorMessage) {
    // Remove existing error message
    const existingError = document.querySelector(".submission-error")
    if (existingError) {
      existingError.remove()
    }

    // Create error message element
    const errorDiv = document.createElement("div")
    errorDiv.className = "submission-error"
    errorDiv.innerHTML = `
    <h3>Submission Failed</h3>
    <p>We're sorry, but there was an error submitting your inquiry. Please try again or call us directly at 1-800-MORTGAGE.</p>
    <p class="error-details">Error: ${errorMessage}</p>
    <button onclick="this.parentElement.remove()" class="close-error">×</button>
  `

    // Insert error message before the form
    form.parentNode.insertBefore(errorDiv, form)
    errorDiv.scrollIntoView({ behavior: "smooth" })
  }

  // Add some interactive enhancements
  const inputs = form.querySelectorAll("input, select, textarea")
  inputs.forEach((input) => {
    input.addEventListener("focus", function () {
      this.parentNode.style.transform = "scale(1.02)"
      this.parentNode.style.transition = "transform 0.2s ease"
    })

    input.addEventListener("blur", function () {
      this.parentNode.style.transform = "scale(1)"
    })
  })
})
