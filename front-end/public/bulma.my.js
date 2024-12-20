function applyDropdownFunctionality(dropdownEl){
  const dropdownTrigger = dropdownEl.querySelector('.dropdown-trigger');
  const dropdownButton = dropdownTrigger.querySelector('.button');
  const dropdownItems = dropdownEl.querySelectorAll('.dropdown-item');
  dropdownTrigger.addEventListener('click', () => {
      dropdownEl.classList.toggle('is-active');
  });
  dropdownItems.forEach(item => {
      item.addEventListener('click', (event) => {
          event.preventDefault();
          const selection = item.textContent.trim();
          dropdownButton.querySelector('span').textContent = selection;
          dropdownEl.setAttribute('value', selection);
          dropdownEl.classList.remove('is-active');
      });
  });
}

function applyDropdownTriggers(dd_parent){
  dd_parent.querySelectorAll('.dropdown-trigger').forEach(trigger => {
    trigger.addEventListener('click', () => {
        const dropdown = trigger.closest('.dropdown');
        dropdown.classList.toggle('is-active');
    });
  });
}


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
    applyDropdownFunctionality(dd);
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


