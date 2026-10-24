export const homeRessources = [
  {
    x: 300,
    y: 300,
    width: 50,
    height: 50,
    type: "field",
    state: "empty",
    growthTime: 3000,
    element: null,
  },
  {
    x: 380,
    y: 380,
    width: 50,
    height: 50, 
    type: "field",
    state: "empty",
    growthTime: 3000,
    element: null,
  },
  {
    x: 250,
    y: 250,
    width: 70,
    height: 70,
    type: "breadOven",
    state: "empty",
    backeTime: 3000,
    element: null,
  },
];
export function loadHomeRessources() {
  for (const homeRessourceObject of homeRessources) {
    let element = document.createElement("div");
    element.classList.add(homeRessourceObject.type);
    element.classList.add(homeRessourceObject.state);
    element.style.left = homeRessourceObject.x + "px";
    element.style.top = homeRessourceObject.y + "px";
    element.style.height = homeRessourceObject.height + "px";
    element.style.width = homeRessourceObject.width + "px";
    homeRessourceObject.element = element;
    game.appendChild(element);
  }
}
//Pflanzen wachsen lassen
export function growCrops(homeRessourceObject) {
  if (homeRessourceObject.type === "field") {
    setTimeout(() => {
      homeRessourceObject.state = "ready";
      if (homeRessourceObject.element !== null) {
        homeRessourceObject.element.classList.remove("planted");
        homeRessourceObject.element.classList.add("ready");
      }
    }, homeRessourceObject.growthTime);
  }
}

//Pflanzen ernten

export function harvestCrops(homeRessourceObject) {
  if (homeRessourceObject.type === "field") {
    if (homeRessourceObject.state === "ready") {
      homeRessourceObject.state = "empty";
      homeRessourceObject.element.classList.remove("ready");
      homeRessourceObject.element.classList.add("empty");
      wheatCounter += 1;
      updateWheatCount();
    } else {
      plantRessource(homeRessourceObject);
    }
  }
}
// Brot in den Ofen tun
export function craftBread(homeRessourceObject) {
  if (
    wheatCounter >= 2 &&
    homeRessourceObject.type === "breadOven" &&
    homeRessourceObject.state === "empty"
  ) {
    wheatCounter -= 2;
    homeRessourceObject.state = "baking";
    homeRessourceObject.element.classList.remove("empty");
    homeRessourceObject.element.classList.add("baking");
    setTimeout(() => {
      homeRessourceObject.state = "ready";
      if (homeRessourceObject.element !== null) {
        
        homeRessourceObject.element.classList.remove("baking");
        homeRessourceObject.element.classList.add("ready");
      }
    }, homeRessourceObject.backeTime);
  }
  updateWheatCount();
}
// Brot aus dem Ofen holen
export function harvestBread(homeRessourceObject) {
  if (homeRessourceObject.type === "breadOven") {
    if (homeRessourceObject.state === "ready") {
      homeRessourceObject.state = "empty";
      homeRessourceObject.element.classList.remove("ready");
      homeRessourceObject.element.classList.add("empty");
      breadCount += 1;
      updateBreadCount();
    }
  }
}