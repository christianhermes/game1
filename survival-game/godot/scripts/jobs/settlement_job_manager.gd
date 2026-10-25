extends Node


# Die Auftragsarten bleiben zunächst bewusst klein. Neue Arten kommen erst
# hinzu, wenn ein konkretes Gameplay-System sie benötigt.
enum JobType {
	MOVE,
	PICKUP,
}


# Der Status beschreibt den Lebenszyklus eines Auftrags unabhängig davon,
# ob die Basisszene gerade geladen ist.
enum JobStatus {
	OPEN,
	RUNNING,
	FINISHED,
}


# Jeder neue Auftrag erhält eine eindeutige laufende Nummer. Das Dictionary
# speichert die Auftragsdaten unter genau dieser Nummer.
var next_job_id := 1
var jobs: Dictionary = {}


# Erstellt einen einzelnen Auftrag und liefert seine eindeutige ID zurück.
func create_job(
	job_type: JobType,
	target_id: StringName,
	target_position: Vector3,
	worker_id: StringName,
) -> int:
	# Die aktuelle ID wird für diesen Auftrag festgehalten, bevor der Zähler
	# für den nächsten Auftrag erhöht wird.
	var job_id := next_job_id
	next_job_id += 1

	# Alle für Szenenwechsel relevanten Auftragsdaten werden als Werte
	# gespeichert. Dadurch hängt der Manager nicht von einem geladenen Node ab.
	jobs[job_id] = {
		"id": next_job_id -1,
		"type": job_type,
		"target_id": target_id,
		"target_position": target_position,
		"worker_id": worker_id,
		"status": JobStatus.OPEN,
		}

	return job_id


# Liefert die Daten eines Auftrags. Eine unbekannte ID ergibt ein leeres
# Dictionary, sodass Aufrufer den fehlenden Auftrag mit is_empty() erkennen.
func get_job(job_id: int) -> Dictionary:
	return jobs.get(job_id, {})
