import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/business/controllers/business_controller.dart';
import 'package:sixam_mart/features/business/domain/models/package_model.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/services/location_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/auth/domain/models/store_body_model.dart';
import 'package:sixam_mart/features/auth/domain/services/store_registration_service_interface.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:http/http.dart' as http;

enum ImageType {
  logo,
  cover,
  gst,
  aadhar,
  msme,
  pancard,
  fssai,
}
class StoreRegistrationController extends GetxController implements GetxService {
  final StoreRegistrationServiceInterface storeRegistrationServiceInterface;
  final LocationServiceInterface locationServiceInterface;

  StoreRegistrationController({required this.locationServiceInterface, required this.storeRegistrationServiceInterface});
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panCardrController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double _storeStatus = 0.1;
  double get storeStatus => _storeStatus;

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  XFile? _pickedCover;
  XFile? get pickedCover => _pickedCover;

  XFile? _pickGst;
  XFile? get pickedGst => _pickGst;

  XFile? _pickedAadhar;
  XFile? get pickedAadhar => _pickedAadhar;

  XFile? _pickedMsme;
  XFile? get pickedMsme => _pickedMsme;

  XFile? _pickedPancard;
  XFile? get pickedPancard => _pickedPancard;

  XFile? _pickedFssai;
  XFile? get pickedFssai => _pickedFssai;

  LatLng? _restaurantLocation;
  LatLng? get restaurantLocation => _restaurantLocation;

  List<int>? _zoneIds;
  List<int>? get zoneIds => _zoneIds;

  int? _selectedZoneIndex = 0;
  int? get selectedZoneIndex => _selectedZoneIndex;

  List<ZoneDataModel>? _zoneList;
  List<ZoneDataModel>? get zoneList => _zoneList;

  List<ModuleModel>? _moduleList;
  List<ModuleModel>? get moduleList => _moduleList;

  int? _selectedModuleIndex = -1;
  int? get selectedModuleIndex => _selectedModuleIndex;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  String? _storeAddress;
  String? get storeAddress => _storeAddress;

  String _storeMinTime = '--';
  String get storeMinTime => _storeMinTime;

  String _storeMaxTime = '--';
  String get storeMaxTime => _storeMaxTime;

  String _storeTimeUnit = 'minute';
  String get storeTimeUnit => _storeTimeUnit;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  bool _inZone = false;
  bool get inZone => _inZone;

  int _businessIndex = 0;
  int get businessIndex => _businessIndex;

  int _activeSubscriptionIndex = 0;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  PackageModel? _packageModel;
  PackageModel? get packageModel => _packageModel;

  String? _selectedPickupZone;
  String? get selectedPickupZone => _selectedPickupZone;

  int? _selectedPickupZoneId;
  int? get selectedPickupZoneId => _selectedPickupZoneId;

  final List<String> _pickupZoneList = [];
  List<String> get pickupZoneList => _pickupZoneList;

  final List<int> _pickupZoneIdList = [];
  List<int> get pickupZoneIdList => _pickupZoneIdList;

  void setSelectedPickupZone(String? zone, int? zoneId) {
    if (zone != null && zoneId != null) {
      if (_pickupZoneList.contains(zone) || _pickupZoneIdList.contains(zoneId)) {
        showCustomSnackBar('zone_already_added_please_select_another'.tr);
      } else {
        _selectedPickupZone = zone;
        _pickupZoneList.add(zone);
        _pickupZoneIdList.add(zoneId);
        update();
      }
    }
  }

  void removePickupZone(String zone, int zoneId) {
    _selectedPickupZone = null;
    _pickupZoneList.remove(zone);
    _pickupZoneIdList.remove(zoneId);
    update();
  }

  void clearPickupZone() {
    _selectedModuleIndex = -1;
    _selectedPickupZone = null;
    _pickupZoneList.clear();
    _pickupZoneIdList.clear();
  }

  void showHidePass({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  Future<void> setZoneIndex(int? index, {bool canUpdate = true}) async {
    _selectedZoneIndex = index;
    _moduleList = null;
    _selectedModuleIndex = -1;
    update();
    if(canUpdate){
      await getModules(zoneList![selectedZoneIndex!].id);
      update();
    }
  }

  void minTimeChange(String time){
    _storeMinTime = time;
    update();
  }

  void maxTimeChange(String time){
    _storeMaxTime = time;
    update();
  }

  void timeUnitChange(String unit){
    _storeTimeUnit = unit;
    update();
  }

  void storeStatusChange(double value, {bool isUpdate = true}){
    _storeStatus = value;
    if(isUpdate) {
      update();
    }
  }

  void selectModuleIndex(int? index, {canUpdate = true}) {
    _selectedModuleIndex = index;
    if(canUpdate) {
      update();
    }
  }

  void pickImage(ImageType type, bool isRemove) async {
    if (isRemove) {
      switch (type) {
        case ImageType.logo:
          _pickedLogo = null;
          break;
        case ImageType.cover:
          _pickedCover = null;
          break;
        case ImageType.gst:
          _pickGst = null;
          break;
        case ImageType.aadhar:
          _pickedAadhar = null;
          break;
        case ImageType.msme:
          _pickedMsme = null;
          break;
        case ImageType.pancard:
          _pickedPancard = null;
          break;
        case ImageType.fssai:
          _pickedFssai = null;
          break;
      }
    } else {
      final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      switch (type) {
        case ImageType.logo:
          _pickedLogo = picked;
          break;
        case ImageType.cover:
          _pickedCover = picked;
          break;
        case ImageType.gst:
          _pickGst = picked;
          break;
        case ImageType.aadhar:
          _pickedAadhar = picked;
          break;
        case ImageType.msme:
          _pickedMsme = picked;
          break;
        case ImageType.pancard:
          _pickedPancard = picked;
          break;
        case ImageType.fssai:
          _pickedFssai = picked;
          break;
      }
    }
    update();
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))) {
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = 0;
    _restaurantLocation = null;
    _zoneIds = null;
    List<ZoneDataModel>? zones = await storeRegistrationServiceInterface.getZoneList();
    if (zones != null) {
      _zoneList = [];
      _zoneList!.addAll(zones);
      setLocation(LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ), forStoreRegistration: true, zoneId: _zoneList![0].id);
      await getModules(_zoneList![0].id);
    }
    update();
  }

  void setLocation(LatLng location, {bool forStoreRegistration = false, int? zoneId}) async {
    // ZoneResponseModel response = await Get.find<LocationController>().getZone(
    //   location.latitude.toString(), location.longitude.toString(), false, handleError: true,
    // );
    ZoneResponseModel response = await locationServiceInterface.getZone(location.latitude.toString(), location.longitude.toString(), handleError: true);

    if(zoneId != null) {
      _inZone = await storeRegistrationServiceInterface.checkInZone(location.latitude.toString(), location.longitude.toString(), zoneId);
    }

    _storeAddress = await Get.find<LocationController>().getAddressFromGeocode(LatLng(location.latitude, location.longitude));
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
      // _selectedZoneIndex = storeRegistrationServiceInterface.prepareSelectedZoneIndex(_zoneIds, _zoneList);
      for(int index=0; index<zoneList!.length; index++) {
        if(zoneIds!.contains(zoneList![index].id)) {
          if(!forStoreRegistration) {
            _selectedZoneIndex = index;
          }
          break;
        }
      }
    }else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    update();
  }

  Future<void> getModules(int? zoneId) async {
    List<ModuleModel>? modules = await storeRegistrationServiceInterface.getModules(zoneId);
    if (modules != null) {
      _moduleList = [];
      _moduleList!.addAll(modules);
    }
    update();
  }

  void resetStoreRegistration(){
    _pickedLogo = null;
    _pickedCover = null;
    _selectedModuleIndex = -1;
    _selectedModuleIndex = -1;
    _storeMinTime = '--';
    _storeMaxTime = '--';
    _storeTimeUnit = 'minute';
    update();
  }
  void clearText(){
    aadhaarController.clear();
    panCardrController.clear();
    gstNumberController.clear();
    _pickedFssai = null;
    _pickedPancard = null;
    _pickedMsme = null;
    _pickedAadhar = null;
    _pickGst = null;
  }

  Future<void> registerStore(StoreBodyModel storeBody) async {
    _isLoading = true;
    update();
    Response? response = await storeRegistrationServiceInterface.registerStore(storeBody, _pickedLogo, _pickedCover);
    if(response.statusCode == 200) {
      Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
      int? storeId = response.body['store_id'];
      int? packageId = response.body['package_id'];
      postRegistrationData(storeId);
      clearText();
      if(packageId == null) {
        Get.find<BusinessController>().submitBusinessPlan(storeId: storeId!, packageId: null);
      } else {
        Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(
          storeId: storeId,
          packageId: packageId,
        ));
      }
      // Get.offAllNamed(RouteHelper.getBusinessPlanRoute(storeId, packageId));
    }
    _isLoading = false;
    update();
  }

  void resetBusiness(){
    _businessIndex = Get.find<SplashController>().configModel!.commissionBusinessModel == 0 ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    // _isFirstTime = true;
    _paymentIndex = Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus??false ? 1 : 0;
  }

  Future<void> getPackageList({bool isUpdate = true, int? moduleId}) async {
    _packageModel = await storeRegistrationServiceInterface.getPackageList(moduleId: moduleId);
    if(isUpdate) {
      update();
    }
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}){
    _digitalPaymentName = name;
    if(canUpdate) {
      update();
    }
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status){
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }
  Future<void> postRegistrationData(int? storeID) async {
    var uri = Uri.parse('https://smartvyapaar.com/node-api/store/$storeID/documents');
    var request = http.MultipartRequest('POST', uri);
    request.fields['gst_number'] = gstNumberController.text;
    request.fields['aadhaar_number'] = aadhaarController.text;
    request.fields['pan_number'] = panCardrController.text;
    if (_pickGst != null) {
      request.files.add(await http.MultipartFile.fromPath('gst_image', _pickGst!.path));
    }
    if (_pickedAadhar != null) {
      request.files.add(await http.MultipartFile.fromPath('aadhaar_image', _pickedAadhar!.path));
    }
    if (_pickedMsme != null) {
      request.files.add(await http.MultipartFile.fromPath('msme_image', _pickedMsme!.path));
    }
    if (_pickedPancard != null) {
      request.files.add(await http.MultipartFile.fromPath('pan_image', _pickedPancard!.path));
    }
    if (_pickedFssai != null) {
      request.files.add(await http.MultipartFile.fromPath('fssai_image', _pickedFssai!.path));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        clearText();
        print('Success ✅');
      } else {
        print('Failed ❌');
      }
    } catch (e) {
      print('Error during request: $e');
    }
  }

}