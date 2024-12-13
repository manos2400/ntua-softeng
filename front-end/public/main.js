function getToken(){
    const token = document.cookie.split('; ').find(row => row.startsWith('token=')).split('=')[1];
    return token.replace(/\s/g, '');
}

const API_BASE = 'http://localhost:9115/api';

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

    if(data){
        options.body = JSON.stringify(data);
    }

    console.log('Request:', url, options);

    const response = await fetch(`${API_BASE}/${url}`, options);

    //console.log('Response:', response);

    if(output_format == 'json'){

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.message || `Error: ${response.status}`);
        }
        return await response.json();
        
    } else {

        if(!response.ok){
            throw new Error(`Error: ${response.status}`);
        }
        return response;

    }
}

// File POST request
async function fileRequest(url, data){

    const headers = {
        'x-observatory-auth': getToken(),
        'Content-Type': 'multipart/form-data',
    };

    const formData = new FormData();
    formData.append('file', data);

    const options = {
        method: 'POST',
        headers,
        body: formData,
    };

    console.log('Request:', url, options);

    const response = await fetch(`${API_BASE}/${url}`, options);
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