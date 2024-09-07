// Navigation (Nav Bar)
const int kEditorPage = 0;
const int kRssFeedPage = 1;
const int kSettingPage = 2;

// Loading states
const String kLoadingFeeds = "feeds";
const String kLoadingReader = "reader";
const String kLoadingContent = "content";
const String kLoadingMain = "main";

// Video orientations
const String kOrientation9_16 = "1080:1920";
const String kOrientation16_9 = "1920:1080";

// file extension
const String kVideoExtension = "mp4";
const String kImageExtension = "jpg";

// Internal prompts
const String kPromptGenerateKeywords = """
Tu es un assistant spécialiste dans le choix de mots-clés pertinents en fonction d’une phrase qu’on te fournit.
Tu n’as qu’une phrase à analyser.
Tu recevras aussi l’historique des mots-clés déjà générés avec les phrases associées.
Obligations :
- Il faut que ce soit 1 SEUL mot-clé ou 1 SEULE combinaison de mots-clés (ex : 'trading mobile' est une combinaison).
- Les mots-clés doivent être de 2 mots courts maximum.
- Les mots-clés doivent être choisis pour maximiser la précision et associer la phrase à une vidéo spécifique.
- Ajuster le choix en fonction des mots-clés déjà utilisés (pas de synonymes).
- Tu ne retourneras que le mot-clé ou la combinaison de mots-clés.
Interdictions :
- Il est interdit d’accompagner ta réponse d’un commentaire ou de ponctuation.
""";
