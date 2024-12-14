const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();
const PORT = 3000;

app.set('view engine', 'ejs');
app.use(express.static('public'));

// get token from cookie
app.use(cookieParser());
app.use((req, res, next) => {
    token = req.cookies.token;
    next();
});

// if token exists, consider user logged in and as admin (only for UI)
async function checkToken() {
    return token;
}

app.get('/', async (req, res) => {
    if (await checkToken()) {
        res.render('dashboard', { title: 'Dashboard Page' });
    } else {
        res.render('landing', { title: 'Landing Page' });
    }
});
app.get('/login', async (req, res) => {
    if (await checkToken()) {
        res.render('dashboard', { title: 'Dashboard Page' });
    } else {
        res.render('login', { title: 'Login Page' });
    }
});

app.get('/admin', async (req, res) => {
    if (await checkToken()) {
        res.render('admin', { title: 'Admin Page' });
    } else {
        res.render('401', { title: '401 Page' });
    }
});
app.get('/chargesBy', (req, res) => {
    res.render('chargesBy', { title: 'Charges By Page' });
});
app.get('/passAnalysis', (req, res) => {
    res.render('passAnalysis', { title: 'Pass Analysis Page' });
});
app.get('/passesCost', (req, res) => {
    res.render('passesCost', { title: 'Passes Cost Page' });
});
app.get('/tollStationPasses', (req, res) => {
    res.render('tollstationpasses', { title: 'Toll Station Passes Page' });
});
app.get('*', (req, res) => {
    res.render('404', { title: '404 Page' });
});


app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
