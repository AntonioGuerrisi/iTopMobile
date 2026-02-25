# iTop Mobile

App mobile Flutter per la gestione dei **ticket** e degli **asset** salvati in [iTop](https://www.combodo.com/itop).

## Funzionalità

### Autenticazione
- **Login** con le stesse credenziali di iTop (REST API v1.3)
- **Salvataggio credenziali** sicuro con opzione "Ricordami" (flutter_secure_storage)
- **Auto-login** al riavvio dell'app se le credenziali sono salvate
- URL del server configurabile dalla schermata di login

### Ticket (UserRequest)
- **Lista ticket** con filtro temporale (ultimi 3 mesi, 6 mesi, anno, tutti) per prestazioni ottimali su grandi volumi
- **Filtri per stato**: Nuovo, Assegnato, In attesa, Risolto, Chiuso
- **Filtro "I miei ticket"**: mostra solo i ticket assegnati all'utente loggato
- **Ricerca** per titolo, riferimento o descrizione
- **Dettaglio** completo con 3 tab: Dettagli, Descrizione, Log pubblici
- **Gestione stato** del ticket con transizioni iTop:
  - Nuovo → Assegna / Risolvi
  - Assegnato → In Attesa / Risolvi / Riassegna
  - In Attesa → Riassegna / Risolvi
  - Risolto → Chiudi / Riapri
- **Aggiunta log pubblici e privati**
- **Risoluzione ticket** con selezione di servizio, sottocategoria servizio e descrizione della soluzione
- **Pull-to-refresh** sulla lista

### Asset (FunctionalCI)
- **Lista asset** con filtro per tipo (Server, VM, PC, Laptop, Stampante, ecc.)
- **Ricerca** per nome o descrizione
- **Dettaglio** completo con sezioni: Generale, Hardware, Posizione
- Gestione corretta dei campi specifici per classe (status solo per PhysicalDevice e sottoclassi)

### Altro
- **Tema chiaro/scuro** automatico basato sulle impostazioni di sistema
- **Schermata impostazioni** con info utente e logout
- **3 tab di navigazione**: Ticket, Asset, Impostazioni

## Architettura

Il progetto utilizza il pattern **Provider** per la gestione dello stato.

```
lib/
├── main.dart                          # Entry point con MultiProvider
├── theme/
│   └── app_theme.dart                 # Tema, colori priorità/stato, icone
├── models/
│   ├── ticket.dart                    # Modello Ticket (UserRequest)
│   ├── ticket_log.dart                # Modello Log entry (caselog)
│   └── asset.dart                     # Modello Asset (FunctionalCI)
├── services/
│   ├── itop_api_service.dart          # Client REST API iTop
│   └── storage_service.dart           # Gestione credenziali sicure
├── providers/
│   ├── auth_provider.dart             # Stato autenticazione + auto-login
│   ├── ticket_provider.dart           # Stato ticket + filtri + azioni
│   └── asset_provider.dart            # Stato asset + filtri
├── screens/
│   ├── login_screen.dart              # Schermata di login
│   ├── home_screen.dart               # Shell con bottom navigation
│   ├── ticket_list_screen.dart        # Lista ticket con filtri
│   ├── ticket_detail_screen.dart      # Dettaglio ticket (3 tab)
│   ├── ticket_actions_screen.dart     # Azioni ticket (log, stato, risolvi)
│   ├── asset_list_screen.dart         # Lista asset con filtri
│   ├── asset_detail_screen.dart       # Dettaglio asset
│   └── settings_screen.dart           # Impostazioni e logout
└── widgets/
    ├── ticket_card.dart               # Card ticket
    ├── asset_card.dart                # Card asset
    └── status_filter_chips.dart       # Filtri stato orizzontali
```

## Configurazione

L'app è preconfigurata per connettersi a `https://example.domain.tld`.
L'URL del server può essere modificato dalla schermata di login.

### API iTop utilizzata

L'app utilizza l'endpoint REST di iTop:
```
POST {server}/webservices/rest.php?version=1.3
```

Operazioni utilizzate:
- `core/get` — Recupera oggetti (ticket, asset, utenti, servizi, sottocategorie)
- `core/update` — Aggiorna oggetti (aggiunta log pubblici/privati)
- `core/apply_stimulus` — Applica transizioni di stato ai ticket

## Prerequisiti

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.5.0
- Android Studio / Xcode per emulatori
- Un'istanza iTop con REST API abilitate

## Installazione e avvio

```bash
# Clona il repository
git clone <url-del-repo>
cd iTopMobile

# Installa le dipendenze
flutter pub get

# Avvia su emulatore/dispositivo
flutter run

# Build APK debug
flutter build apk --debug

# Build APK release
flutter build apk --release

# Build release iOS
flutter build ios --release
```

## Dipendenze principali

| Pacchetto | Utilizzo |
|-----------|----------|
| `provider` | State management |
| `http` | Chiamate REST API |
| `flutter_secure_storage` | Salvataggio sicuro credenziali |
| `shared_preferences` | Preferenze utente |
| `intl` | Formattazione date e filtro temporale |
| `cached_network_image` | Cache immagini |
| `shimmer` | Loading skeleton |
| `pull_to_refresh_flutter3` | Pull-to-refresh liste |
| `flutter_slidable` | Azioni slide su card |

## Configurazione iTop

Assicurati che nel tuo iTop siano abilitate le REST API:
1. Vai su **Amministrazione** > **Configurazione**
2. Verifica che `itop-rest-service` sia abilitato
3. L'utente utilizzato deve avere i permessi di accesso via API

## Licenza

Vedi il file [LICENSE](LICENSE).