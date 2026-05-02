<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>Slot Pro</title>

<style>
body {
    background: radial-gradient(circle, #111, #000);
    color: white;
    font-family: Arial;
    text-align: center;
}

#container {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-top: 40px;
    padding: 20px;
    background: #111;
    border-radius: 15px;
    box-shadow: 0 0 30px gold;
}

.col {
    width: 100px;
    height: 300px;
    overflow: hidden;
    background: black;
    border-radius: 10px;
}

.icon {
    height: 100px;
}

.icon img {
    width: 100%;
}

.spinning .col {
    animation: spin linear;
}

@keyframes spin {
    0% { transform: translateY(0); }
    100% { transform: translateY(-70%); }
}

/* PAYLINE */
.payline {
    position: absolute;
    width: 520px;
    height: 4px;
    background: red;
    top: 190px;
    left: 50%;
    transform: translateX(-50%);
    box-shadow: 0 0 10px red;
}

/* UI */
#ui {
    margin-top: 20px;
}

button {
    padding: 12px 30px;
    font-size: 18px;
    background: gold;
    border: none;
    border-radius: 10px;
    cursor: pointer;
}

.win {
    animation: winFlash 0.5s infinite alternate;
}

@keyframes winFlash {
    from { box-shadow: 0 0 10px gold; }
    to { box-shadow: 0 0 30px yellow; }
}

#bigwin {
    font-size: 40px;
    color: gold;
    display: none;
    margin-top: 20px;
    animation: zoom 0.5s infinite alternate;
}

@keyframes zoom {
    from { transform: scale(1); }
    to { transform: scale(1.2); }
}
</style>
</head>

<body>

<h1>🎰 SLOT PRO</h1>

<div style="position:relative;">
    <div id="container">
        <div class="col"></div>
        <div class="col"></div>
        <div class="col"></div>
        <div class="col"></div>
        <div class="col"></div>
    </div>
    <div class="payline"></div>
</div>

<div id="ui">
    💰 Saldo: <span id="balance">1000</span><br><br>
    🎯 Bet: <input type="number" id="bet" value="50" min="10"><br><br>
    <button onclick="spin(this)">SPIN</button>
</div>

<div id="bigwin">🔥 BIG WIN 🔥</div>

<script>
const ICONS = [
    'apple','banana','cherry','grapes','lemon','orange','pear','strawberry'
];

let balance = 1000;
let cols;

window.onload = () => {
    cols = document.querySelectorAll('.col');
    setInitialItems();
}

function setInitialItems() {
    for (let col of cols) {
        let html = '';
        for (let i = 0; i < 40; i++) {
            let icon = randomIcon();
            html += `<div class="icon"><img src="items/${icon}.png"></div>`;
        }
        col.innerHTML = html;
    }
}

function spin(btn) {
    let bet = parseInt(document.getElementById('bet').value);

    if (balance < bet) {
        alert("Saldo habis!");
        return;
    }

    balance -= bet;
    updateBalance();

    document.getElementById('bigwin').style.display = "none";

    btn.disabled = true;
    document.getElementById('container').classList.add('spinning');

    setTimeout(() => {
        let result = [];

        for (let col of cols) {
            let r = randomIcon();
            result.push(r);

            let icons = col.querySelectorAll('img');
            for (let i = 0; i < icons.length; i++) {
                icons[i].src = `items/${r}.png`;
            }
        }

        checkWin(result, bet);

        document.getElementById('container').classList.remove('spinning');
        btn.disabled = false;

    }, 2000);
}

function checkWin(result, bet) {
    let count = {};

    result.forEach(r => {
        count[r] = (count[r] || 0) + 1;
    });

    let win = false;

    for (let key in count) {
        if (count[key] >= 3) {
            let reward = bet * count[key] * 2;
            balance += reward;
            updateBalance();

            showWin();

            if (reward > bet * 5) {
                document.getElementById('bigwin').style.display = "block";
            }

            win = true;
        }
    }

    if (!win) {
        console.log("Zonk 😅");
    }
}

function showWin() {
    document.getElementById('container').classList.add('win');
    setTimeout(() => {
        document.getElementById('container').classList.remove('win');
    }, 1500);
}

function updateBalance() {
    document.getElementById('balance').innerText = balance;
}

function randomIcon() {
    return ICONS[Math.floor(Math.random() * ICONS.length)];
}
</script>

</body>
</html>
