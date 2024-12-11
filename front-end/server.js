const express = require('express');
const app = express();
const PORT = 3000;

app.set('view engine', 'ejs');
app.use(express.static('public'));


// Helper function to check the token on the backend API
async function checkToken(token) {
    try {
        const response = await fetch('http://localhost:9115/api/validate-token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-observatory-auth': token,  // send token in headers
            }
        });

        const data = await response.json();

        if (response.ok) {
            return data.isValid;  // Return whether token is valid
        } else {
            throw new Error(data.message || 'Error validating token');
        }
    } catch (error) {
        console.error('Error validating token:', error);
        return false;  // Token is invalid or error occurred
    }
}

app.get('/', async (req, res) => {

    // get token from localstorage:
    const token = req.query.token;
    // log token to console:
    console.log('Token:', token);

    if(!token) {
        res.render('landing', { title: 'Landing Page' });
        return;
    }

    const isTokenValid = await checkToken(token);

    if (isTokenValid) {
        res.redirect('dashboard');
    } else {
        res.render('landing', { title: 'Landing Page' });
    }
});


app.get('/admin', (req, res) => {
    res.render('admin', { title: 'Admin Page' });
});
app.get('/chargesBy', (req, res) => {
    res.render('chargesBy', { title: 'Charges By Page' });
});
app.get('/login', (req, res) => {
    res.render('login', { title: 'Login Page' });
});
app.get('/passAnalysis', (req, res) => {
    res.render('passAnalysis', { title: 'Pass Analysis Page' });
});
app.get('/passesCost', (req, res) => {
    res.render('passesCost', { title: 'Passes Cost Page' });
});
app.get('/signup', (req, res) => {
    res.render('signup', { title: 'Signup Page' });
});
app.get('/tollStationPasses', (req, res) => {
    res.render('tollstationpasses', { title: 'Toll Station Passes Page' });
});

// 404 page
app.get('*', (req, res) => {
    res.render('404', { title: '404 Page' });
});



app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
