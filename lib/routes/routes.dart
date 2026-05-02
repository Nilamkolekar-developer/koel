import 'package:autopeepal/logic/bindings/addServiceRequest_bindings.dart';
import 'package:autopeepal/logic/bindings/myEsn_bindings.dart';
import 'package:autopeepal/views/screens/auth/login.dart';
import 'package:autopeepal/views/screens/auth/register.dart';
import 'package:autopeepal/views/screens/loacalDatasetFlashFile/loacalDatasetFlashFileScreen.dart';

import 'package:autopeepal/views/screens/myEsn/AddServiceRequestForm.dart';
import 'package:autopeepal/views/screens/myEsn/appFeaturePage.dart';
import 'package:autopeepal/views/screens/myEsn/closeServiceRequest.dart';
import 'package:autopeepal/views/screens/myEsn/flashECUScreen.dart';
import 'package:autopeepal/views/screens/myEsn/myEsnScreen.dart';
import 'package:autopeepal/views/screens/myEsn/openServiceRequestScreen.dart';
import 'package:autopeepal/views/screens/myEsn/srnNumberPage.dart';
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
      name: Routes.srnpage,
      //binding: RegisterBindings(),
      page: () => SrnNumberPage(),
    ),
    GetPage(
      name: Routes.flashEcuPage,
      //binding: RegisterBindings(),
      page: () => FlashEcuPage(),
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
  ];
}
