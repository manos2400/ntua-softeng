document.addEventListener('DOMContentLoaded', () => {


  // ------------------ NAVBAR ------------------

  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  $navbarBurgers.forEach( el => {
    el.addEventListener('click', () => {
      const target = el.dataset.target;
      const $target = document.getElementById(target);
      el.classList.toggle('is-active');
      $target.classList.toggle('is-active');
    });
  });


  // ------------------ NOTIFICATION DELETE BTN ------------------

  (document.querySelectorAll('.notification .delete') || []).forEach(($delete) => {
    const $notification = $delete.parentNode;
    $delete.addEventListener('click', () => {
      $notification.parentNode.removeChild($notification);
    });
  });


  // ------------------ DROPDOWN ------------------

  let dds = document.querySelectorAll('.dropdown');
  dds.forEach(dd => {
    const dropdown = dd;
    const dropdownTrigger = dropdown.querySelector('.dropdown-trigger');
    const dropdownButton = dropdownTrigger.querySelector('.button');
    const dropdownItems = dropdown.querySelectorAll('.dropdown-item');
    dropdownTrigger.addEventListener('click', () => {
      dropdown.classList.toggle('is-active');
    });
    dropdownItems.forEach(item => {
      item.addEventListener('click', (event) => {
        event.preventDefault();
        const selection = item.textContent.trim();
        dropdownButton.querySelector('span').textContent = selection;
        dropdown.setAttribute('value', selection);
        dropdown.classList.remove('is-active');
      });
    });
  });


  // ------------------ FILE INPUT ------------------

  dds = document.querySelectorAll('.file');
  dds.forEach(dd => {
    const fileInput = dd.querySelector('input[type=file]');
    const fileLabel = dd.querySelector('.file-name');
    if (fileInput.files.length > 0) {
      fileLabel.textContent = fileInput.files[0].name;
    }
    fileInput.onchange = () => {
      if (fileInput.files.length > 0) {
        fileLabel.textContent = fileInput.files[0].name;
      }
    };
  });


});


