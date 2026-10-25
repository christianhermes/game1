# SPIELVISION – verbindliche Designentscheidungen

**Stand: 2026-10-25.** Dieses Dokument beschreibt das **gewünschte Spiel**, nicht bereits implementierte Funktionen. Der tatsächliche Code bestimmt den Iststand. Neuere ausdrückliche Nutzerentscheidungen haben Vorrang. Unentschiedene Details nicht als beschlossen behandeln.

**Einstieg:** [AGENTS.md](AGENTS.md) · **Umsetzung:** [ENTWICKLUNGSPLAN.md](ENTWICKLUNGSPLAN.md) · **Historie:** [docs/archiv/](docs/archiv/)

## 1. Verbindliche Spielregeln für die Planung (aktualisiert 2026-10-25)

### Beschlossen: Perspektive, Spielfigur und Welt
- **Basis im Stil von Going Medieval:** isometrische/freie Übersichtskamera, Zoom/Rotation und Mausinteraktion; keine permanente Third-Person-Steuerung in der Siedlung.
- **Abenteuer im Stil der Steuerungs-/Kameraperspektive von Stardew Valley:** direkte Kontrolle des eigenen Charakters in einer Top-down-/schrägen Übersichtsperspektive; vorläufig weiterhin **stilisiertes Low-Poly-3D**, kein beschlossener Wechsel zu Pixel-Art/2D.
- **Dieselbe Figur in beiden Modi:** in der Basis der erste autonom arbeitende Bewohner/NPC mit Aufgaben und Wegfindung, bei Expeditionen direkt gesteuerter Held. Einheitliche Identität, Ausrüstung, Inventar und Stats.
- **Basis läuft während Expeditionen weiter (Variante B):** NPCs arbeiten, Transporte, Pflanzenwachstum, Verderb und passive Produktion laufen fort. Technisch darf eine vereinfachte ereignis-/zeitbasierte Hintergrundsimulation verwendet werden; keine aufwendige Offscreen-3D-Simulation nötig. Der auf Expedition befindliche Held steht für Basisaufträge nicht zur Verfügung.
- **Basisangriffe:** sehr spät, zunächst isometrische taktische Ansicht mit NPC-Verteidigung. Direktes Übernehmen des Charakters während einer Basisschlacht ist ausdrücklich **weit hinten** und kein frühes Ziel.
- **Spielstart:** in einer zerstörten ehemaligen Stadt. Ruinen sind verwertbare Ressourcenquellen, restaurierbare/abbaubare Bauobjekte und Fundorte für Hinweise; Freiräumen kann Keller/Wege/Fundstellen freilegen.
- **Atmosphäre:** gemütlicher, hoffnungsvoller Wiederaufbau mit düsterer Vergangenheit und optionaler Kriminal-/Fantasy-Ermittlung. **Konkrete Story, Täter, Stadtname, Figuren, Beweisabfolge und Enden sind NICHT beschlossen und werden nicht jetzt implementiert.**

### Beschlossen: Bewohner, Rekrutierung und Arbeit
- Der eigene Charakter ist **NPC Nr. 1**; anfangs erledigt er Arbeiten nacheinander. Zusätzliche Bewohner erlauben parallele Arbeit.
- Gemeinsames Auftragssystem für Bewohner: bewegen, Ressourcen bergen/sammeln, Holzfällen, Transportieren, Bauen, Landwirtschaft und Werkstationen bedienen; Prioritäten und nachvollziehbare Blockadegründe.
- **NPC-Tiefe B:** individuell, aber überschaubar: Fähigkeiten, Arbeitsprioritäten, Vorlieben/Eigenschaften und wenige Bedürfnisse (zunächst Nahrung/Schlaf als spätere Stufe). Keine frühe komplexe Sozial-/Stimmungssimulation.
- Rekrutierung **kombiniert** gewöhnliche anreisende Bewohner (Wohnraum/Versorgung als mögliche Voraussetzungen) und besondere ehemalige Bewohner/Personen aus Expeditionen und Quests. Spezielle NPCs können Wissen/Rezepte/Bonusfähigkeiten bringen; keine endgültigen Namen/Berufe/Quoten.
- Arbeit und Materialtransporte werden durch **NPCs** erledigt. Keine magische Materialteleportation. Arbeits- und Transportaufträge müssen dieselben realen Bestände verwenden.
- **Esel gestrichen aus dem Kernspiel und der frühen/mittleren Roadmap.** Eventuell später als Nutztier/Transporttier wie Kühe, Hühner usw.; kein anfänglicher Transportesel, keine eselspezifischen Prioritäten oder Ladepunkte.
- Aktive Werkstationen erfordern **Arbeit eines zugewiesenen Bewohners**, nicht zwingend direkte Eingabe des Spielers. Passive Stationen verarbeiten nach Belieferung/Start selbstständig.

### Beschlossen: Funktionsräume, Arbeit und lokale Versorgung (2026-10-25)
- **Raumregel C:** Jeder erkannte, geschlossene Raum kann **eine Hauptfunktion** erhalten (z. B. Zimmermannswerkstatt, Schmiede, Küche, Vorratskammer). Andere Tätigkeiten und Werkstationen im selben Raum bleiben erlaubt; keine exklusive Funktionssperre.
- **Voraussetzungen:** Eine Hauptfunktion wird erst betriebsbereit, wenn die erforderlichen konkreten Objekte/Stationen vorhanden und nutzbar sind (z. B. Werkbank für Zimmermann, Esse und Amboss für Schmiede). Exakte Objektlisten und Boni werden je Raumtyp später definiert.
- **Spezialisierung:** Hauptfunktion kann klar kommunizierte, moderate Vorteile bieten; nicht spezialisierte Räume/Mehrzweckwerkstätten bleiben grundsätzlich nutzbar. Keine Pflicht, jedem Raum einen Typ zuzuweisen.
- **Raum-Arbeitszuweisung:** Ein oder mehrere Bewohner können einem Raum bzw. dessen Arbeitsplätzen zugeordnet werden. Produktionsaufträge werden an geeigneten Stationen durch zugewiesene Bewohner abgearbeitet; die Anzahl gleichzeitiger Tätigkeiten hängt von realen Arbeitsplätzen ab, nicht nur vom Raumlabel.
- **Lokale Lager:** Kisten, Regale, Stapel etc. sind echte physische Behälter mit eigenen Beständen/Kapazitäten; ein Raum erhält **kein unsichtbares magisches Inventar**. Geeignete lokale Lager können dem Raum/Stationen zugeordnet werden. Bestandsziel und Filter je Lager oder Raum sind als späterer Konfigurationskomfort vorgesehen.
- **Materialversorgung:** Verfügbare Transport-NPCs bringen Materialien aus physisch erreichbaren Lagern. Fehlt ein Transporteur, dürfen zugewiesene Arbeiter erforderliche Materialien **selbst holen**. Fehlen Materialien/Platz/Wege, wird die Arbeit nachvollziehbar pausiert. Entnahme, Reservierung und Transport verhindern Doppelverwendung, Verlust und endloses Pendeln.
- **Produktionswarteschlangen:** Jedes Rezept besitzt höchstens einen sichtbaren Auftrag mit einer Wiederholungsmenge. Die Liste ist manuell nach Priorität sortierbar; der oberste ausführbare Auftrag wird unabhängig von seiner Wiederholungsmenge zuerst berücksichtigt. Jeder Auftrag kann gezielt abgebrochen werden.
- **Transporttiere:** Esel können **später optional** dieselbe allgemeine Logistik unterstützen; weder Starttier noch Voraussetzung für Funktionsräume oder frühe Transportlogik.
- **Später optional:** Raumübergreifende Produktionsketten, Auftragsreihenfolgen, Zielbestände wie „20 Brote halten“, automatische Zwischenproduktplanung. **Nicht** Teil der ersten Raumversion.
- **Umbauten:** Raumgrenzen, fehlende Pflichtobjekte, Raumteilungen/-zusammenlegungen und unzugängliche Arbeitsplätze müssen Status/Zuordnung aktualisieren; Materialien bleiben in ihren realen Behältern.

### Weiterhin gültige Kernregeln
- Stilisiertes Low-Poly-3D; kleine, testbare Entwicklungsschritte; wenig Grind.
- Spielerinventar: begrenzte Slots und Stapel, Rucksack-Upgrades, **kein Gewichtssystem**.
- Physische, voneinander unabhängige Kisten; Siedlungsübersicht ist nur lesend. Kein globaler, ortsunabhängiger Materialzugriff.
- Werkstationen: Zugriff auf Kisten im selben geschlossenen Raum bzw. in einem kleinen lokalen Außenradius; weitere Wege erfordern physischen NPC-Transport.
- Materialreservierungen verhindern Doppelverwendung, Transporte verlieren/duplizieren nichts.
- Lebensmittel-Frische: frisch, normal, alt, verdorben; Lagerbehälter/Raumtyp beeinflussen Haltbarkeit.
- Forschung über Entdeckungen und Meilensteine; Zweige Bau, Handwerk, Landwirtschaft, Versorgung, Arkane Künste als langfristige Designrichtung.
- Ruhige Bauphasen ohne ständige Überfälle; Kampf/Expedition bleiben wichtig, ohne den Siedlungsaufbau zu dominieren.

## Nicht Teil der aktuellen Umsetzung

Komplexe Sozial- und Stimmungssysteme, Tiere/Esel als Logistikvoraussetzung, detaillierte Temperatursimulation, direkte Heldenübernahme bei Basisangriffen und eine festgeschriebene Mystery-Handlung. NPCs und reale Transporte sind dagegen Teil des neuen Kernkonzepts, jedoch schrittweise umzusetzen.
