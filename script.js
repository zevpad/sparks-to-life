document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('signup-form');
  const submitBtn = document.getElementById('submit-btn');
  const successMsg = document.getElementById('success-message');
  const formError = document.getElementById('form-error');

  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    if (!validateForm()) return;

    submitBtn.disabled = true;
    submitBtn.textContent = 'Submitting…';
    formError.classList.add('hidden');

    const action = form.getAttribute('action');

    // Demo mode: placeholder URL was never replaced
    if (!action || action === 'FORM_ACTION_URL_HERE') {
      showSuccess();
      return;
    }

    try {
      const response = await fetch(action, {
        method: 'POST',
        body: new FormData(form),
        headers: { 'Accept': 'application/json' },
      });

      if (response.ok) {
        showSuccess();
      } else {
        showFormError('Something went wrong. Please try again or contact me directly.');
        resetButton();
      }
    } catch {
      showFormError('Could not send your signup. Please check your connection and try again.');
      resetButton();
    }
  });

  function validateForm() {
    let valid = true;
    formError.classList.add('hidden');

    // Text/email/tel inputs
    form.querySelectorAll('input[required]:not([type="checkbox"])').forEach((input) => {
      input.classList.remove('invalid');
      if (!input.value.trim()) {
        input.classList.add('invalid');
        valid = false;
      }
    });

    // Gmail must look like a Gmail address
    const gmailInput = form.querySelector('#gmail');
    if (gmailInput && gmailInput.value.trim() && !gmailInput.value.trim().toLowerCase().endsWith('@gmail.com')) {
      gmailInput.classList.add('invalid');
      showFormError('Please enter a Gmail address (ending in @gmail.com).');
      return false;
    }

    // Required checkboxes
    form.querySelectorAll('input[type="checkbox"][required]').forEach((checkbox) => {
      checkbox.classList.remove('invalid');
      if (!checkbox.checked) {
        checkbox.classList.add('invalid');
        valid = false;
      }
    });

    if (!valid) {
      showFormError('Please fill in all required fields and check all boxes before submitting.');
    }

    return valid;
  }

  function showSuccess() {
    form.classList.add('hidden');
    successMsg.classList.remove('hidden');
    successMsg.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function showFormError(msg) {
    formError.textContent = msg;
    formError.classList.remove('hidden');
    formError.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function resetButton() {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Sign Up as a Tester';
  }

  // Clear invalid state on input
  form.querySelectorAll('input').forEach((input) => {
    input.addEventListener('input', () => input.classList.remove('invalid'));
    input.addEventListener('change', () => input.classList.remove('invalid'));
  });

  // Smooth-scroll hero CTA
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener('click', (e) => {
      const target = document.querySelector(anchor.getAttribute('href'));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth' });
      }
    });
  });
});
