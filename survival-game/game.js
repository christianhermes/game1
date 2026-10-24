import { homeMapLayout, mapLayouts } from "./maps.js";
import {Enemy, Boss, Skeleton, Exploder} from "./enemies.js"
import{homeRessources, loadHomeRessources, growCrops, harvestCrops, craftBread, harvestBread} from "./home.js"
// HTML-Element holen

const player = document.getElementById("player");
const game = document.getElementById("game");
const berry = document.getElementById("berry");
const berryCounter = document.getElementById("berryCounter");
const hp = document.getElementById("hp");
const attackArea = document.getElementById("attackArea");
const gameOverScreen = document.getElementById("gameOverScreen");
const restartButton = document.getElementById("restartButton");
const xpDisplay = document.getElementById("xpDisplay");
const levelDisplay = document.getElementById("levelDisplay");
const damageDisplay = document.getElementById("damageDisplay");
const levelUpScreen = document.getElementById("levelUpScreen");
const damageUpgrade = document.getElementById("damageUpgrade");
const healUpgrade = document.getElementById("healUpgrade");
const maxHealthUpgrade = document.getElementById("maxHealthUpgrade");
const waveDisplay = document.getElementById("waveDisplay");
const attackSpeedUpgrade = document.getElementById("attackSpeedUpgrade");
const waveMessage = document.getElementById("waveMessage");
const dashStatus = document.getElementById("dashStatus");
const relic = document.getElementById("relic");
const relicDisplay = document.getElementById("relicDisplay");
const explosion = document.getElementById("explosion");
const goldCounter = document.getElementById("goldCounter");
const merchantScreen = document.getElementById("merchantScreen");
const buyDamage = document.getElementById("buyDamage");
const nextWaveButton = document.getElementById("nextWaveButton");
const homeAreaButton = document.getElementById("homeAreaButton");
const backToDungeonButton = document.getElementById("backToDungeonButton");
const wheatCount = document.getElementById("wheatCount");
const breadCounter = document.getElementById("breadCounter");

let gamePaused = false;
//aktuelle Map festlegen
let currentArea = "home";

restartButton.addEventListener("click", function () {
  location.reload();
});

nextWaveButton.addEventListener("click", function () {
  currentWave++;
  updateWave();
  spawnWave(currentWave + 2);
  waveTransition = false;
  waveMessage.style.display = "none";
  merchantScreen.style.display = "none";
  gamePaused = false;
});
homeAreaButton.addEventListener("click", function () {
  loadArea("home");
  waveTransition = false;
  waveMessage.style.display = "none";
  merchantScreen.style.display = "none";
  gamePaused = false;
  backToDungeonButton.style.display = "block";
  gamePaused = false;
});
backToDungeonButton.addEventListener("click", function () {
  loadArea("dungeon");
  currentWave++;
  updateWave();
  spawnWave(currentWave + 2);
  waveTransition = false;
  backToDungeonButton.style.display = "none";
  gamePaused = false;
});

buyDamage.addEventListener("click", function () {
  if (playerGold >= 30) {
    playerGold -= 30;
    playerDamage += 5;
    updateGold();
    updateDamage();
  } else {
    console.log("Nicht genug Gold");
  }
});

damageUpgrade.addEventListener("click", function () {
  playerDamage += 5;
  updateDamage();
  closeLevelUpScreen();
});
healUpgrade.addEventListener("click", function () {
  playerHp = Math.min(playerHp + 30, playerMaxHp);
  updateHealth();
  closeLevelUpScreen();
});
maxHealthUpgrade.addEventListener("click", function () {
  playerMaxHp += 20;
  playerHp = Math.min(playerHp + 20, playerMaxHp);
  updateHealth();
  closeLevelUpScreen();
});
attackSpeedUpgrade.addEventListener("click", function () {
  playerAttackSpeed = Math.max(playerAttackSpeed - 20, 100);
  if (playerAttackSpeed === 100) {
    attackSpeedUpgrade.disabled = true;
  }

  closeLevelUpScreen();
});

game.addEventListener("mousemove", function (event) {
  // Die Browserkoordinaten werden in Koordinaten innerhalb von #game umgerechnet.
  const gameRect = game.getBoundingClientRect();
  mouseX = event.clientX - gameRect.left - game.clientLeft;
  mouseY = event.clientY - gameRect.top - game.clientTop;
});

// Player Zeug festlegen
let playerX = 0;
let playerY = 0;
let playerMaxHp = 100;
let playerHp = 100;
let playerDirection = "down";
let playerDamage = 10;
let playerAlive = true;
let playerXp = 0;
let playerLevel = 1;
let xpToNextLevel = 30;
const movement = 10;
let playerAttackSpeed = 400;
let playerReadyToAttack = true;
let playerReadyToDash = true;
let playerDashCooldown = 3000;
let playerIsDashing = false;
const playerWidth = player.clientWidth;
const playerHeight = player.clientHeight;
let playerReadyToShoot = true;
let playerShootCooldown = 300;
let playerGold = 0;

let mouseX = 0;
let mouseY = 0;

//Dinge der Beere festlegen
let berryX = 200;
let berryY = 150;
let berryBool = true;
let berryCount = 0;
const berryWidth = berry.clientWidth;
const berryHeight = berry.clientHeight;

//Dinge für Crops
let wheatCounter = 0;
let breadCount = 0;

// Dinge für das Relic
let relicX = 0;
let relicY = 0;
let relicActive = false;
let activeRelicType = "dash";
const relicTypes = ["dash", "fireRate", "damage"];

const relicInventory = {
  dash: 0,
  fireRate: 0,
  damage: 0,
};

//Dinge mit Gegnern
const enemies = [];
let currentWave = 0;
let waveTransition = false;

const goldDrops = [];

const projectiles = [];
const obstacles = [];
const enemySize = 48;
const projectileWidth = 24;
const projectileHeight = 12;

//RessourcenObjecte


function loadMap(layout) {
  for (const layoutElement of layout) {
    createObstacle(
      layoutElement.x,
      layoutElement.y,
      layoutElement.width,
      layoutElement.height,
      layoutElement.type,
      layoutElement.blocksProjectiles,
    );
  }
}

// Feldgröße holen
const fieldWidth = game.clientWidth;
const fieldHeight = game.clientHeight;

// maxewerte festlegen
const maxX = fieldWidth - playerWidth;
const maxY = fieldHeight - playerHeight;

//aktuelle Map leeren
function clearCurrentMap() {
  for (const obsatacleObject of obstacles) {
    obsatacleObject.element.remove();
  }
  obstacles.length = 0;
  for (const projectileObject of projectiles) {
    projectileObject.element.remove();
  }
  projectiles.length = 0;
  for (const goldDropObject of goldDrops) {
    goldDropObject.element.remove();
  }
  goldDrops.length = 0;
  for (const homeRessourcesObject of homeRessources) {
    if (homeRessourcesObject.element !== null) {
      homeRessourcesObject.element.remove();
    }
    homeRessourcesObject.element = null;
  }
}

//Ressourcen pflenzen
function plantRessource(homeRessourceObject) {
  if (homeRessourceObject !== null && homeRessourceObject.state === "empty") {
    homeRessourceObject.state = "planted";
    homeRessourceObject.element.classList.remove("empty");
    homeRessourceObject.element.classList.add("planted");
    growCrops(homeRessourceObject);
  }
}

//Ressource in Reichweite

function homeRessourceCollision() {
  for (const homeRessourcesObject of homeRessources) {
    const homeRessourceRight =
      homeRessourcesObject.x + homeRessourcesObject.element.clientWidth;
    const homeRessourceDown =
      homeRessourcesObject.y + homeRessourcesObject.element.clientHeight;
    if (
      playerX + playerWidth > homeRessourcesObject.x &&
      homeRessourceRight > playerX &&
      playerY < homeRessourceDown &&
      playerY + playerHeight > homeRessourcesObject.y
    )
      return homeRessourcesObject;
  }
  return null;
}
//Map laden
function loadArea(areaName) {
  clearCurrentMap();
  if (areaName === "dungeon") {
    backToDungeonButton.style.display = "none";
    loadMap(mapLayouts[randomValue(0, mapLayouts.length - 1)]);
    currentArea = "dungeon";
    game.classList.remove("dungeon", "home");
    game.classList.add("dungeon");
  } else {
    backToDungeonButton.style.display = "block";
    loadMap(homeMapLayout);
    currentArea = "home";
    game.classList.remove("home", "dungeon");
    game.classList.add("home");
    loadHomeRessources();
  }

  const postion = getRandomFreePosition(playerWidth, playerHeight);
  playerX = postion.x;
  playerY = postion.y;

  updatePlayerPosition();
}
document.addEventListener("keydown", function (event) {
  if (!playerAlive || gamePaused) {
    return;
  }
  const key = event.key.toLowerCase();
  if (key === " ") {
    if (!event.repeat) {
      attack();
    }
  } else if (key === "shift") {
    if (!event.repeat) {
      dash();
    }
  } else if (key === "e") {
    if (!event.repeat) {
      // Zielrichtung und Projektilgeschwindigkeit werden in dieser Funktion berechnet.
      shootPlayerProjectile();
    }
  } else if (key === "f") {
    if (!event.repeat && currentArea === "home") {
      const homeRessourceObject = homeRessourceCollision();
      if (homeRessourceObject === null) {
        return;
      }
      if (homeRessourceObject.type === "field") {
        if (homeRessourceObject.state === "empty") {
          plantRessource(homeRessourceObject);
        } else if (homeRessourceObject.state === "ready") {
          harvestCrops(homeRessourceObject);
        } else {
          return;
        }
      } else if (homeRessourceObject.type === "breadOven") {
        if (homeRessourceObject.state === "empty") {
          craftBread(homeRessourceObject);
        } else if (homeRessourceObject.state === "ready") {
          harvestBread(homeRessourceObject);
        }
      }
    }
  } else {
    movePlayer(key);
  }
  relicCollision();
  berryCollision();
  goldCollision();
  updatePlayerPosition();
});

function movePlayer(key) {
  if (!playerAlive) {
    return;
  }
  let nextX = playerX;
  let nextY = playerY;
  if (key === "a" && playerX > 0) {
    nextX = Math.max(nextX - movement, 0);
    playerDirection = "left";
  } else if (key === "d" && playerX < maxX) {
    nextX = Math.min(nextX + movement, maxX);
    playerDirection = "right";
  } else if (key === "w" && playerY > 0) {
    nextY = Math.max(nextY - movement, 0);
    playerDirection = "up";
  } else if (key === "s" && playerY < maxY) {
    nextY = Math.min(nextY + movement, maxY);
    playerDirection = "down";
  } else {
    //console.log(key);
  }
  if (isPositionBlocked(nextX, nextY, playerWidth, playerHeight)) {
    return;
  }
  playerX = nextX;
  playerY = nextY;
  updatePlayerPosition();
  for (const enemyObject of enemies) {
    enemyCollision(enemyObject);
  }
}

// Position des Players ändern
function updatePlayerPosition() {
  player.style.left = playerX + "px";
  player.style.top = playerY + "px";
}
function dash() {
  if (!playerReadyToDash) {
    return;
  }

  dashStatus.textContent = "Lädt auf";
  playerReadyToDash = false;
  playerIsDashing = true;
  player.classList.add("dashing");
  for (let i = 0; i < 8; i++) {
    let nextX = playerX;
    let nextY = playerY;
    if (playerDirection === "left") {
      nextX = Math.max(playerX - 10, 0);
    } else if (playerDirection === "right") {
      nextX = Math.min(playerX + 10, maxX);
    } else if (playerDirection === "up") {
      nextY = Math.max(playerY - 10, 0);
    } else {
      nextY = Math.min(playerY + 10, maxY);
    }
    if (isPositionBlocked(nextX, nextY, playerWidth, playerHeight)) {
      break;
    } else {
      playerX = nextX;
      playerY = nextY;
    }
  }
  updatePlayerPosition();
  setTimeout(function () {
    playerReadyToDash = true;
    dashStatus.textContent = "Bereit";
  }, playerDashCooldown);
  setTimeout(function () {
    playerIsDashing = false;
    player.classList.remove("dashing");
  }, 150);
}

function attack() {
  if (!playerAlive) {
    return;
  }
  if (playerReadyToAttack) {
    playerReadyToAttack = false;
    let attackX = playerX;
    let attackY = playerY;
    if (playerDirection === "left") {
      attackX -= playerWidth;
    } else if (playerDirection === "right") {
      attackX += playerWidth;
    } else if (playerDirection === "up") {
      attackY -= playerHeight;
    } else {
      attackY += playerHeight;
    }
    attackArea.style.left = attackX + "px";
    attackArea.style.top = attackY + "px";
    attackArea.style.display = "block";
    setTimeout(function () {
      attackArea.style.display = "none";
    }, 150);
    setTimeout(function () {
      playerReadyToAttack = true;
    }, playerAttackSpeed);
    for (const enemyObject of enemies) {
      attackCollision(attackX, attackY, enemyObject);
    }
  }
}

function attackCollision(attackX, attackY, enemyObject) {
  if (!enemyObject.alive) {
    return;
  }
  const enemyRight = enemyObject.x + enemyObject.element.clientWidth;
  const enemyDown = enemyObject.y + enemyObject.element.clientHeight;
  if (
    attackX + playerWidth > enemyObject.x &&
    enemyRight > attackX &&
    attackY < enemyDown &&
    attackY + playerHeight > enemyObject.y
  ) {
    enemyObject.takeDamage(playerDamage);
    console.log("Treffer");
    if (playerDirection === "left") {
      enemyObject.x = Math.max(enemyObject.x - 10, 0);
    } else if (playerDirection === "right") {
      enemyObject.x = Math.min(
        enemyObject.x + 10,
        fieldWidth - enemyObject.element.clientWidth,
      );
    } else if (playerDirection === "up") {
      enemyObject.y = Math.max(enemyObject.y - 10, 0);
    } else {
      enemyObject.y = Math.min(
        enemyObject.y + 10,
        fieldHeight - enemyObject.element.clientHeight,
      );
    }
    enemyObject.updatePosition();
  }
  if (enemyObject.hp <= 0) {
    enemyObject.die();
  }
}

function goldCollision() {
  for (const goldDrop of goldDrops) {
    const goldRight = goldDrop.x + goldDrop.element.clientWidth;
    const goldDown = goldDrop.y + goldDrop.element.clientHeight;
    if (
      playerX + playerWidth > goldDrop.x &&
      goldRight > playerX &&
      playerY < goldDown &&
      playerY + playerHeight > goldDrop.y
    ) {
      goldDrops.splice(goldDrops.indexOf(goldDrop), 1);
      goldDrop.element.remove();
      playerGold += goldDrop.value;
      updateGold();
    }
  }
}

function openShop() {
  gamePaused = true;
  merchantScreen.style.display = "block";
}
function berryCollision() {
  const berryRight = berryX + berry.clientWidth;
  const berryDown = berryY + berry.clientHeight;
  if (
    playerX + playerWidth > berryX &&
    berryRight > playerX &&
    playerY < berryDown &&
    playerY + playerHeight > berryY
  ) {
    if (berryBool) {
      console.log("Erwischt");
      berry.style.display = "none";
      berryBool = false;
      berryCount = berryCount + 1;
      berryCounter.textContent = berryCount.toString();
      playerHp = Math.min(playerHp + 10, playerMaxHp);
      updateHealth();
      const pos = getRandomFreePosition(berryWidth, berryHeight);

      changeBerryPosition(pos.x, pos.y);
    }
  }
}
function changeBerryPosition(a, b) {
  berryX = a;
  berryY = b;
  updateBerryPosition();
  berryBool = true;
  berry.style.display = "block";
}

// Position der Beere ändern
function updateBerryPosition() {
  berry.style.left = berryX + "px";
  berry.style.top = berryY + "px";
}

function relicCollision() {
  if (!relicActive) {
    return;
  }
  const relicRight = relicX + relic.clientWidth;
  const relicDown = relicY + relic.clientHeight;
  if (
    playerX + playerWidth > relicX &&
    relicRight > playerX &&
    playerY < relicDown &&
    playerY + playerHeight > relicY
  ) {
    relic.style.display = "none";
    relicActive = false;
    if (activeRelicType === "dash") {
      playerDashCooldown = Math.max(playerDashCooldown - 200, 800);
      relicInventory.dash += 1;
      updateRelicDisplay();
      console.log(
        `Dash-Relikt eingesammelt! Neuer Cooldown: ${playerDashCooldown} ms`,
      );
    } else if (activeRelicType === "fireRate") {
      playerShootCooldown = Math.max(playerShootCooldown - 30, 100);
      console.log(
        `FireRate-Relikt eingesammelt! Neuer Cooldown: ${playerShootCooldown} ms`,
      );
      relicInventory.fireRate += 1;
      updateRelicDisplay();
    } else if (activeRelicType === "damage") {
      playerDamage += 5;
      console.log(
        `Schaden-Relikt eingesammelt! Neuer Schaden: ${playerDamage}`,
      );
      updateDamage();
      relicInventory.damage += 1;
      updateRelicDisplay();
    }
  }
}

function dropRelic(enemyObject) {
  activeRelicType = relicTypes[randomValue(0, relicTypes.length - 1)];
  for (const relicType of relicTypes) {
    relic.classList.remove(relicType);
  }
  relic.classList.add(activeRelicType);
  relicX = enemyObject.x;
  relicY = enemyObject.y;
  relicActive = true;
  updateRelicPosition();
  relic.style.display = "block";
}
// Position des Relic ändern
function updateRelicPosition() {
  relic.style.left = relicX + "px";
  relic.style.top = relicY + "px";
}
function updateRelicDisplay() {
  relicDisplay.textContent = `Relics: Dash: ${relicInventory.dash}, Feuerrate :${relicInventory.fireRate}, Schaden: ${relicInventory.damage}`;
}



function createEnemyElement() {
  const element = document.createElement("div");

  // Der Container bleibt immer gleich groß und bildet den schwarzen Hintergrund.
  const healthBarContainer = document.createElement("div");
  healthBarContainer.classList.add("health-bar-container");

  // Nur diese innere Füllung wird bei Schaden schmaler und wechselt die Farbe.
  const healthElement = document.createElement("div");
  healthElement.classList.add("health-bar-fill");

  // Richtige Verschachtelung: Gegner -> Container -> Füllung.
  healthBarContainer.appendChild(healthElement);
  element.appendChild(healthBarContainer);
  element.classList.add("enemy");
  game.appendChild(element);
  return {
    element: element,
    healthElement: healthElement,
  };
}

function spawnEnemy(x, y, isBoss = false, type = "melee") {
  const enemy = createEnemyElement();
  const element = enemy.element;
  const healthElement = enemy.healthElement;
  let enemyReadyToPush;
  if (isBoss) {
    enemyReadyToPush = new Boss(x, y, element, healthElement, isBoss);
  } else if (type === "skeleton") {
    enemyReadyToPush = new Skeleton(x, y, element, healthElement, isBoss);
  } else if (type === "exploder") {
    enemyReadyToPush = new Exploder(x, y, element, healthElement, isBoss);
  } else {
    enemyReadyToPush = new Enemy(x, y, element, healthElement, isBoss, type);
  }
  enemyReadyToPush.maxHp = enemyReadyToPush.hp;
  if (isBoss) {
    element.classList.add("boss");
  }
  if (type === "skeleton") {
    element.classList.add("skeleton");
  }
  if (type === "exploder") {
    element.classList.add("exploder");
  }
  enemies.push(enemyReadyToPush);
  enemyReadyToPush.updateHealth();
  enemyReadyToPush.updatePosition();
  return enemyReadyToPush;
}

function spawnWave(enemyCount) {
  for (let i = 0; i < enemyCount; i++) {
    let x = 0;
    let y = 0;
    do {
      x = randomValue(0, fieldWidth - enemySize);
      y = randomValue(0, fieldHeight - enemySize);
    } while (
      isSpawnOnPlayer(x, y) ||
      isSpawnOnEnemy(x, y) ||
      isPositionBlocked(x, y, enemySize, enemySize)
    );
    const boss = isBossWave() && i === 0;
    const isRanged = currentWave >= 3 && !boss && (i + 1) % 3 === 0;
    let type = isRanged ? "skeleton" : "melee";
    const isExploder = currentWave >= 4 && !boss && (i + 1) % 4 === 0;
    type = isExploder ? "exploder" : type;

    spawnEnemy(x, y, boss, type);
  }
}
function isSpawnOnPlayer(spawnX, spawnY) {
  let onPlayer = false;
  if (
    playerX + playerWidth > spawnX &&
    spawnX + enemySize > playerX &&
    playerY < spawnY + enemySize &&
    playerY + playerHeight > spawnY
  ) {
    onPlayer = true;
  }
  return onPlayer;
}
function isSpawnOnEnemy(spawnX, spawnY) {
  for (let enemyObject of enemies) {
    if (
      enemyObject.x + enemyObject.element.clientWidth > spawnX &&
      spawnX + enemySize > enemyObject.x &&
      enemyObject.y < spawnY + enemySize &&
      enemyObject.y + enemyObject.element.clientHeight > spawnY
    ) {
      return true;
    }
  }
  return false;
}

// TODO: Besseres Pathfinding/Waytracking ergänzen, damit Gegner Hindernisse
// gezielt umlaufen und nicht an großen Mauern oder in Ecken hängen bleiben.
function moveEnemyWithCollision(enemyObject, nextX, nextY) {
  const width = enemyObject.element.clientWidth;
  const height = enemyObject.element.clientHeight;

  if (!isPositionBlocked(nextX, enemyObject.y, width, height)) {
    enemyObject.x = nextX;
  }
  if (!isPositionBlocked(enemyObject.x, nextY, width, height)) {
    enemyObject.y = nextY;
  }
  enemyObject.updatePosition();
}

function enemyCollision(enemyObject) {
  if (!enemyObject.alive || !playerAlive || playerIsDashing) {
    return;
  }
  const enemyRight = enemyObject.x + enemyObject.element.clientWidth;
  const enemyDown = enemyObject.y + enemyObject.element.clientHeight;
  if (
    playerX + playerWidth > enemyObject.x &&
    enemyRight > playerX &&
    playerY < enemyDown &&
    playerY + playerHeight > enemyObject.y
  ) {
    if (enemyObject.canAttack) {
      enemyObject.canAttack = false;
      setTimeout(function () {
        enemyObject.canAttack = true;
      }, enemyObject.attackCooldown);
      console.log("Gegner greift an");
      playerHp = Math.max(playerHp - enemyObject.damage, 0);
      updateHealth();
      if (playerHp === 0) {
        gameOver();
      }
    }
  }
}

function isBossWave() {
  if (currentWave % 5 === 0) {
    return true;
  } else {
    return false;
  }
}
function allEnemiesDefeated() {
  let allDefeated = true;
  for (const enemyObject of enemies) {
    if (enemyObject.alive) {
      allDefeated = false;
    }
  }
  return allDefeated;
}

function clearDefeatedEnemies() {
  for (const enemyObject of enemies) {
    enemyObject.element.remove();
  }
  enemies.length = 0;
}

function createProjectileElement(
  startX,
  startY,
  velocityX,
  velocityY,
  damage,
  owner,
) {
  const angle = Math.atan2(velocityY, velocityX);
  const angleInDegrees = (angle * 180) / Math.PI;
  const element = document.createElement("div");
  element.style.transform = `rotate(${angleInDegrees}deg)`;
  element.classList.add("projectile");
  game.appendChild(element);
  if (owner === "enemy") {
    element.classList.add("enemy-projectile");
  }
  return {
    x: startX,
    y: startY,
    damage: damage,
    velocityX: velocityX,
    velocityY: velocityY,
    element: element,
    hit: false,
    owner: owner,
  };
}
function shootPlayerProjectile() {
  // Ausgangspunkt und Zielvektor werden vom Spielerzentrum zur Maus berechnet.
  const playerCenterX = playerX + playerWidth / 2;
  const playerCenterY = playerY + playerHeight / 2;
  const deltaX = mouseX - playerCenterX;
  const deltaY = mouseY - playerCenterY;
  const distance = Math.hypot(deltaX, deltaY);

  // Bei identischer Position existiert keine Schussrichtung.
  if (distance === 0) {
    return;
  }
  if (!playerReadyToShoot) {
    return;
  }
  playerReadyToShoot = false;
  setTimeout(function () {
    playerReadyToShoot = true;
  }, playerShootCooldown);
  // Normalisieren sorgt in jedem Winkel für dieselbe Projektilgeschwindigkeit.
  const projectileSpeed = 10;
  const velocityX = (deltaX / distance) * projectileSpeed;
  const velocityY = (deltaY / distance) * projectileSpeed;

  // Das Projektil beginnt mittig in der Spielfigur.
  const startX = playerCenterX - projectileWidth / 2;
  const startY = playerCenterY - projectileHeight / 2;

  shootProjectile(startX, startY, velocityX, velocityY, playerDamage, "player");
}

function shootProjectile(startX, startY, velocityX, velocityY, damage, owner) {
  const projectile = createProjectileElement(
    startX,
    startY,
    velocityX,
    velocityY,
    damage,
    owner,
  );
  projectiles.push(projectile);
  updateProjectilePosition(projectile);
  return projectile;
}

// Position der Beere ändern
function updateProjectilePosition(projectile) {
  projectile.element.style.left = projectile.x + "px";
  projectile.element.style.top = projectile.y + "px";
}

function moveProjectiles() {
  if (!playerAlive || gamePaused) {
    return;
  }

  for (let i = projectiles.length - 1; i >= 0; i--) {
    const projectile = projectiles[i];
    if (projectile.hit === true) {
      projectiles.splice(projectiles.indexOf(projectile), 1);
      projectile.element.remove();
      continue;
    }
    projectile.x += projectile.velocityX;
    projectile.y += projectile.velocityY;
    if (projectileHitsObstacle(projectile)) {
      projectile.element.remove();
      projectiles.splice(i, 1);
      continue;
    }
    if (
      projectile.x > fieldWidth - projectile.element.clientWidth ||
      projectile.x < 0 ||
      projectile.y > fieldHeight - projectile.element.clientHeight ||
      projectile.y < 0
    ) {
      projectile.element.remove();
      projectiles.splice(i, 1);
      continue;
    } else {
      updateProjectilePosition(projectile);
    }
  }
}

function projectileHit() {
  for (const enemyObject of enemies) {
    if (enemyObject.alive === false) continue;
    for (const projectile of projectiles) {
      if (projectile.hit === true || !(projectile.owner === "player")) continue;
      const enemyRight = enemyObject.x + enemyObject.element.clientWidth;
      const enemyDown = enemyObject.y + enemyObject.element.clientHeight;
      if (
        projectile.x + projectile.element.clientWidth > enemyObject.x &&
        enemyRight > projectile.x &&
        projectile.y < enemyDown &&
        projectile.y + projectile.element.clientHeight > enemyObject.y
      ) {
        projectile.hit = true;

        enemyObject.takeDamage(projectile.damage);
        if (enemyObject.hp <= 0) {
          enemyObject.die();
          break;
        }
      }
    }
  }
}

function checkWaveEnd() {
  if (allEnemiesDefeated() && waveTransition === false) {
    waveTransition = true;
    clearDefeatedEnemies();
    waveMessage.style.display = "block";
    waveMessage.textContent = `Welle ${currentWave} geschafft!`;
    openShop();
  }
}
function enemyProjectileHitPlayer() {
  if (!playerAlive || gamePaused || playerIsDashing) {
    return;
  }
  for (const projectile of projectiles) {
    if (projectile.hit === true || !(projectile.owner === "enemy")) continue;
    if (
      projectile.x + projectile.element.clientWidth > playerX &&
      playerX + playerWidth > projectile.x &&
      projectile.y + projectile.element.clientHeight > playerY &&
      playerY + playerHeight > projectile.y
    ) {
      projectile.hit = true;
      playerHp = Math.max(playerHp - projectile.damage, 0);

      updateHealth();
      if (playerHp === 0) {
        gameOver();
      }
    }
  }
}

function projectileHitsObstacle(projectile) {
  for (const obstacleObject of obstacles) {
    if (obstacleObject.blocksProjectiles === false) {
      continue;
    }
    if (
      projectile.x + projectile.element.clientWidth > obstacleObject.x &&
      obstacleObject.x + obstacleObject.width > projectile.x &&
      projectile.y < obstacleObject.y + obstacleObject.height &&
      projectile.y + projectile.element.clientHeight > obstacleObject.y
    ) {
      return true;
    }
  }
  return false;
}

function createObstacle(x, y, width, height, type, blocksProjectiles) {
  const element = document.createElement("div");
  element.classList.add("obstacle");
  element.classList.add(type);
  element.style.left = x + "px";
  element.style.top = y + "px";
  element.style.width = width + "px";
  element.style.height = height + "px";

  game.appendChild(element);
  const obstacle = {
    x: x,
    y: y,
    width: width,
    height: height,
    type: type,
    blocksProjectiles: blocksProjectiles,
    element: element,
  };
  obstacles.push(obstacle);
  return obstacle;
}
function isPositionBlocked(nextX, nextY, width, height) {
  for (const obstacleObject of obstacles) {
    if (
      nextX + width > obstacleObject.x &&
      obstacleObject.x + obstacleObject.width > nextX &&
      nextY < obstacleObject.y + obstacleObject.height &&
      nextY + height > obstacleObject.y
    ) {
      return true;
    }
  }
  return false;
}

function getRandomFreePosition(width, height) {
  let x = 0;
  let y = 0;
  do {
    ((x = randomValue(0, fieldWidth - width)),
      (y = randomValue(0, fieldHeight - height)));
  } while (isPositionBlocked(x, y, width, height));
  {
  }
  return { x: x, y: y };
}
function updateHealth() {
  hp.textContent = `${playerHp}/${playerMaxHp}`;
}
function updateXp() {
  xpDisplay.textContent = `${playerXp} / ${xpToNextLevel}`;
}
function updateLevel() {
  levelDisplay.textContent = playerLevel.toString();
}
function updateGold() {
  goldCounter.textContent = playerGold.toString();
}
function updateDamage() {
  damageDisplay.textContent = playerDamage.toString();
}
function updateWheatCount() {
  wheatCount.textContent = wheatCounter.toString();
}
function updateBreadCount() {
  breadCounter.textContent = breadCount.toString();
}

function updateWave() {
  if (isBossWave()) {
    waveDisplay.textContent = `${currentWave} (BOSS)`;
  } else {
    waveDisplay.textContent = currentWave.toString();
  }
}
function closeLevelUpScreen() {
  levelUpScreen.style.display = "none";
  gamePaused = false;
}

function checkLevelUp() {
  if (playerXp >= xpToNextLevel) {
    playerXp -= xpToNextLevel;
    playerLevel++;
    xpToNextLevel += 10;
    updateLevel();
    console.log("Level Up");

    gamePaused = true;
    levelUpScreen.style.display = "block";
  }
  updateXp();
}

function gameOver() {
  playerAlive = false;
  player.style.display = "none";
  console.log("Game Over");
  gameOverScreen.style.display = "block";
}
function randomValue(min, max) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

loadArea("home");
updateGold();
updateLevel();
updateDamage();
updateBreadCount();
updateRelicDisplay();
updateWheatCount();
updateXp();
updateHealth();
updateBerryPosition();
setInterval(function () {
  for (const enemyObject of enemies) {
    enemyObject.move();
    enemyObject.shoot();
    enemyObject.specialAttack();
  }
}, 500);
setInterval(function () {
  moveProjectiles();
  projectileHit();
  enemyProjectileHitPlayer();
}, 30);
