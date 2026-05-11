import 'package:autopeepal/logic/bindings/addServiceRequest_bindings.dart';
import 'package:autopeepal/logic/bindings/flashEcu_bindings.dart';
import 'package:autopeepal/logic/bindings/myEsn_bindings.dart';
import 'package:autopeepal/views/screens/LocalFlashing/localFlashing.dart';
import 'package:autopeepal/views/screens/appFeature/appFeatureScreen.dart';
import 'package:autopeepal/views/screens/appFeature/dtcScreen.dart';
import 'package:autopeepal/views/screens/appFeature/firmwareUpdate.dart';
import 'package:autopeepal/views/screens/appFeature/flashEcuList.dart';
import 'package:autopeepal/views/screens/appFeature/flashEcuScreen.dart';
import 'package:autopeepal/views/screens/appFeature/freezeFrameScreen.dart';
import 'package:autopeepal/views/screens/appFeature/gdImageScreen.dart';
import 'package:autopeepal/views/screens/appFeature/imageZoomingPage.dart';
import 'package:autopeepal/views/screens/appFeature/infoPage.dart';
import 'package:autopeepal/views/screens/appFeature/liveParameterScreen.dart';
import 'package:autopeepal/views/screens/appFeature/liveParameterSelectedPage.dart';
import 'package:autopeepal/views/screens/appFeature/treeListPage.dart';
import 'package:autopeepal/views/screens/appFeature/treeSurveyList.dart';
import 'package:autopeepal/views/screens/appFeature/writeParameterScreen.dart';
import 'package:autopeepal/views/screens/auth/login.dart';
import 'package:autopeepal/views/screens/auth/register.dart';
import 'package:autopeepal/views/screens/connection/connectionScreen.dart';
import 'package:autopeepal/views/screens/connection/writeSSIDPassScreen.dart';
import 'package:autopeepal/views/screens/loacalDatasetFlashFile/loacalDatasetFlashFileScreen.dart';
import 'package:autopeepal/views/screens/myEsn/AddServiceRequestForm.dart';
import 'package:autopeepal/views/screens/myEsn/myEsnScreen.dart';
import 'package:autopeepal/views/screens/myEsn/openServiceRequestScreen.dart';
import 'package:autopeepal/views/screens/myEsn/wifiDevicePage.dart';
import 'package:autopeepal/views/screens/tickit/createTickit.dart';
import 'package:autopeepal/views/screens/tickit/tickitList.dart';
import 'package:get/get.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/views/screens/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: Routes.splashScreen, page: () => SplashScreen()),
    // GetPage(name: Routes.devScreen, page: () => DevScreen()),
    GetPage(
      name: Routes.loginScreen,
      //binding: LoginBindings(),
      page: () => LoginScreen(),
    ),

    // GetPage(
    //   name: Routes.blutoothDevices,
    //   //binding: LoginBindings(),
    //  // page: () => BluetoothDevicesPage(),
    // ),

    GetPage(
      name: Routes.registerScreen,
      // binding: RegisterBindings(),
      page: () => RegisterScreen(),
    ),

    GetPage(
      name: Routes.esnScreen,
      binding: MyesnBindings(),
      page: () => SrnTypeSelectionPage(),
    ),
    GetPage(
      name: Routes.addServiceForm,
      binding: AddServiceRequestBindings(),
      page: () => AddServiceRequestPage(),
    ),
    GetPage(
      name: Routes.openServiceRequest,
      //binding: RegisterBindings(),
      page: () => OpenServiceRequestListPage(),
    ),
    // GetPage(
    //   name: Routes.closeServiceRequest,
    //   //binding: RegisterBindings(),
    //   page: () => CloseServiceRequest(),
    // ),
    GetPage(
      name: Routes.ConnectionPage,
      //binding: RegisterBindings(),
      page: () => ConnectionPage(),
    ),

    GetPage(
      name: Routes.wifiDevicePage,
      //binding: RegisterBindings(),
      page: () => WifiDevicesPage(),
    ),
    GetPage(
      name: Routes.appFeaturePage,
      //binding: RegisterBindings(),
      page: () => AppFeaturePage(),
    ),
    GetPage(
      name: Routes.tickitScreen,
      //binding: RegisterBindings(),
      page: () => TickitScreen(),
    ),
    GetPage(
      name: Routes.tickitList,
      //binding: RegisterBindings(),
      page: () => TicketsListPage(),
    ),
    GetPage(
      name: Routes.localDatasetFiles,
      //binding: RegisterBindings(),
      page: () => LocalDatasetFilePage(),
    ),
    GetPage(
      name: Routes.localFlashing,
      //binding: RegisterBindings(),
      page: () => LocalFlashingPage(),
    ),
    GetPage(
      name: Routes.writeSSIDPASS,
      //binding: RegisterBindings(),
      page: () => WriteSsidPassPage(),
    ),
    GetPage(
      name: Routes.dtcScreen,
      //binding: RegisterBindings(),
      page: () => DtcListPage(),
    ),
    GetPage(
      name: Routes.writeParameter,
      //binding: RegisterBindings(),
      page: () => WriteParameterPage(),
    ),
    GetPage(
      name: Routes.liveParameter,
      //binding: RegisterBindings(),
      page: () => LiveParameterSelectPage(),
    ),
    GetPage(
      name: Routes.liveParameterSelected,
      //binding: RegisterBindings(),
      page: () => LiveParameterSelectedPage(),
    ),
    GetPage(
      name: Routes.firmwareUpdateScreen,
      //binding: RegisterBindings(),
      page: () => FirmwareUpdatePage(),
    ),
    GetPage(
      name: Routes.flashEcuPage,
      binding: FlashEcuBindings(),
      page: () => FlashEcuPage(),
    ),
    GetPage(
      name: Routes.flashListPage,
      //binding: RegisterBindings(),
      page: () => FlashEcuListPage(),
    ),
    GetPage(
      name: Routes.infoPage,
      //binding: RegisterBindings(),
      page: () => InfoPage(),
    ),
      GetPage(
      name: Routes.treeListPage,
      //binding: RegisterBindings(),
      page: () => TreeListPage(),
    ),
    GetPage(
      name: Routes.treeListSurveyPage,
      //binding: RegisterBindings(),
      page: () => TreeSurveyPage(),
    ),
     GetPage(
      name: Routes.gdImagePage,
      //binding: RegisterBindings(),
      page: () => GdImagePage(),
    ),
     GetPage(
      name: Routes.imageZoomingPage,
      //binding: RegisterBindings(),
      page: () => ImageZoomingPage(),
    ),
    GetPage(
      name: Routes.freezeFrame,
      //binding: RegisterBindings(),
      page: () => FreezeFramePage(),
    ),
  ];
}
