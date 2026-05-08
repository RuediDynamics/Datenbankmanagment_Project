# Aufgabe 2: Identifikation der Stakeholder-Rollen

---

## Kontext

Das Datenbankprojekt unterstützt ein **Immobilienverwaltungsunternehmen** (angelehnt an DreamHome), das Mietobjekte, Mieter, Besichtigungen und Mitarbeiter verwaltet.

---

## Identifizierte Stakeholder-Rollen

| Rolle | Kurzbeschreibung |
|---|---|
| Filialleiter | Strategische Übersicht über alle Objekte, Mitarbeiter und Leistungskennzahlen |
| Immobilienmakler | Tägliche Verwaltung von Objekten, Kundenkontakt und Besichtigungen |
| Rezeptionist / Sachbearbeiter | Operative Dateneingabe, Terminverwaltung und Kundenanfragen |
| Mieter | Einsicht in eigene Mietverträge, Zahlungen und Anfragen |

---

## Begründung der Rollenwahl

**Filialleiter**
Dieser Stakeholder benötigt aggregierte Berichte über Belegungsraten, Umsätze und Mitarbeiterleistung. Er trifft strategische Entscheidungen und braucht daher einen breiten, zusammenfassenden Zugriff auf alle Datenbereiche des Systems.

**Immobilienmakler**
Der Makler arbeitet täglich mit Objektdaten, Kundenprofilen und Besichtigungsterminen. Er ist auf aktuelle, detaillierte Informationen zu einzelnen Objekten und Interessenten angewiesen.

**Rezeptionist / Sachbearbeiter**
Diese Rolle ist hauptsächlich für die Dateneingabe und -pflege zuständig – z. B. neue Mieter erfassen, Termine buchen und Anfragen weiterleiten. Die Datenbedürfnisse sind operational und wiederkehrend.

**Mieter**
Mieter benötigen eingeschränkten, personalisierten Zugriff auf ihre eigenen Vertragsdetails, Zahlungshistorie und offene Anfragen. Ihre Datenbedürfnisse sind eng gefasst, aber sicherheitsrelevant.

---

## Einordnung der Datenbedürfnisse

> **Breiteste Datenbedürfnisse (analog zum Director in DreamHome):**
> 🏆 **Filialleiter** – Er benötigt systemweiten Zugriff auf alle Entitätsbereiche (Objekte, Mitarbeiter, Finanzen, Kunden) und nutzt das System primär für Auswertungen und Entscheidungsunterstützung.

> **Meiste operative, alltägliche Datenbedürfnisse (analog zum Assistant in DreamHome):**
> ⚙️ **Rezeptionist / Sachbearbeiter** – Er interagiert am häufigsten mit dem System, führt repetitive Transaktionen durch und ist auf schnellen, strukturierten Datenzugriff für die tägliche Arbeit angewiesen.
