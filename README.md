# nanoHTTP - Ein einfacher einbindbarer Webserver

Was gerade Windowsprogrammierern missfällt ist der Gedanke, eine Anwendung über das Netzwerk mit sich selbst oder dem eigenen System kommunizieren zu lassen. Und in den meisten fällen ist das auch garnicht nötig. Zumindest mit Windows nicht. Die grafische Benutzeroberfläche einer Linuxdistribution hingegen hat keine andere Wahl. Dort gehört es zum Systemkonzept, das die Clientanwendungen ihre Benutzeroberfläche anzeigen, in dem sie mit einem Server kommunizieren, der sich meist auf dem gleichen System befindet.

Seit Jahren steigt der Trend, modernere Benutzeroberflächen mit Hilfe von Webtechnologien zu realisieren. Nun stellt sich die Frage aber: Wie macht man das am besten? Ein Browser-Steuerelement steht bereits seit Ewigkeiten den Programmierern in nahezu jeder Sprache zur Verfügung. Auch in Purebasic ist das WebGadget fester Bestandteil. Der Nachteil daran ist nur, das dieses Steuerelement kaum eine Möglichkeit bietet, mit der Host-Applikation zu kommunizieren. Mit dem aus dem Purebasic-Forum frisch veröffentlichten ExWebGadget auf Chromium-Basis ist es zwar möglich, aus Purebasic heraus auf Javascript-Funktionen/-Methoden oder umgekehrt zu zugreifen. Aber zum einen ist dieses Gadget ausschließlich auf Windows lauffähig und zum anderen benötigt es das .NET Framework.

Unter MacOSX sowie Linux wird stattdessen für das normale Webgadget das WebKitGTK verwendet, welches deutlich moderner ist als das IE-Gadget von Windows. Hier ist aber der gegenseitige Zugriff auf Prozeduren/Funktionen/Methoden allerdings nicht möglich. Es muss also ein Bindeglied her, das die Host-Applikation mit dem Browser-Steuerelement kommunizieren lässt. Und am naheliegendsten ist nun einmal der Webserver.

Dafür habe ich den nanoHTTP geschrieben. Es ist ein einfacher Webserver, der sich in die Host-Applikation einbinden lässt. Der Server kann statische Dateien entweder aus dem Dateisystem oder sogar direkt aus einem Zip-Archiv an das jeweilige Gadget liefern. Aber man kann auch eigene Prozeduren verwenden, die das Gadget ansprechen kann, in dem man die Prozedur einfach an eine URL koppelt.

## Die Betriebsmodis

### Dateisystem

nanoHTTP liefert statische Dateien in diesem Modus aus dem Dateisystem heraus aus. Das Verhalten ist dabei ähnlich eines jedem Webserver. Bei Start des Servers über die entsprechende Prozedur legt man das Home-Directory fest. Es kann entweder ein vollständiger oder ein relativer Pfad angegeben werden. Ein relativer Pfad erleichtert das Verschieben oder Verbreiten der Anwendung. Nicht mit dem Zip-Archiv-Modi kombinierbar.

### Zip-Archiv

Auch Dateien aus einem Zip-Archiv kann der Server liefern. Das Archiv wird intern genauso behandelt wie das Home-Directory. Nicht mit dem Dateisystem-Modi kombinierbar.

### Prozedur

Dieser Modus ist von den anderen beiden Modis unabhängig und wird priorisiert behandelt. Mit diesem Modus ist es möglich, eine Server-URL auf eine Purebasic-Prozedur zu routen. Dadurch wird es möglich, mit dem System zu arbeiten. Innerhalb dieser Callback-Prozedur stehen einem alle Purebasic-Prozeduren zur Verfügung. Das Ergebnis dieser Prozedur lässt sich als HTML, CSS, Javascript, JSON oder anderen Datentypen zurückliefern. Prozeduren haben eine höhere Priorität. Wird eine Route zum Beispiel als `app/index.html` definiert und existiert unter der gleichen URL eine Datei aus Dateisystem oder dem Archiv, dann werden diese ignoriert.

## Die Optionen

### nanoHTTP::Port

Hier wird der Port für den Server konfiguriert. Als Standard ist hier der Port **12345** gesetzt. Nach Möglichkeit sollte immer ein Port über 1024 gewählt werden.

### nanoHTTP::IPMask

Die IP-Maske, welche Zugriff auf den Server haben darf. Als Standard ist hier **127.0.0.1** gesetzt. Dadurch reagiert der Server nur auf Verbindung von dieser IP.

### nanoHTTP::DefaultFile

Diese Option gibt die Standard-Datei an, die aus Dateisystem oder Archiv aufgerufen wird, wenn keine Datei in der URL angegeben und keine Prozedur existiert. Als Standard ist hier wie gewohnt **index.html** gesetzt.

## Prozeduren für die Prozedur

Folgende Prozeduren sind für den Einsatz innerhalb der URL-Prozedur gedacht und sollten auch nur da verwendet werden.

### nanoHTTP::SetHeader(Field.s, Value.s)

Hiermit können eigene Headerfelder definiert werden, die der Server an den Client bei der Antwort mitsendet. Vor allem für den HTTP Statuscode wichtig. Die 3 Felder für das Protokoll, dem Statuscode und der Status-Message haben eigene feste Bezeichner.

1. **Protocol:** Ist ohne Änderung auf *HTTP/1.1*
2. **Status:** Der Status-Code ohne Änderung auf *200*
3. **StatusMessage:** Ohne Änderung auf *OK*

Beispiel für SetHeader:

```basic
nanoHTTP::SetHeader("Status", "404")
nanoHTTP::SetHeader("StatusMessage", "File not found")
```

### nanoHTTP::SendResponseData(Adress.i, DataSize.i, MimeType.s)

Sendet Daten aus dem Speicher an den Client. Als MimeType reicht die bloße Dateiendung. Hat das Modul nicht den passenden Typ parat, werden die Daten als Octed-Stream gesendet. Bei der Adresse handelt es sich um den Pointer des Speichers und mit Datasize muss die Größe angegeben werden.

Beispiel für SendResponseData:

```basic
String.s = "<p>Kleiner Absatz!</p>"
Size.i = StringByteLength(String, #PB_UTF8)

*Buffer = AllocateMemory(Size + 1)
PokeS(*Buffer, String, Size, #PB_UTF8)

nanoHTTP::SendResponseData(*Buffer, Size, "html")
```

### nanoHTTP::SendResponseString(ResponseString.s, MimeType.s)

Mit dieser Prozedur können Daten, die als String beim Client ankommen sollen auch direkt an den Client senden. Auch hier reicht die Dateiendung aus, um den richtigen Mimetype an den Client zu übermitteln.

Beispiel für SendResponseString:

```basic
String.s = "<p>Kleiner Absatz!</p>"
nanoHTTP::SendResponseString(String, "html")
```

Schon kürzer, oder? Das Ergebnis ist das gleiche.

### nanoHTTP::ParseHTTPContent(ContentString.s, Map TargetMap.s())

Eine Hilfsprozedur, die einen URL-kodierten Key-Value String in die übergebene Map schreibt.

Beispiel für ParseHTTPContent

```basic
NewMap Params.s()
String.s = "feld1=Feld%201&feld2=Feld%202"

nanoHTTP::ParseHTTPContent(String, Params())

Debug Params("feld1")		; gibt "Feld 1" aus
Debug Params("feld2")		; gibt "Feld 2" aus
```

## Prozeduren zur Vorbereitung

Diese Prozedur wird außerhalb der Anwendung verwendet, allerdings noch vor dem Serverstart.

### nanoHTTP::SetDynamicApp(Route.s, Callback.i)

Hiermit wird eine Prozedur einer URL zugewiesen. Wird diese URL vom Client aufgerufen, führt der Server die Prozedur aus. Eine Prozedur muss immer die Parameter Map.s und String haben. Siehe Beispiel:

```basic
Procedure GetVersion(Map Header.s(), ContentString)
	nanoHTTP::SendResponseString("1.0.0.0", "txt")
EndProcedure

nanoHTTP::SetDynamicApp("intern/getversion", @GetVersion())
; wenn ein Browser nun 127.0.0.1:12345/intern/getversion aufruft, steht im Fenster 1.0.0.0
```

## Der Server

Nun geht es ans eingemachte. Der Server kann endgültig gestartet werden.

**ACHTUNG:** Der Server ist Threadblocked. Das heißt er läuft über eine Endlosschleife. Es ist zu empfehlen, den Server über CreateThread laufen zu lassen.

Die Prozedur StartServer lässt den Server laufen. Die Parameter der Prozeduren steuern die Modis. Entweder Dateisystem, Zip-File oder ohne Datei-Routen (nur Prozeduren). Default ist der Modus auf `#NHTTP_DIRTYPE_FILESYSTEM` und das Home-Directory auf `webdir/` gestellt.

```
nanoHTTP::StartServer(nanoHTTP::#NHTTP_DIRTYPE_FILESYSTEM, "htdocs/")
; Startet den Server mit dem Home-Directory htdocs

nanoHTTP::StartServer(nanoHTTP::#NHTTP_DIRTYPE_ZIP, "htdocs.zip")
; Startet den Server im Zip-Modi und verweist auf htdocs.zip

nanoHTTP::StartServer(nanoHTTP::#NHTTP_DIRTYPE_NONE, "")
; Startet den Server ohne Dateirouting und verarbeitet nur noch Prozeduren-URL's
```

