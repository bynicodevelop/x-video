import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/config_controller.dart';
import 'package:x_video_ai/controllers/loading_controller.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/chronical_prompt_model.dart';
import 'package:x_video_ai/services/chronical_service.dart';

class ChronicalController extends StateNotifier<Map<String, dynamic>> {
  final ChronicalService _chronicalService;
  final ConfigController _configController;
  final LoadingController _loadingController;

  ChronicalController(
    ChronicalService chronicalService,
    ConfigController configController,
    LoadingController loadingController,
  )   : _chronicalService = chronicalService,
        _configController = configController,
        _loadingController = loadingController,
        super({});

  Future<void> createChronical() async {
    _loadingController.startLoading('chronical');

    if (_configController.model == null ||
        _configController.model?.apiKeyOpenAi == null ||
        _configController.model?.modelOpenAi == null ||
        _configController.model?.chronicalPrompt == null) {
      _loadingController.stopLoading('chronical');

      throw Exception('Missing configuration');
    }

    ChronicalPromptModel chronicalPromptModel = ChronicalPromptModel(
      prompt: _configController.model?.chronicalPrompt ?? '',
      apiKey: _configController.model?.apiKeyOpenAi ?? '',
      model: _configController.model?.modelOpenAi ?? '',
      content:
          "Cac 40 : Lesté par le repli de Totalenergies, le CAC 40 cède du terrain Aujourd'hui à 13:42 (BFM Bourse) - L'indice parisien évolue en légère baisse à la mi-séance de ce mardi, alors que les investisseurs attendent de nouvelles statistiques économiques. La Bourse de Paris cède à la prudence ce mardi. Après avoir débuté dans le vert, le CAC 40 abandonne 0,2% à 7.627,96 points à la mi-séance. Les investisseurs attendent les nouvelles données économiques de la semaine, notamment le rapport sur l'emploi américain pour le mois d'août qui sera publié vendredi. L'indice ISM manufacturier pour le mois d'août sera par ailleurs publié à 16h, ce mardi après-midi. \"Le début de semaine prudent pour la plupart des indices de référence, aggravé par le jour férié américain d'hier, devrait être de courte durée, car nous nous attendons à ce que la volatilité du marché augmente progressivement à partir de maintenant\", explique Pierre Veyret d'Activtrades. >> Accédez à nos analyses graphiques exclusives, et entrez dans la confidence du Portefeuille Trading\nFDJ grimpe\n\"Bien qu'une certaine incertitude persiste avant les développements macroéconomiques de cette semaine et après une saison estivale mitigée pour les investisseurs, le sentiment du marché reste résistant car le manque de direction n'a pas conduit les indices de référence en territoire correctif jusqu'à présent\", juge-t-il.\nLes investisseurs américains seront de retour ce mardi, après un jour férié la veille.\nDu côté des valeurs, le CAC 40 est pénalisé par la baisse de Totalenergies, l'une des plus importantes capitalisations de l'indice, qui abandonne 1,6% dans le sillage du repli des cours du pétrole.\nLe contrat de novembre sur le Brent de mer du Nord cède 2,2% à 75,79 dollars le baril tandis que celui d'octobre sur le WTI coté à New York recule de 1,6% à 72,38 dollars le baril. Les investisseurs continuent d'être grippés par la situation économique de la Chine.\nHors CAC 40, FDJ s'adjuge 2,2% porté par un relèvement de recommandation à l'achat de la part de Deutsche Bank. Sopra Steria avance de 2,7% après avoir finalisé la cession de Sopra Banking Software à Axway Software. Valneva gagne 3,5% après avoir annoncé des données encourageantes pour son candidat-vaccin contre la maladie de Lyme. Sur les devises, l'euro perd 0,3% face au dollar à 1,1037 dollar. Julien Marion - ©2024 BFM Bourse Portefeuille Trading +310.70 % vs +53.54 % pour le CAC 40 Performance depuis le 28 mai 2008 offre spéciale 2 mois offerts function creatOutbrainJs() { const creatJs = document.createElement(\"script\"); creatJs.defer = true; creatJs.src = \"//widgets.outbrain.com/outbrain.js\"; return document.body.appendChild(creatJs); } window.didomiOnReady = window.didomiOnReady || []; window.didomiOnReady.push(function(Didomi) { console.log(\"Didomi ready \"); Didomi.getObservableOnUserConsentStatusForVendor(164) .filter(function (status) { return status !== undefined }) .subscribe(function(consentStatus) { if (consentStatus === false || consentStatus === true) { console.log(\"Didomi consent -> exécution du script outbrain \", consentStatus); creatOutbrainJs() } }); }); Votre avis Message : Envoyer Les dernières actualités du CAC 40 13h42Cac 40 : Lesté par le repli de Totalenergies, le CAC 40 cède du terrain09h00Cac 40 : L’indice parisien a ouvert la séance en hausse de +0.18%HierCac 40 : Porté par Sanofi, le CAC 40 arrache une petite hausse pour …HierCac 40 : Des statistiques chinoises décevantes pénalisent le luxe et …HierCac 40 : L’indice parisien a ouvert la séance en baisse de -0.03%Plus d'actualités",
    );

    final String chronical = await _chronicalService.createChronical(
      chronicalPromptModel,
    );

    state = {
      'chronical': chronical,
    };

    _loadingController.stopLoading('chronical');
  }
}

final chronicalControllerProvider =
    StateNotifierProvider<ChronicalController, Map<String, dynamic>>(
  (ref) {
    return ChronicalController(
      ChronicalService(
        FileGateway(),
      ),
      ref.read(configControllerProvider.notifier),
      ref.read(loadingControllerProvider.notifier),
    );
  },
);
