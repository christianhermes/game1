export class Enemy {
  constructor(x, y, element, healthElement, isBoss, type) {
    let baseHp = 20 + currentWave * 10;
    let baseDamage = 10;
    const baseXp = 10;
    let baseMovement = 5;
    const baseAttackCooldown = 1000;
    this.x = x;
    this.y = y;
    this.element = element;
    this.healthElement = healthElement;
    this.movement = isBoss ? baseMovement - 2 : baseMovement;
    this.damage = isBoss ? baseDamage * 2 : baseDamage;
    this.canAttack = true;
    this.hp = isBoss ? baseHp * 3 : baseHp;
    this.alive = true;
    this.xp = isBoss ? baseXp * 5 : baseXp;
    this.isBoss = isBoss;
    this.attackCooldown = isBoss
      ? baseAttackCooldown + 500
      : baseAttackCooldown;
    this.type = type;
    this.goldDropValue = 10;
  }

  // Gegner bewegen lassen
  move() {
    if (!this.alive || !playerAlive || gamePaused) {
      return;
    }
    let nextX = this.x;
    let nextY = this.y;
    if (this.x > playerX) {
      nextX = this.x - this.movement;
    } else if (this.x < playerX) {
      nextX = this.x + this.movement;
    }
    if (this.y > playerY) {
      nextY = this.y - this.movement;
    } else if (this.y < playerY) {
      nextY = this.y + this.movement;
    }
    moveEnemyWithCollision(this, nextX, nextY);
    enemyCollision(this);
  }
  dropGold() {
    const dropGoldElement = document.createElement("div");
    dropGoldElement.classList.add("drop");
    dropGoldElement.classList.add("gold");
    dropGoldElement.style.left = this.x + "px";
    dropGoldElement.style.top = this.y + "px";
    const goldDrop = {
      x: this.x,
      y: this.y,
      value: this.goldDropValue,
      element: dropGoldElement,
    };

    game.appendChild(dropGoldElement);
    goldDrops.push(goldDrop);
  }
  // Position des Gegners ändern
  updatePosition() {
    this.element.style.left = this.x + "px";
    this.element.style.top = this.y + "px";
  }
  //Lebensanzeige des Gegeners ändern
  updateHealth() {
    const healthPercentage = Math.max(0, (this.hp / this.maxHp) * 100);

    // healthElement ist die innere farbige Füllung des Lebensbalkens.
    this.healthElement.style.width = healthPercentage + "%";

    if (healthPercentage > 60) {
      this.healthElement.style.backgroundColor = "green";
    } else if (healthPercentage > 30) {
      this.healthElement.style.backgroundColor = "yellow";
    } else {
      this.healthElement.style.backgroundColor = "red";
    }
  }
  //Lebend es Gegners verringern
  takeDamage(damage) {
    this.hp = Math.max(this.hp - damage, 0);
    this.updateHealth();

    // Der Gegner leuchtet kurz auf, damit der Treffer sofort erkennbar ist.
    this.element.classList.add("hit");
    setTimeout(() => {
      this.element.classList.remove("hit");
    }, 100);

    // Die Schadenszahl liegt direkt im Spielfeld. Dadurch bleibt sie auch dann
    // kurz sichtbar, wenn der getroffene Gegner durch diesen Treffer stirbt.
    const hitDamage = document.createElement("span");
    hitDamage.textContent = `-${damage}`;
    hitDamage.classList.add("damage-number");
    hitDamage.style.left = this.x + this.element.clientWidth / 2 + "px";
    hitDamage.style.top = this.y + "px";
    game.appendChild(hitDamage);

    // Nach dem Ende der CSS-Animation wird das Element aus dem DOM entfernt.
    setTimeout(() => {
      hitDamage.remove();
    }, 500);
  }
  //Gegner sterben lassen
  die() {
    if (this.alive === false) {
      return;
    }
    if (this.isBoss) {
      dropRelic(this);
    }
    this.alive = false;
    this.element.style.display = "none";
    this.element.remove();
    playerXp += this.xp;
    checkLevelUp();
    checkWaveEnd();
    this.dropGold();
  }
  shoot() {}
  specialAttack() {}
}

class Skeleton extends Enemy {
  constructor(x, y, element, healthElement, isBoss) {
    super(x, y, element, healthElement, isBoss, "skeleton");
    this.damage = 7;
    this.canAttack = true;
    this.hp = 20;
    this.alive = true;
    this.canShoot = true;
    this.shootCooldown = 1500;
  }
  move() {
    if (!this.alive || !playerAlive || gamePaused) {
      return;
    }
    const distance = Math.hypot(playerX - this.x, playerY - this.y);
    let nextX = this.x;
    let nextY = this.y;

    if (distance > 220) {
      if (this.x > playerX) {
        nextX = this.x - this.movement;
      } else if (this.x < playerX) {
        nextX = this.x + this.movement;
      }
      if (this.y > playerY) {
        nextY = this.y - this.movement;
      } else if (this.y < playerY) {
        nextY = this.y + this.movement;
      }
    } else if (distance < 140) {
      if (this.x > playerX) {
        nextX = Math.min(
          this.x + this.movement,
          fieldWidth - this.element.clientWidth,
        );
      } else if (this.x < playerX) {
        nextX = Math.max(this.x - this.movement, 0);
      }
      if (this.y > playerY) {
        nextY = Math.min(
          this.y + this.movement,
          fieldHeight - this.element.clientHeight,
        );
      } else if (this.y < playerY) {
        nextY = Math.max(this.y - this.movement, 0);
      }
    }
    moveEnemyWithCollision(this, nextX, nextY);
    enemyCollision(this);
  }
  shoot() {
    if (!this.alive || !playerAlive || gamePaused || this.canShoot === false) {
      return;
    }
    const skeletonCenterX = this.x + this.element.clientWidth / 2;
    const skeletonCenterY = this.y + this.element.clientHeight / 2;
    const startX = skeletonCenterX - projectileWidth / 2;
    const startY = skeletonCenterY - projectileHeight / 2;

    // Dieser Vektor zeigt von der Gegnerposition zur aktuellen Spielerposition.
    const deltaX = playerX - this.x;
    const deltaY = playerY - this.y;
    const distance = Math.hypot(deltaX, deltaY);
    if (distance === 0) {
      return;
    }

    // Erst nach allen Prüfungen wird der Gegner bis zum nächsten Schuss gesperrt.
    this.canShoot = false;

    // Das Teilen durch distance normalisiert den Vektor.
    // So fliegt das Projektil mit Geschwindigkeit 6 in jedem Winkel gleich schnell.
    const projectileSpeed = 6;
    const velocityX = (deltaX / distance) * projectileSpeed;
    const velocityY = (deltaY / distance) * projectileSpeed;

    shootProjectile(startX, startY, velocityX, velocityY, this.damage, "enemy");

    // Nach dem Cooldown darf genau dieser Gegner wieder ein Projektil erzeugen.
    setTimeout(() => {
      this.canShoot = true;
    }, this.shootCooldown);
  }
}

export class Boss extends Enemy {
  constructor(x, y, element, healthElement, isBoss) {
    super(x, y, element, healthElement, isBoss, "boss");
    this.isBoss = true;
    this.xp = 50;
    this.canUseSpezial = true;
    this.specialCooldown = 3000;
    this.specialAttackRange = 150;
    this.specialDamage = 50;
    this.isChargingSpecial = false;
  }

  move() {
    // Während des Aufladens bleibt der Boss im Mittelpunkt seines Warnkreises.
    if (this.isChargingSpecial) {
      return;
    }
    super.move();
  }

  specialAttack() {
    if (!this.alive || !playerAlive || gamePaused || !this.canUseSpezial) {
      return;
    }

    const bossCenterX = this.x + this.element.clientWidth / 2;
    const bossCenterY = this.y + this.element.clientHeight / 2;
    const playerCenterX = playerX + player.clientWidth / 2;
    const playerCenterY = playerY + player.clientHeight / 2;
    const deltaX = playerCenterX - bossCenterX;
    const deltaY = playerCenterY - bossCenterY;
    const distance = Math.hypot(deltaX, deltaY);

    // Der Boss startet den Spezialangriff erst, wenn der Spieler in Reichweite ist.
    if (distance > this.specialAttackRange) {
      return;
    }

    this.canUseSpezial = false;
    this.isChargingSpecial = true;
    this.element.classList.add("charging-special");

    // Der Warnkreis hat den doppelten Angriffsradius als Breite und Höhe.
    // Durch das Abziehen des Radius liegt sein Mittelpunkt genau auf dem Boss.
    const specialWarningElement = document.createElement("div");
    specialWarningElement.classList.add("special-warning");
    specialWarningElement.style.width = this.specialAttackRange * 2 + "px";
    specialWarningElement.style.height = this.specialAttackRange * 2 + "px";
    specialWarningElement.style.left =
      bossCenterX - this.specialAttackRange + "px";
    specialWarningElement.style.top =
      bossCenterY - this.specialAttackRange + "px";
    game.appendChild(specialWarningElement);

    setTimeout(() => {
      // Visuelle Effekte werden immer entfernt, auch wenn der Angriff abgebrochen wird.
      specialWarningElement.remove();
      this.element.classList.remove("charging-special");
      this.isChargingSpecial = false;

      if (!this.alive || !playerAlive || gamePaused) {
        return;
      }

      // Der Spieler kann sich während der Warnzeit bewegen. Deshalb werden die
      // Mittelpunkte und die Entfernung beim Auslösen noch einmal berechnet.
      const currentBossCenterX = this.x + this.element.clientWidth / 2;
      const currentBossCenterY = this.y + this.element.clientHeight / 2;
      const currentPlayerCenterX = playerX + player.clientWidth / 2;
      const currentPlayerCenterY = playerY + player.clientHeight / 2;
      const currentDeltaX = currentPlayerCenterX - currentBossCenterX;
      const currentDeltaY = currentPlayerCenterY - currentBossCenterY;
      const currentDistance = Math.hypot(currentDeltaX, currentDeltaY);

      if (currentDistance <= this.specialAttackRange) {
        playerHp = Math.max(playerHp - this.specialDamage, 0);
        updateHealth();

        if (playerHp === 0) {
          gameOver();
          return;
        }

        // Der normalisierte Richtungsvektor schiebt den Spieler vom Boss weg.
        // Bei Entfernung 0 gibt es keine eindeutige Richtung für den Rückstoß.
        if (currentDistance > 0) {
          const knockbackStrength = 50;
          const nextPlayerX = Math.max(
            0,
            Math.min(
              playerX + (currentDeltaX / currentDistance) * knockbackStrength,
              maxX,
            ),
          );
          const nextPlayerY = Math.max(
            0,
            Math.min(
              playerY + (currentDeltaY / currentDistance) * knockbackStrength,
              maxY,
            ),
          );

          // Hindernisse stoppen auch den Rückstoß.
          if (
            !isPositionBlocked(
              nextPlayerX,
              nextPlayerY,
              playerWidth,
              playerHeight,
            )
          ) {
            playerX = nextPlayerX;
            playerY = nextPlayerY;
            updatePlayerPosition();
          }
        }
      }
    }, 700);

    setTimeout(() => {
      this.canUseSpezial = true;
    }, this.specialCooldown);
  }
}

export class Exploder extends Enemy {
  constructor(x, y, element, healthElement, isBoss) {
    super(x, y, element, healthElement, isBoss, "exploder");
    this.hp = 10;
    this.movement = 25;
    this.damage = 15;
    this.canExplode = true;
    this.explosionRange = 100;
    this.isCharging = false;
  }
  // Exploder bewegen lassen

  move() {
    if (!this.alive || !playerAlive || gamePaused || this.isCharging) {
      return;
    }
    const distance = Math.hypot(playerX - this.x, playerY - this.y);

    let nextX = this.x;
    let nextY = this.y;
    if (this.x > playerX) {
      nextX = this.x - this.movement;
    } else if (this.x < playerX) {
      nextX = this.x + this.movement;
    }
    if (this.y > playerY) {
      nextY = this.y - this.movement;
    } else if (this.y < playerY) {
      nextY = this.y + this.movement;
    }
    if (distance <= this.explosionRange) {
      this.isCharging = true;
      this.element.classList.add("charging");
      setTimeout(() => {
        if (!this.alive) {
          return;
        }
        this.alive = false;
        checkWaveEnd();
        explosion.style.left = this.x + "px";
        explosion.style.top = this.y + "px";
        explosion.style.display = "block";
        setTimeout(() => {
          explosion.style.display = "none";
          this.element.style.display = "none";
          this.element.remove();
        }, 500);

        const distance = Math.hypot(playerX - this.x, playerY - this.y);
        if (distance <= this.explosionRange) {
          playerHp = Math.max(playerHp - this.damage, 0);
          updateHealth();
          if (playerHp === 0) {
            gameOver();
          }
        }
      }, 700);

      return;
    }
    moveEnemyWithCollision(this, nextX, nextY);
    enemyCollision(this);
  }
}