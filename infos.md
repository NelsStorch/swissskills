Das SwissSkills 2025 Playbook: Ein 6-Wochen-Masterplan für den Cloud-Computing-Sieg
Einleitung: Einen Champion schmieden
Die Qualifikation für die SwissSkills National Championships ist eine beachtliche Leistung, aber sie ist nur der erste Schritt. Die nationale Bühne erfordert ein höheres Mass an Kompetenz, eine Fusion aus tiefem Architekturwissen, taktischer Geschwindigkeit und strategischer Ausführung unter Druck. Dieses Dokument ist ein umfassendes Strategiehandbuch. Es ist keine einfache Lernhilfe; es ist ein sechswöchiges Intensivtrainingsprogramm, das darauf ausgelegt ist, den Wettbewerb zu dekonstruieren, das erforderliche technische Arsenal zu meistern und die Fähigkeiten auf Meisterschaftsniveau zu bringen. Dieser Plan geht über reines Auswendiglernen hinaus, um die Kerninstinkte eines Elite-Cloud-Ingenieurs zu kultivieren. Engagement, kombiniert mit diesem strategischen Plan, wird das Fundament für den Erfolg am 19. September sein.

Abschnitt 1: Der strategische Rahmen: Dekonstruktion des Wettbewerbs
Dieser Abschnitt legt die strategische Denkweise fest, die für den Sieg erforderlich ist. Er analysiert das Format, die Regeln und das Umfeld des Wettbewerbs, um eine grundlegende Strategie zu entwickeln, die jeden Aspekt der technischen Vorbereitung beeinflusst.

1.1 Beherrschung des zweiteiligen Formats: Der Architekt gegen den Sprinter
Der Wettbewerb ist bewusst so konzipiert, dass er zwei unterschiedliche, sich aber ergänzende Modi des Cloud-Engineerings testet. In einem zu brillieren, reicht nicht aus; ein Wettbewerber muss sowohl im Marathon als auch im Sprint versiert sein. Diese Struktur spiegelt die doppelten Anforderungen realer Cloud-Rollen wider, die sowohl langfristiges Projektdesign als auch schnelle operative Aufgaben umfassen. Eine Gewinnstrategie muss daher zweigeteilt sein, mit einer gezielten Vorbereitung auf jede einzelne Herausforderung.

1.1.1 Der Infrastruktur-Marathon (5-Stunden-Aufgabe): Ein Test der architektonischen Strenge
Dies ist eine umfassende Aufgabe, bei der die Wettbewerber im Laufe des Tages eine Cloud-Infrastruktur aufbauen und verfeinern. Die Schlüsselbegriffe aus der Wettbewerbsbeschreibung, "umfassend" und "miteinander verbunden", signalisieren, dass es sich nicht um eine Reihe kleiner, unabhängiger Aufgaben handelt, sondern um ein einziges, zusammenhängendes Projekt. Ein Fehler in einer frühen grundlegenden Schicht kann sich fortsetzen und die gesamte Lösung gefährden.

Das Leitprinzip für diese Aufgabe muss das AWS Well-Architected Framework sein. Das Live-Bewertungssystem wird nicht nur bewerten, ob eine Ressource existiert, sondern auch, ob sie gemäss den Best Practices korrekt aufgebaut ist. Bevor etwas gebaut wird, muss ein Wettbewerber die Anforderung gedanklich auf die sechs Säulen abbilden: Operative Exzellenz, Sicherheit, Zuverlässigkeit, Leistungseffizienz, Kostenoptimierung und Nachhaltigkeit.   

Die manuelle Konfiguration in der AWS-Konsole ist für diese Aufgabe ungeeignet; sie ist langsam, fehleranfällig und schwer zu ändern. Das primäre Werkzeug für die Ausführung muss AWS CloudFormation sein. Durch die Definition von Infrastruktur als Code (IaC) kann ein Wettbewerber schnelle, wiederholbare und leicht modifizierbare Bereitstellungen erreichen. Die Vorbereitung sollte die Erstellung modularer Vorlagen für gängige Architekturkomponenten wie VPCs, Sicherheitsgruppen, IAM-Rollen und EC2-Startvorlagen umfassen.   

Das Live-Bewertungssystem sollte als Echtzeit-Feedbackschleife in einer iterativen Bereitstellungsstrategie verwendet werden. Ein methodischer, schichtweiser Ansatz ist optimal:

Bereitstellung der grundlegenden Schicht (z. B. VPC, Subnetze, Routing-Tabellen) über einen CloudFormation-Stack.

Innehalten und auf die Punktevergabe durch das Bewertungssystem für diese Schicht warten, um deren Korrektheit zu bestätigen.

Nach der Bestätigung die nächste abhängige Schicht bereitstellen (z. B. Sicherheitsgruppen, Datenbank-Subnetze).
Dieser Ansatz verhindert den Aufbau einer komplexen Anwendung auf einem fehlerhaften Fundament, was bei einer vernetzten Aufgabe katastrophal wäre.

Fünf Stunden sind eine beträchtliche Zeit, aber sie werden ohne richtiges Management schnell vergehen. Die ersten 30-45 Minuten sollten ausschliesslich der Planung gewidmet sein. Dies beinhaltet das Lesen der gesamten Aufgabenstellung, das Diagrammieren der erforderlichen Architektur, das Identifizieren aller Service-Integrationen und das Ausarbeiten der notwendigen CloudFormation-Stacks. Ein solider Plan verhindert kostspielige Nacharbeiten und panische Entscheidungen im späteren Verlauf.

1.1.2 Die Speed-Challenge (1h 45m Aufgabe): Ein Test der taktischen Effizienz
Dieser Teil des Wettbewerbs testet die Fähigkeit, "so viele kleine Aufgaben wie möglich zu bewältigen". Die Aufgaben sind "unabhängig", was bedeutet, dass die Schlüsselmetriken Geschwindigkeit und Genauigkeit sind. Die grafische Benutzeroberfläche (GUI) der AWS Management Console ist hier der Feind; sie ist für eine wettbewerbsfähige Leistung zu langsam.

Das primäre Werkzeug für diese Phase muss die AWS Command Line Interface (CLI) sein. Der Erfolg ist direkt proportional zur CLI-Gewandtheit. Die Vorbereitung muss über einfache Befehle wie    

aws s3 mb hinausgehen. Die Wettbewerber sollten die Verwendung von Shell-Skripten (bash oder zsh) beherrschen, um Befehle zu verketten und Sequenzen zu automatisieren. Entscheidend ist die Beherrschung des --query-Parameters mit JMESPath-Syntax und das Weiterleiten der Ausgabe an Werkzeuge wie jq für fortgeschrittenes Filtern und Extrahieren von Daten. Dies ermöglicht das programmatische Abrufen von Ressourcen-IDs, Zuständen oder anderen Eigenschaften, die für nachfolgende Befehle benötigt werden, und eliminiert zeitaufwändige manuelle Suchen in der Konsole.   

Angesichts des Zeitlimits ist die Aufgabentriage eine entscheidende Fähigkeit. Ein Wettbewerber sollte die ersten fünf Minuten damit verbringen, so viele Aufgaben wie möglich durchzulesen, um die "niedrig hängenden Früchte" zu identifizieren – Aufgaben, die mit einem oder wenigen bekannten CLI-Befehlen erledigt werden können. Diese zuerst auszuführen, baut Momentum auf und sichert schnell Punkte. Die Vorbereitung sollte das Erstellen und Auswendiglernen eines persönlichen "Spickzettels" mit gängigen, komplexen CLI-Befehlen für die Kerndienste umfassen, wobei die bereitgestellte Recherche als Ausgangspunkt dient.   

1.2 Die Spielregeln und die Vorbereitung der Umgebung
Die Regeln sind nicht nur Einschränkungen; sie sind Teil der Herausforderung selbst. Eine unzureichende Vorbereitung der Wettbewerbsumgebung kann zur Disqualifikation oder zu einem erheblichen Leistungsnachteil führen.

1.2.1 Effektive Nutzung des uneingeschränkten Internets
Die Bereitstellung eines uneingeschränkten Internetzugangs ist keine Krücke für mangelndes Wissen; es ist ein Präzisionswerkzeug für die gezielte Informationsbeschaffung. Es wird keine Zeit geben, einen Dienst von Grund auf zu lernen. Das grundlegende Wissen muss vor Beginn des Wettbewerbs solide sein. Das Internet sollte verwendet werden für:

Schnelles Finden spezifischer CloudFormation-Ressourcensyntax oder Eigenschaftsnamen.

Nachschlagen detaillierter AWS CLI-Befehlsflags oder -optionen.

Zugriff auf die offizielle AWS-Dokumentation für API-Limits, Service-Quotas oder spezifische Konfigurationsdetails.

Das Üben der effizienten Navigation in der AWS-Dokumentation ist eine Fähigkeit für sich. Ein Wettbewerber sollte wissen, wo er den CloudFormation User Guide, die CLI Command Reference und die Entwicklerhandbücher für Schlüsseldienste findet. Schnelles Lesen und effektives Suchen sind entscheidende Fähigkeiten, die es zu schärfen gilt.

1.2.2 BYOD-Protokoll und KI-Embargo: Die kritische Vorbereitung vor dem Wettbewerb
Die "Bring Your Own Device" (BYOD)-Richtlinie, gekoppelt mit einer strengen "Keine KI"-Regel, ist eine potenzielle Falle für Unvorbereitete. Viele moderne Entwicklungswerkzeuge haben KI-Unterstützung tief integriert, und die Verwendung eines verbotenen Werkzeugs, selbst versehentlich, führt zum sofortigen Ausschluss. Darüber hinaus schafft die Abhängigkeit von KI-Unterstützung während des Trainings eine Abhängigkeit, die einen Wettbewerber am Wettbewerbstag erheblich langsamer und ungenauer machen wird.

Daher muss eine vollständige Überprüfung der Entwicklungsumgebung durchgeführt werden, um jegliche KI-gestützte Unterstützung zu deaktivieren. Dies ist ein kritischer Risikominderungsschritt, der vor dem Wettbewerb abgeschlossen und überprüft werden muss.

Tabelle 1: BYOD KI-Deaktivierungs-Checkliste

Werkzeug/Anwendung	Zu deaktivierendes Feature	Schritt-für-Schritt-Anleitung	Überprüfungsmethode
Visual Studio Code	GitHub Copilot Extension	
1. Gehen Sie zur Ansicht "Erweiterungen" (Ctrl+Shift+X). 2. Suchen Sie nach "GitHub Copilot" und "GitHub Copilot Chat". 3. Klicken Sie bei beiden Erweiterungen auf "Deaktivieren" oder "Deinstallieren". 4. Starten Sie VS Code neu.    

Das Copilot-Symbol in der Statusleiste ist verschwunden. Beim Tippen erscheinen keine Code-Vorschläge.
Visual Studio Code	Inline-Vervollständigungen	
1. Öffnen Sie die Befehlspalette (Ctrl+Shift+P). 2. Geben Sie "Configure Copilot Completions" ein und wählen Sie es aus. 3. Wählen Sie "Disable Completions".    

Beim Tippen erscheinen keine ausgegrauten Textvorschläge.
Google Chrome	AI Overviews (SGE)	
1. Gehen Sie zu google.com/searchlabs. 2. Melden Sie sich bei Ihrem Google-Konto an. 3. Suchen Sie die Karte "AI Overviews and more" oder "SGE". 4. Schalten Sie die Funktion aus.    

Eine Google-Suche generiert keine grosse KI-gestützte Zusammenfassung oben in den Ergebnissen.
Google Chrome	Autocomplete-Vorschläge	
1. Öffnen Sie die Chrome-Einstellungen. 2. Navigieren Sie zu "Ich und Google" > "Synchronisierung und Google-Dienste". 3. Deaktivieren Sie "Suchanfragen und URLs vervollständigen".    

Beim Tippen in der Adressleiste erscheinen nur der lokale Verlauf und Lesezeichen, keine erweiterten Web-Vorschläge.
Andere IDEs (JetBrains, etc.)	Integrierte KI-Assistenten	Beziehen Sie sich auf die Dokumentation der spezifischen IDE, um alle integrierten KI-Code-Vervollständigungs-Plugins (z. B. "AI Assistant" in JetBrains) zu finden und zu deaktivieren.	In der IDE sind keine KI-gestützten Code-Vervollständigungs- oder Chat-Funktionen aktiv.
Browser-Erweiterungen	Alle KI-/Grammatik-Tools	Überprüfen und deaktivieren oder entfernen Sie manuell alle Browser-Erweiterungen, die KI-gesteuerte Unterstützung bieten, wie z. B. Grammarly, QuillBot oder ähnliche Tools.	Die Erweiterungssymbole sind in der Browser-Symbolleiste nicht mehr aktiv.
Abschnitt 2: Das technische Arsenal: Beherrschung der AWS-Service-Landschaft
Mit einem strategischen Rahmen rückt der Fokus nun auf die technischen Werkzeuge. Alle 24 spezifizierten Dienste in sechs Wochen in gleicher Tiefe zu beherrschen, ist unmöglich und ineffizient. Ein Triage-System ist notwendig, um die Anstrengungen auf das zu konzentrieren, was die meisten Punkte bringt. Die Dienstliste ist nicht flach; sie ist ein Abhängigkeitsbaum. Die Beherrschung grundlegender Dienste ist eine Voraussetzung für die effektive Nutzung von Diensten auf Anwendungsebene. Der Wettbewerb wird die Integration dieser Dienste testen, nicht nur isoliertes Wissen. Zum Beispiel kann man keine serverlose Anwendung (Tier 2) erstellen, ohne zuerst das Netzwerk zu verstehen, in dem sie läuft (VPC - Tier 1), und die Berechtigungen, die sie benötigt (IAM - Tier 1).

Tabelle 2: AWS Service Triage-Matrix

Tier	Dienstname	Kernfunktion	Wichtige Wettbewerbskonzepte	Primärer Anwendungsfall
1	IAM	Verwaltet den sicheren Zugriff auf AWS-Services und -Ressourcen.	Richtlinien (JSON), Rollen, Bedingungen, Identitäts- vs. ressourcenbasierte Richtlinien.	Beide
1	VPC	Stellt einen logisch isolierten Abschnitt der AWS Cloud bereit.	Multi-AZ-Design, Subnetze, Routing-Tabellen, NAT/Internet-Gateways, Endpunkte.	Beide
1	EC2	Bietet skalierbare Rechenkapazität (virtuelle Server).	AMIs, Startvorlagen, Auto Scaling Groups, Instanztypen.	Beide
1	S3	Bietet skalierbaren Objektspeicher.	Buckets, Versionierung, Lebenszyklusrichtlinien, Cross-Region Replication (CRR).	Beide
1	CloudFormation	Modelliert und provisioniert AWS-Infrastruktur als Code.	Vorlagen, Parameter, Mappings, Bedingungen, intrinsische Funktionen (!Ref, !GetAtt).	Infrastruktur-Aufgabe
2	Lambda	Führt Code aus, ohne Server bereitzustellen oder zu verwalten.	Ereignisgesteuerte Ausführung, IAM-Ausführungsrollen, Auslöser.	Beide
2	API Gateway	Erstellt, veröffentlicht und verwaltet APIs.	HTTP- vs. REST-APIs, Lambda-Integration, Anfrage-/Antwort-Mapping.	Infrastruktur-Aufgabe
2	DynamoDB	Bietet eine vollständig verwaltete NoSQL-Schlüssel-Wert-Datenbank.	Tabellen, Primärschlüssel (Partition, Sort), Lese-/Schreibkapazitätseinheiten.	Infrastruktur-Aufgabe
2	ECS & ECR	Führt containerisierte Anwendungen aus und speichert sie.	Task-Definitionen, Services, Cluster, Fargate-Starttyp, Pushen von Images zu ECR.	Infrastruktur-Aufgabe
2	Route 53	Bietet einen skalierbaren Domain Name System (DNS)-Webservice.	Gehostete Zonen, Record-Sets (A, CNAME), Routing-Richtlinien.	Infrastruktur-Aufgabe
2	CloudFront	Liefert Inhalte weltweit mit geringer Latenz und hohen Übertragungsgeschwindigkeiten.	Distributionen, Ursprünge (S3, ALB), Cache-Verhalten, SSL mit ACM.	Infrastruktur-Aufgabe
2	SQS & SNS	Bietet verwaltete Nachrichtenwarteschlangen (SQS) und Benachrichtigungsdienste (SNS).	Warteschlange vs. Thema, Entkopplung von Anwendungen, Fan-Out-Muster.	Infrastruktur-Aufgabe
3	CloudWatch	Überwacht Ressourcen und Anwendungen auf AWS.	Metriken, Alarme, Protokolle.	Beide
3	Systems Manager	Bietet Betriebsdaten und Automatisierung für AWS-Ressourcen.	Run Command, Parameter Store.	Speed-Challenge
3	KMS	Erstellt und verwaltet kryptografische Schlüssel.	Customer Managed Keys (CMKs), Service-Integration für Verschlüsselung.	Beide
3	Secrets Manager	Hilft beim Schutz von Geheimnissen, die für den Zugriff auf Anwendungen und Dienste benötigt werden.	Speichern/Abrufen von Datenbankanmeldeinformationen, API-Schlüsseln.	Infrastruktur-Aufgabe
3	Certificate Manager	Stellt öffentliche und private SSL/TLS-Zertifikate bereit, verwaltet und implementiert sie.	Integration mit ALB und CloudFront.	Infrastruktur-Aufgabe
3	CodePipeline & CodeBuild	Automatisiert Continuous Integration und Delivery (CI/CD)-Pipelines.	Pipeline-Stufen, Build-Projekte, Quell-/Build-/Deploy-Aktionen.	Infrastruktur-Aufgabe
3	ElastiCache	Bietet einen In-Memory-Datenspeicher oder Cache.	Redis- vs. Memcached-Engines, Verbesserung der Datenbank-Leseleistung.	Infrastruktur-Aufgabe
3	EFS	Bietet ein einfaches, skalierbares, elastisches Dateisystem.	Geteilter Speicher für mehrere EC2-Instanzen (z. B. für WordPress).	Infrastruktur-Aufgabe
3	CloudShell	Bietet eine browserbasierte Shell mit vorinstallierter AWS CLI.	Schneller Zugriff auf eine vorauthentifizierte CLI-Umgebung.	Speed-Challenge

In Google Sheets exportieren
2.1 Tier 1: Die Kern-Fünf - Grundlegende Beherrschung (60% der Lernzeit)
Diese Dienste sind das Fundament fast jeder Lösung auf AWS. Ein tiefes, nuanciertes Verständnis hier ist nicht verhandelbar. Sie werden sowohl in der Infrastruktur- als auch in der Speed-Challenge vorkommen.

IAM (Identity and Access Management): Dies ist das Sicherheitsfundament. Die Vorbereitung muss über das Erstellen von Benutzern hinausgehen. Ein Wettbewerber muss das Schreiben granularer IAM-Richtlinien mit Bedingungen (z. B. aws:SourceIp, aws:RequestTag) beherrschen, den Unterschied zwischen identitätsbasierten und ressourcenbasierten Richtlinien verstehen und IAM-Rollen für die Service-zu-Service-Kommunikation erstellen und annehmen können.   

VPC (Virtual Private Cloud): Dies ist das Netzwerkfundament. Ein Wettbewerber muss in der Lage sein, eine sichere, Multi-AZ-VPC von Grund auf zu entwerfen und zu erstellen. Dies umfasst öffentliche und private Subnetze, Routing-Tabellen, Internet-Gateways, NAT-Gateways und Netzwerk-ACLs. Ein kritisches Studiengebiet ist die Unterscheidung zwischen Gateway-Endpunkten (für S3/DynamoDB, kostenlos, verwendet Routing-Tabelleneinträge) und Schnittstellen-Endpunkten (für die meisten anderen Dienste, kostenpflichtig, verwendet Elastic Network Interfaces). Dies ist ein häufiger Verwirrungspunkt und ein wahrscheinliches Testthema.   

EC2 (Elastic Compute Cloud) & S3 (Simple Storage Service): Dies sind die Kern-Rechen- und Speicherdienste. Bei EC2 sollte der Fokus auf Startvorlagen, Auto Scaling Groups und dem Verständnis verschiedener Instanztypen liegen. Bei S3 muss das Wissen über einfache Buckets hinausgehen, um Versionierung, Lebenszyklusrichtlinien und Cross-Region Replication (CRR) zu beherrschen. Ein Wettbewerber sollte in der Lage sein, diese Dienste schnell über die CLI zu konfigurieren.   

CloudFormation: Dies ist das Automatisierungsfundament und das primäre Werkzeug für die Infrastruktur-Aufgabe. Die Beherrschung der Vorlagenstruktur ist unerlässlich, einschliesslich Parametern, Mappings (für umgebungsspezifische Konfigurationen wie unterschiedliche AMIs oder Instanztypen), Bedingungen (zum Umschalten der Ressourcenerstellung) und Ausgaben. Ein Wettbewerber muss die Verwendung intrinsischer Funktionen wie !Ref und !GetAtt üben, um Ressourcen dynamisch miteinander zu verbinden.   

2.2 Tier 2: Der Anwendungs- & Daten-Stack (30% der Lernzeit)
Diese Dienste werden verwendet, um die eigentlichen Anwendungen zu erstellen, die auf der Kerninfrastruktur laufen. Ein Wettbewerber wird mit ziemlicher Sicherheit mehrere davon kombinieren müssen, um die Infrastruktur-Aufgabe zu lösen.

Das Serverless-Trio (Lambda, API Gateway, DynamoDB): Dies ist ein grundlegendes Muster für moderne Anwendungen. Es ist entscheidend, das Lambda-Ausführungsmodell zu verstehen, wie man API Gateway als Auslöser konfiguriert (Unterscheidung zwischen HTTP-API und REST-API) und die Grundlagen von DynamoDB (Tabellen, Primärschlüssel, Lese-/Schreibkapazität).   

Container-Dienste (ECS, ECR): Der Fokus sollte auf dem Verständnis der grundlegenden Konzepte liegen: eine Task-Definition (der Bauplan für eine Anwendung), ein Service (hält eine bestimmte Anzahl laufender Tasks aufrecht) und ein Cluster (die logische Gruppierung von Tasks oder Instanzen). Ein Wettbewerber sollte wissen, wie man ein Docker-Image erstellt, es in die Elastic Container Registry (ECR) pusht und es auf Elastic Container Service (ECS) mit dem Fargate-Starttyp (serverless) ausführt.

Routing & Caching (Route 53, CloudFront, ElastiCache): Ein Wettbewerber sollte wissen, wie man eine Domain bei Route 53 registriert und A/CNAME-Einträge erstellt. Er muss die Rolle von CloudFront bei der Verteilung von Inhalten von einem Ursprung wie einem S3-Bucket oder einem Application Load Balancer verstehen. Obwohl ElastiCache wahrscheinlich kein tiefer Fokus sein wird, ist es wichtig, seinen Zweck (In-Memory-Caching für Redis/Memcached) zur Verbesserung der Datenbankleistung zu kennen.

Entkopplungsdienste (SQS, SNS): Den Unterschied zwischen einer Warteschlange (SQS, für Eins-zu-Eins-, dauerhafte Nachrichtenübermittlung zwischen Komponenten) und einem Thema (SNS, für Eins-zu-Viele-, Fan-Out-Benachrichtigungen) zu verstehen, ist ein Schlüsselkonzept beim Aufbau zuverlässiger, verteilter Architekturen.

2.3 Tier 3: Der unterstützende & spezialisierte Stack (10% der Lernzeit)
Diese Dienste sind wichtig, aber entweder spezialisierter oder können "just-in-time" mit dem erlaubten Internetzugang gelernt werden. Ein solides konzeptionelles Verständnis dessen, was sie tun und wann sie verwendet werden, ist ausreichend.

Betrieb & Überwachung (CloudWatch, Systems Manager): Wissen, wie man Protokolle anzeigt und grundlegende Alarme in CloudWatch erstellt. Für Systems Manager (SSM) die Rolle bei der Verwaltung von EC2-Instanzen verstehen, z. B. das Ausführen von Befehlen mit Run Command oder das Speichern von Konfigurationsdaten mit Parameter Store.

Sicherheit & Geheimnisse (KMS, Secrets Manager, Certificate Manager): Verstehen, dass KMS für die Verwaltung von Verschlüsselungsschlüsseln, Secrets Manager für die sichere Speicherung von Datenbankanmeldeinformationen oder API-Schlüsseln und Certificate Manager (ACM) für die Bereitstellung von SSL/TLS-Zertifikaten für Dienste wie CloudFront und Load Balancer zuständig ist.

CI/CD (CodePipeline, CodeBuild): Den konzeptionellen Fluss verstehen: CodePipeline orchestriert den Workflow (z. B. Quelle -> Build -> Deploy), und CodeBuild führt die Build- und Testbefehle in einer temporären Umgebung aus.

Dateisysteme (EFS): Wissen, dass EFS ein gemeinsam genutztes, elastisches Dateisystem bereitstellt, auf das mehrere EC2-Instanzen zugreifen können, oft verwendet für ältere Anwendungen wie WordPress, die einen gemeinsamen Inhaltsspeicher benötigen.   

Shell (CloudShell): Dies ist ein praktisches Werkzeug. Es ist eine vorauthentifizierte CLI-Umgebung, die im Browser verfügbar ist. Es ist nützlich für schnelle Aufgaben, sollte aber eine ordnungsgemäss konfigurierte lokale CLI auf der BYOD-Maschine nicht ersetzen.

Abschnitt 3: Der Architekten-Bauplan: Gängige Wettbewerbsmuster
Elite-Wettbewerber kennen nicht nur Dienste; sie wissen, wie man sie zu Lösungen kombiniert. Dieser Abschnitt geht von einzelnen Diensten zu integrierten Architekturmustern über. Die Infrastruktur-Aufgabe wird mit ziemlicher Sicherheit eine Variante eines dieser Muster sein. Das Ziel ist es, das erforderliche Muster aus der Aufgabenstellung zu erkennen und sofort mit der Implementierung einer bekannten, guten Architektur zu beginnen. Dieses "architektonische Muskelgedächtnis" spart immense Zeit in der entscheidenden anfänglichen Designphase und verhindert grundlegende Fehler.

3.1 Muster 1: Die hochverfügbare, mehrschichtige Webanwendung
Dies ist die klassische Cloud-Architektur und ein erstklassiger Kandidat für die Infrastruktur-Aufgabe aufgrund ihrer umfassenden Natur, die Wissen über Netzwerk, Rechenleistung, Datenbanken und Sicherheit testet.

Architekturzusammenfassung: Eine öffentlich zugängliche Web-Schicht, eine private Anwendungsschicht und eine private Datenschicht, alle über mehrere Availability Zones verteilt für Ausfallsicherheit und hohe Verfügbarkeit.   

Schlüsseldienste & Konfiguration:

Präsentations-/Web-Schicht: EC2-Instanzen werden in öffentlichen Subnetzen platziert und von einer Auto Scaling Group verwaltet, um schwankenden Datenverkehr zu bewältigen. Ein Application Load Balancer (ALB) befindet sich vor diesen Instanzen, verteilt den Verkehr und führt Zustandsprüfungen durch.   

Logik-/Anwendungsschicht: EC2-Instanzen werden in privaten Subnetzen platziert, ebenfalls von einer Auto Scaling Group verwaltet. Diese Instanzen können nur von der Sicherheitsgruppe der Web-Schicht erreicht werden. Um auf das Internet zuzugreifen, z. B. zum Herunterladen von Software-Updates, verwenden sie ein NAT-Gateway in einem öffentlichen Subnetz.   

Datenschicht: Eine Amazon RDS-Datenbank (z. B. MySQL, PostgreSQL) wird für die Multi-AZ-Bereitstellung konfiguriert. Dies erstellt eine synchrone Standby-Replik in einer anderen Availability Zone für einen automatischen Failover. Die Datenbankinstanzen befinden sich in dedizierten privaten Subnetzen für maximale Isolation.   

Sicherheit: Eine mehrschichtige Verteidigung mit Sicherheitsgruppen ist entscheidend. Die Sicherheitsgruppe des ALB erlaubt eingehenden Verkehr aus dem Internet (Port 80/443). Die Sicherheitsgruppe der Web-Schicht erlaubt eingehenden Verkehr nur von der Sicherheitsgruppe des ALB. Die Sicherheitsgruppe der App-Schicht erlaubt eingehenden Verkehr nur von der Sicherheitsgruppe der Web-Schicht. Schliesslich erlaubt die Sicherheitsgruppe der Datenbank eingehenden Verkehr auf dem Datenbankport (z. B. 3306 für MySQL) nur von der Sicherheitsgruppe der App-Schicht. Dies implementiert das Prinzip des geringsten Privilegs auf Netzwerkebene.   

3.2 Muster 2: Die moderne serverlose Anwendung
Dieses Muster repräsentiert einen moderneren, ereignisgesteuerten Ansatz, der Skalierbarkeit, Kosteneffizienz und schnelle Entwicklung betont. Es ist ein starker Kandidat für eine Aufgabe, bei der der Betriebsaufwand minimiert werden soll.

Architekturzusammenfassung: Ein statisches Frontend, das auf S3 gehostet und von CloudFront ausgeliefert wird und mit einem Backend kommuniziert, das aus serverlosen Komponenten wie API Gateway, Lambda und DynamoDB aufgebaut ist.   

Schlüsseldienste & Konfiguration:

Frontend: Ein Single-Page-Application (SPA)-Build (z. B. React, Vue) wird in einen S3-Bucket hochgeladen, der für statisches Website-Hosting konfiguriert ist. Eine Amazon CloudFront-Distribution wird vor den S3-Bucket geschaltet, um globales Caching, geringe Latenz und eine benutzerdefinierte Domain mit einem von AWS Certificate Manager bereitgestellten SSL/TLS-Zertifikat zu bieten.   

Backend-API: Amazon API Gateway (typischerweise eine HTTP-API für Einfachheit und geringere Kosten) empfängt Anfragen von der Frontend-Anwendung. Jeder API-Endpunkt und jede Methode (z. B. GET /users, POST /products) ist so konfiguriert, dass sie eine bestimmte Lambda-Funktion auslöst.   

Geschäftslogik & Zustand: AWS Lambda-Funktionen enthalten die Geschäftslogik. Sie erhalten spezifische, minimale Berechtigungen über IAM-Rollen, um mit einer DynamoDB-Tabelle zum Speichern und Abrufen von Anwendungsdaten zu interagieren.   

3.3 Muster 3: Die serverlose Daten-/Bildverarbeitungspipeline
Dieses Muster testet die Fähigkeit, einen ereignisgesteuerten Workflow zu erstellen, ein häufiger Anwendungsfall im Data Engineering und in der Backend-Verarbeitung. Es demonstriert ein Verständnis für asynchrone, entkoppelte Systeme.

Architekturzusammenfassung: Ein Ereignis, wie das Hochladen einer Datei auf Amazon S3, löst eine Kette automatisierter Verarbeitungsschritte ohne manuell bereitgestellte Server aus.   

Schlüsseldienste & Konfiguration:

Ingestion: Ein S3-Bucket wird als "Quell-" oder "Lande-"Zone für eingehende Dateien konfiguriert.

Auslösung: Eine S3-Ereignisbenachrichtigung wird auf dem Quell-Bucket konfiguriert. Wenn ein neues Objekt erstellt wird (z. B. ein Bild hochgeladen wird), löst das Ereignis eine AWS Lambda-Funktion aus und übergibt Ereignisdetails wie den Bucket-Namen und den Objektschlüssel.   

Verarbeitung: Die Lambda-Funktion empfängt das Ereignis, verwendet die bereitgestellten Informationen, um das Objekt von S3 herunterzuladen, führt eine Transformation durch (z. B. Grössenänderung eines Bildes mit einer Bibliothek, Parsen einer CSV-Datei) und bereitet das Ergebnis vor.

Speicherung & Metadaten: Die verarbeitete Ausgabe wird in einem separaten "Ziel"-S3-Bucket gespeichert. Optional können Metadaten über den Prozess (z. B. neue Bildabmessungen, Anzahl der verarbeiteten Zeilen aus einer CSV) zur Nachverfolgung und Abfrage in eine DynamoDB-Tabelle geschrieben werden.   

3.4 Muster 4: Die gehärtete, automatisierte AMI-Pipeline
Dieses Muster testet Fähigkeiten in Sicherheit und DevOps-Automatisierung (DevSecOps). Es ist ein fortgeschrittenes Szenario, das zeigt, wie man sichere und wiederholbare Infrastruktur aufbaut.

Architekturzusammenfassung: Eine automatisierte Pipeline wird verwendet, um ein standardisiertes, sicheres und gepatchtes "goldenes" Amazon Machine Image (AMI) zu erstellen, das dann für alle EC2-Bereitstellungen verwendet wird.   

Schlüsseldienste & Konfiguration:

Image-Erstellung: EC2 Image Builder wird verwendet, um eine Image-Pipeline zu definieren, die den Erstellungsprozess automatisiert.

Basis-Image: Die Pipeline beginnt mit einem Standard-Amazon Linux 2 AMI oder, für eine fortgeschrittenere Aufgabe, einem vom Center for Internet Security (CIS) gehärteten AMI, das vom AWS Marketplace abonniert wird.   

Härtung/Anpassung: Image Builder-Komponenten werden verwendet, um Sicherheitspatches anzuwenden, notwendige Software (wie Überwachungsagenten) zu installieren und das Betriebssystem gemäss den Sicherheits-Best-Practices zu konfigurieren.   

Ausgabe: Die Ausgabe der Pipeline ist ein benutzerdefiniertes, versioniertes, goldenes AMI.

Bereitstellung: Eine EC2-Startvorlage wird erstellt, die dieses neue goldene AMI spezifiziert. Diese Startvorlage wird dann in einer Auto Scaling Group verwendet, um sicherzustellen, dass alle bereitgestellten Instanzen vom Start an sicher und konform sind.   

Abschnitt 4: Der 6-Wochen-Trainings-Spießrutenlauf: Ihr Weg zur Spitzenleistung
Dies ist ein detaillierter, wochenweiser Trainingsplan. Er integriert die strategischen Prinzipien, das technische Wissen und die Architekturmuster in einen umsetzbaren Zeitplan. Jede Woche hat ein Thema, spezifische Lernziele aus den bereitgestellten AWS-Schulungsmaterialien und einen "Challenge Day", um den Wettbewerbsdruck zu simulieren. Die Einhaltung dieses Zeitplans ist entscheidend für den Erfolg.

Tabelle 3: Der 6-Wochen-Trainings-Spießrutenlauf

Woche	Täglicher Fokus (Mo-Fr)	Wichtige Themen & Trainingsmodule	Hands-On-Lab-Fokus	Samstags-Challenge-Tag	Sonntags-Review
1	Grundlagen & CLI-Beherrschung	IAM: Richtlinien, Rollen. VPC: Subnetze, RTs, Endpunkte. EC2/S3: ASGs, CRR. (Skill Builder Module 2, 3, 4, 5)	
Bauen Sie eine sichere VPC manuell auf. Üben Sie das S3 CRR-Tutorial. Üben Sie grundlegende CLI-Befehle für alle Tier-1-Dienste.   

Speed-Challenge-Sim: 90 Min., 15+ reine CLI-Aufgaben zu Tier-1-Diensten. Stoppen Sie die Zeit für jede Aufgabe.	Analysieren Sie die CLI-Geschwindigkeit. Identifizieren Sie langsame Befehle und üben Sie sie.
2	Infrastructure as Code	CloudFormation: Vorlagenstruktur, !Ref, !GetAtt, !FindInMap, Bedingungen. (AWS Academy "Automation with CFN")	
Bauen Sie die VPC aus Woche 1 mit CloudFormation neu. Verwenden Sie Mappings für CIDR-Blöcke. Bauen Sie die ASG mit einer Bedingung neu.   

Infra-Task-Sim (Teil 1): Bauen Sie das gesamte Netzwerk & die Sicherheit für Muster 1 nur mit CloudFormation. Ziel < 2 Stunden.	Refaktorieren Sie CFN-Vorlagen für Modularität und Lesbarkeit. Fügen Sie Kommentare hinzu.
3	Architektur für Ausfallsicherheit	Muster 1: ALBs, Zielgruppen, Multi-AZ RDS. (Skill Builder Module 6, 7; Academy "High Availability")	Bauen Sie Muster 1 manuell in der Konsole. Bauen Sie dann das gesamte Muster mit verschachtelten CloudFormation-Stacks.	Vollständiger Muster-1-Build: Stellen Sie aus einem leeren Konto die vollständige, funktionale mehrschichtige Web-App mit Ihren CFN-Vorlagen bereit. Stoppen Sie die Zeit.	Dokumentieren Sie Ihre Muster-1-CFN-Vorlagen für schnellen Zugriff.
4	Architektur für Agilität	Muster 2, 3, 4: Lambda, API Gateway, DynamoDB, S3-Ereignisse, EC2 Image Builder. (Skill Builder Module 11, 12)	
Bauen Sie eine serverlose API. Bauen Sie die serverlose Bildverarbeitungspipeline. Bauen Sie eine einfache "goldene AMI"-Pipeline.   

Gemischte Muster-Übungen: 3-4 Mini-Szenarien, die jeweils einen schnellen Aufbau der Muster 2, 3 oder 4 erfordern. Fokus auf Geschwindigkeit.	Konsolidieren Sie alle CFN-Snippets und CLI-Skripte in einem organisierten Ordnersystem.
5	Geschwindigkeits- & Genauigkeitsübungen	Wettbewerbssimulation: Fokus auf Geschwindigkeit, Genauigkeit und Umgang mit Druck.	
Täglich Vormittag: 1-stündige Speed-Challenge-Übungen mit AWS Jam  oder Challenge Labs.   

Täglich Nachmittag: 2-stündige Infra-"Sprints" (z. B. Bereitstellung eines Multi-AZ RDS über CFN).	Vollständige Wettbewerbssimulation: 7-stündige Generalprobe. 4-stündige Schein-Infra-Aufgabe, 1 Stunde Pause, 1h 45m Schein-Speed-Challenge. Strikte Zeitmessung.	Tiefgehende Überprüfung: Analysieren Sie Ihre Leistung der vollständigen Simulation. Identifizieren Sie Zeitfresser, Fehler und Wissenslücken.
6	Abschliessende Überprüfung & Vorbereitung	Gezieltes Schwächentraining: Konzentrieren Sie sich ausschliesslich auf Bereiche, die in der vollständigen Simulation als schwach identifiziert wurden.	Üben Sie die spezifischen Aufgaben und Muster, die während der Simulation langsam oder fehleranfällig waren. Wiederholen, bis sie schnell und fehlerfrei sind.	Umgebungs-Lock-down: Bereiten Sie den BYOD-Laptop vor. Führen Sie die Checkliste aus Tabelle 1 durch. Organisieren Sie alle Skripte und Notizen.	Ruhe und mentale Konsolidierung. Keine technische Arbeit.
Fazit: Exzellente Ausführung am Wettbewerbstag
Die Vorbereitungszeit ist eine Gelegenheit, die Fähigkeiten und die Denkweise eines Champions zu schmieden. Der bereitgestellte Sechs-Wochen-Plan ist ein strenger, aber effektiver Weg zur Spitzenleistung. Er dekonstruiert systematisch den Wettbewerb, priorisiert die riesige AWS-Service-Landschaft, baut Gewandtheit in kritischen Architekturmustern auf und simuliert den Druck des eigentlichen Ereignisses.

Am Wettbewerbstag ist das Ziel nicht zu lernen, sondern auszuführen. Ein Wettbewerber, der diesen Plan befolgt hat, wird das notwendige Wissen im Kopf und die Befehle im Muskelgedächtnis haben. Der Schlüssel zum Sieg wird darin liegen, der Vorbereitung zu vertrauen, die Zeit effektiv zu managen und die Probleme sorgfältig zu lesen, bevor man beginnt. Für die Infrastruktur-Aufgabe sollte das Well-Architected Framework die Leitphilosophie sein. Für die Speed-Challenge muss die AWS CLI eine Erweiterung des Denkens sein. Indem man ruhig und konzentriert bleibt und die geübten Strategien ausführt, kann ein Wettbewerber die in den vorangegangenen Wochen entwickelten Fähigkeiten auf Meisterschaftsniveau demonstrieren.
