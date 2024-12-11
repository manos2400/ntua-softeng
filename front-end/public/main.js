async function apiRequest(url, method = 'GET', body = null) {
    const token = localStorage.getItem('authToken'); // or from cookies, depending on your setup
    const headers = {
        'Content-Type': 'application/json',
        'x-observatory-auth': token, // Add token here
    };

    const options = { method, headers };
    if (body) options.body = JSON.stringify(body);

    const response = await fetch(`http://localhost:9115/${url}`, options);
    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || `Error: ${response.status}`);
    }
    return await response.json();
}



function msg(container,type,txt){
    const article = document.createElement('article');
    article.classList.add('message');
    if(type=="error") article.classList.add('is-danger');
    if(type=="success") article.classList.add('is-success');
    const div = document.createElement('div');
    div.classList.add('message-body');
    div.innerHTML = txt;
    article.appendChild(div);
    container.style.padding = '5px 5px 20px 5px';
    container.innerHTML = '';
    container.appendChild(article);
}


// Register function
function register(username, password, email) {
    const url = '/api/register';
    const body = { username, password, email };
    apiRequest(url, 'POST', body)
        .then(data => {
            console.log('Registration successful:', data);
            // Handle success
        })
        .catch(error => {
            alert(`Registration failed: ${error.message}`);
        });
}

// Get information from the database
function getInfo(endpoint) {
    const url = `/api/${endpoint}`;
    apiRequest(url, 'GET')
        .then(data => {
            console.log('Data retrieved:', data);
            // Handle success
        })
        .catch(error => {
            alert(`Failed to fetch data: ${error.message}`);
        });
}
