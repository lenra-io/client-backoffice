import 'package:client_backoffice/navigation/backoffice_navigator.dart';
import 'package:client_backoffice/navigation/url_strategy/url_strategy.dart' show setUrlStrategyTo;
import 'package:client_common/config/config.dart';
import 'package:client_common/models/auth_model.dart';
import 'package:client_common/models/build_model.dart';
import 'package:client_common/models/cgu_model.dart';
import 'package:client_common/models/deployment_model.dart';
import 'package:client_common/models/store_model.dart';
import 'package:client_common/models/user_application_model.dart';
import 'package:client_common/oauth/oauth_model.dart';
import 'package:flutter/material.dart';
import 'package:lenra_components/lenra_components.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  setUrlStrategyTo('path');

  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  debugPrint("Starting main app[debugPrint]: ${Config.instance.application}");
  // TODO: Récupération de variables d'environnement ne doit pas marcher
  const environment = String.fromEnvironment('ENVIRONMENT');

  if (environment == "production" || environment == "staging") {
    String sentryDsn = Config.instance.sentryDsn;
    await SentryFlutter.init(
      (options) => options
        ..dsn = sentryDsn
        ..environment = environment,
      appRunner: () => runApp(Backoffice()),
    );
  } else {
    runApp(Backoffice());
  }
}

class Backoffice extends StatelessWidget {
  Backoffice({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var themeData = LenraThemeData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OAuthModel>(
          create: (context) => OAuthModel(
            '604adb70-20f9-4b2a-b7b2-233f86a04976',
            'http://localhost:10000/redirect.html',
            scopes: ['manage:account', 'manage:apps', 'store'],
          ),
        ),
        ChangeNotifierProvider<AuthModel>(create: (context) => AuthModel()),
        ChangeNotifierProvider<BuildModel>(create: (context) => BuildModel()),
        ChangeNotifierProvider<DeploymentModel>(create: (context) => DeploymentModel()),
        ChangeNotifierProvider<UserApplicationModel>(create: (context) => UserApplicationModel()),
        ChangeNotifierProvider<StoreModel>(create: (context) => StoreModel()),
        ChangeNotifierProvider<CguModel>(create: (context) => CguModel()),
      ],
      builder: (BuildContext context, _) => LenraTheme(
        themeData: themeData,
        child: MaterialApp.router(
          routerConfig: BackofficeNavigator.router,
          title: 'Lenra',
          theme: ThemeData(
            visualDensity: VisualDensity.standard,
            textTheme: TextTheme(bodyText2: themeData.lenraTextThemeData.bodyText),
          ),
        ),
      ),
    );
  }
}
