document.addEventListener('DOMContentLoaded', () => {

    // Get all "navbar-burger" elements
    const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
  
    // Add a click event on each of them
    $navbarBurgers.forEach( el => {
      el.addEventListener('click', () => {
  
        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);
  
        // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');
  
      });
    });
  
  });


// notification delete
document.addEventListener('DOMContentLoaded', () => {
    (document.querySelectorAll('.notification .delete') || []).forEach(($delete) => {
      const $notification = $delete.parentNode;
  
      $delete.addEventListener('click', () => {
        $notification.parentNode.removeChild($notification);
      });
    });
  });



// dropdown
document.addEventListener('DOMContentLoaded', () => {

  // get all elements with class dropdown
  const dds = document.querySelectorAll('.dropdown');

  dds.forEach(dd => {
    const dropdown = dd;
    const dropdownTrigger = dropdown.querySelector('.dropdown-trigger');
    const dropdownButton = dropdownTrigger.querySelector('.button');
    const dropdownItems = dropdown.querySelectorAll('.dropdown-item');

    // Toggle dropdown visibility
    dropdownTrigger.addEventListener('click', () => {
      dropdown.classList.toggle('is-active');
    });

    // Update button text, dropdown value, and close dropdown on item click
    dropdownItems.forEach(item => {
      item.addEventListener('click', (event) => {
        event.preventDefault();
        const selection = item.textContent.trim();
        dropdownButton.querySelector('span').textContent = selection;
        dropdown.setAttribute('value', selection);
        dropdown.classList.remove('is-active');
      });
    });
  }
  );
}
);



// file input

document.addEventListener('DOMContentLoaded', () => {

  // get all elements with class fileinput
  const dds = document.querySelectorAll('.file');

  dds.forEach(dd => {
    const fileInput = dd.querySelector('input[type=file]');
    const fileLabel = dd.querySelector('.file-name');

    // if there is already a file, add the name to the label
    if (fileInput.files.length > 0) {
      fileLabel.textContent = fileInput.files[0].name;
    }

    fileInput.onchange = () => {
      if (fileInput.files.length > 0) {
        fileLabel.textContent = fileInput.files[0].name;
      }
    };
  }
  );



}
);

