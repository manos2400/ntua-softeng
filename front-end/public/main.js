const API_BASE = `${window.location.origin}/api`;

// get auth token from cookie
function getToken(){
    let token = document.cookie.split('; ').find(row => row.startsWith('token='));
    if(!token) return null;
    token = token.split('=')[1];
    return token.replace(/\s/g, '');
}

// simple POST, GET requests
async function apiRequest(url, method = 'GET', data = null, output_format = 'json') {

    const headers = {
        'x-observatory-auth': getToken(),
        'Content-Type': 'application/json',
    };
    const options = {
        method,
        headers
    };
    if(data) options.body = JSON.stringify(data);

    console.log('Request:', url, options);

    const response = await fetch(`${API_BASE}/${url}`, options);

    if(response.status === 204) {
        return {'error': 'No data'};
    }

    if(output_format === 'json'){
        if (!response.ok) {
            const error = await response.json();
            const errorMessage = error.message || error.error || `${response.status}`;
            throw new Error(errorMessage);
        }
        return await response.json();
    } else {
        if (!response.ok) {
            const errorText = await response.text(); // Capture raw response text
            let errorMessage;
            try {
                const errorJson = JSON.parse(errorText);
                errorMessage = errorJson.message || errorJson.error || errorText;
            } catch {
                errorMessage = errorText;
            }
            throw new Error(errorMessage);
        }
        return response;
    }
}

// file requests
async function fileRequest(url, data) {
    const headers = {
        'x-observatory-auth': getToken(),
        // Do not set 'Content-Type' explicitly, let the browser set it automatically
    };
    const options = {
        method: 'POST',
        headers,
        body: data, // Pass the FormData object directly
    };

    console.log('Request:', url, options);

    const response = await fetch(`${API_BASE}/${url}`, options);
    if (!response.ok) {
        const error = await response.json();
        const errorMessage = error.message || error.error || `${response.status}`;
        throw new Error(errorMessage);
    }
    return await response.json();
}

// quick styled messages for UI
function msg(container,type,txt=""){
    if(type==="loading"){
        container.innerHTML = '<progress class="progress is-medium is-info" max="100">60%</progress>';
        return;
    }
    const article = document.createElement('article');
    article.classList.add('message');
    if(type==="error") article.classList.add('is-danger');
    if(type==="success") article.classList.add('is-success');
    if(type==="warn") article.classList.add('is-warning');
    const div = document.createElement('div');
    div.classList.add('message-body');
    div.innerHTML = txt;
    article.appendChild(div);
    container.style.padding = '5px 5px 20px 5px';
    container.innerHTML = '';
    container.appendChild(article);
}

function formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleString();
}

function getNumber(str){
    // from string ABC34 or AB17 keep 34 and 17
    return str.match(/\d+/)[0];
}