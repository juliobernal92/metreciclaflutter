class ApiEndPoints {
  static const String baseUrl =
      'http://192.168.0.21/metrecicla_api_v2/controllers/';
  static EndPoints endpoints = EndPoints();
}

class EndPoints {
  final String loginService = 'empleados.php';
  final String getEmployeesService = 'empleados.php';
  final String getchatarrasService = 'chatarras.php';
}
