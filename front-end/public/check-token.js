function checkToken(){
    let token = getToken();
    if(!token){
        const container = document.body;
        msg(container, 'error', 'Session expired. Please <a href="/login">log in</a> again.');
        return false;
    }
    return true;
}

document.addEventListener('DOMContentLoaded', () => {
    checkToken();
});